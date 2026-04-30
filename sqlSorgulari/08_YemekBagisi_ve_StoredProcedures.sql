-- ************************************************************
-- PROJE: YEMEK SİPARİŞ SİSTEMİ
-- DOSYA: 08_YemekBagisi_ve_StoredProcedures.sql
-- İÇERİK: Gelişmiş Bağış Modülü ve Saklı Yordamlar
-- ************************************************************

use YemekSiparisDB;
GO

-- 1. BAĞIŞ TABLOSUNUN GENİŞLETİLMESİ
-- Yemek bağışlarını desteklemek için ek alanlar.
alter table Bagislar
    add BagisTuru nvarchar(10) not null default 'Para'
        constraint CHK_BagisTuru check (BagisTuru in ('Para','Yemek'));
GO

alter table Bagislar
    add BagislananUrunID int null,
        BagisAdet        int null;
GO

alter table Bagislar
    add constraint FK_Bagis_UrunReferans foreign key (BagislananUrunID)
        references Urunler(UrunID);
GO

-- 2. HAVUZ GÜNCELLEME TETİKLEYİCİSİ (REVİZE)
-- Para ve Yemek bağışlarını ayrıştırarak havuzu günceller.
drop trigger trg_OtomatikHavuzGuncelle;
GO

create trigger trg_OtomatikHavuzGuncelle
on Bagislar
after insert
as
begin
    set nocount on;

    declare @Turu          nvarchar(10);
    declare @MiktarDeger   decimal(10,2);
    declare @UrunNo        int;
    declare @AdetSayisi    int;
    declare @EklenecekPara decimal(10,2);

    select
        @Turu        = BagisTuru,
        @MiktarDeger = Miktar,
        @UrunNo      = BagislananUrunID,
        @AdetSayisi  = BagisAdet
    from inserted;

    if @Turu = 'Para'
    begin
        set @EklenecekPara = @MiktarDeger;
    end
    else if @Turu = 'Yemek'
    begin
        select @EklenecekPara = @AdetSayisi * Fiyat
        from Urunler
        where UrunID = @UrunNo;
    end

    update AskidaYemekHavuzu
    set ToplamBakiye  = ToplamBakiye + @EklenecekPara,
        ToplamBagis   = ToplamBagis + 1,
        SonGuncelleme = getdate()
    where HavuzID = 1;
end;
GO

-- 3. PROSEDÜR: Para Bağışı Gerçekleştirme
create procedure sp_ParaBagisEkle
    @ID_Kullanici int = null,
    @Tutar        decimal(10,2),
    @Not          nvarchar(200) = null
as
begin
    set nocount on;

    if @Tutar <= 0
    begin
        raiserror('Hata: Bağış miktarı pozitif olmalıdır!', 16, 1);
        return;
    end

    if @ID_Kullanici is not null and
       not exists (select 1 from Kullanicilar where KullaniciID = @ID_Kullanici and IsActive = 1)
    begin
        raiserror('Hata: Kullanıcı bulunamadı!', 16, 1);
        return;
    end

    begin try
        begin transaction;
            insert into Bagislar (KullaniciID, Miktar, BagisNotu, BagisTuru)
            values (@ID_Kullanici, @Tutar, @Not, 'Para');
        commit transaction;
        print 'Bağış işlemi başarıyla kaydedildi.';
    end try
    begin catch
        rollback transaction;
        declare @ErrMsg nvarchar(500) = error_message();
        raiserror(@ErrMsg, 16, 1);
    end catch
end;
GO

-- 4. PROSEDÜR: Yemek Bağışı Gerçekleştirme
create procedure sp_YemekBagisEkle
    @ID_Kullanici int = null,
    @ID_Urun      int,
    @Sayi         int,
    @Not          nvarchar(200) = null
as
begin
    set nocount on;

    if @Sayi <= 0
    begin
        raiserror('Hata: Adet bilgisi hatalı!', 16, 1);
        return;
    end

    if not exists (select 1 from Urunler where UrunID = @ID_Urun and IsActive = 1)
    begin
        raiserror('Hata: Ürün aktif değil veya bulunamadı!', 16, 1);
        return;
    end

    declare @UrunIsmi  nvarchar(100);
    declare @BirimFiyat decimal(10,2);
    declare @NetTutar   decimal(10,2);

    select @UrunIsmi = UrunAdi, @BirimFiyat = Fiyat
    from Urunler where UrunID = @ID_Urun;

    set @NetTutar = @Sayi * @BirimFiyat;

    begin try
        begin transaction;
            insert into Bagislar
                (KullaniciID, Miktar, BagisNotu, BagisTuru, BagislananUrunID, BagisAdet)
            values
                (@ID_Kullanici, @NetTutar, @Not, 'Yemek', @ID_Urun, @Sayi);
        commit transaction;
        print 'Yemek bağışı havuza eklendi.';
    end try
    begin catch
        rollback transaction;
        declare @Err nvarchar(500) = error_message();
        raiserror(@Err, 16, 1);
    end catch
end;
GO

-- 5. PROSEDÜR: Askıda Sipariş Oluşturma
create procedure sp_AskidaSiparisGiris
    @ID_Mus      int,
    @ID_Res      int,
    @ID_Adr      int,
    @ID_Urun     int,
    @AdetBilgisi int
as
begin
    set nocount on;

    -- Yetki Kontrolü
    if not exists (
        select 1 from Kullanicilar
        where KullaniciID = @ID_Mus and IsVerifiedNeedy = 1 and IsActive = 1
    )
    begin
        raiserror('Hata: Kullanıcı ihtiyaç sahibi listesinde değil!', 16, 1);
        return;
    end

    declare @Fiyat      decimal(10,2);
    declare @Toplam     decimal(10,2);
    declare @KasaBakiye decimal(12,2);

    select @Fiyat = Fiyat from Urunler where UrunID = @ID_Urun and IsActive = 1;

    if @Fiyat is null
    begin
        raiserror('Hata: Ürün bulunamadı!', 16, 1);
        return;
    end

    set @Toplam = @AdetBilgisi * @Fiyat;

    select @KasaBakiye = ToplamBakiye from AskidaYemekHavuzu where HavuzID = 1;

    if @KasaBakiye < @Toplam
    begin
        raiserror('Hata: Havuz bakiyesi yetersiz!', 16, 1);
        return;
    end

    begin try
        begin transaction;
            declare @YeniID int;

            insert into Siparisler
                (MusteriID, RestoranID, TeslimatAdresID, ToplamTutar, Durum)
            values
                (@ID_Mus, @ID_Res, @ID_Adr, @Toplam, 'Beklemede');

            set @YeniID = scope_identity();

            insert into SiparisDetaylari (SiparisID, UrunID, Adet, BirimFiyat)
            values (@YeniID, @ID_Urun, @AdetBilgisi, @Fiyat);

            insert into Odemeler (SiparisID, OdemeYontemi, Tutar, OdemeDurumu)
            values (@YeniID, 'AskidaYemek', @Toplam, 'Tamamlandi');

            update AskidaYemekHavuzu
            set ToplamBakiye         = ToplamBakiye - @Toplam,
                ToplamKullanimSayisi = ToplamKullanimSayisi + 1,
                SonGuncelleme        = getdate()
            where HavuzID = 1;
        commit transaction;
        print 'Askıda sipariş onaylandı.';
    end try
    begin catch
        rollback transaction;
        declare @Mesaj nvarchar(500) = error_message();
        raiserror(@Mesaj, 16, 1);
    end catch
end;
GO
