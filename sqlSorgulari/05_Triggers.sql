-- ************************************************************
-- PROJE: YEMEK SİPARİŞ SİSTEMİ
-- DOSYA: 05_Triggers.sql
-- İÇERİK: Otomatik İşleyiş Tetikleyicileri (Triggers)
-- ************************************************************

use YemekSiparisDB;
GO

-- TRIGGER 1: trg_OtomatikHavuzGuncelle
-- Bağış yapıldığında merkezi havuzu güncel tutar.
create trigger trg_OtomatikHavuzGuncelle
on Bagislar
after insert
as
begin
    set nocount on;
    declare @GelenTutar decimal(10,2);
    select @GelenTutar = Miktar from inserted;

    update AskidaYemekHavuzu
    set ToplamBakiye  = ToplamBakiye + @GelenTutar,
        ToplamBagis   = ToplamBagis + 1,
        SonGuncelleme = getdate()
    where HavuzID = 1;
end;
GO

-- TRIGGER 2: trg_AskidaSiparisKontrol
-- Askıda yemek ödemelerinde bakiyeyi kontrol eder ve düşer.
create trigger trg_AskidaSiparisKontrol
on Odemeler
after insert
as
begin
    set nocount on;

    if not exists (select 1 from inserted where OdemeYontemi = 'AskidaYemek')
        return;

    declare @SipNo     int;
    declare @TutarDeger decimal(10,2);
    declare @MusNo     int;
    declare @HavuzBakiye decimal(12,2);

    select @SipNo = SiparisID from inserted where OdemeYontemi = 'AskidaYemek';

    select @TutarDeger = ToplamTutar,
           @MusNo      = MusteriID
    from Siparisler
    where SiparisID = @SipNo;

    select @HavuzBakiye = ToplamBakiye from AskidaYemekHavuzu where HavuzID = 1;

    if @HavuzBakiye < @TutarDeger
    begin
        raiserror ('Hata: Havuzda yeterli bakiye yok!', 16, 1);
        rollback transaction;
        return;
    end;

    update AskidaYemekHavuzu
    set ToplamBakiye         = ToplamBakiye - @TutarDeger,
        ToplamKullanimSayisi = ToplamKullanimSayisi + 1,
        SonGuncelleme        = getdate()
    where HavuzID = 1;

    insert into AskidaSiparisler (MusteriID, SiparisID, KullanilanMiktar)
    values (@MusNo, @SipNo, @TutarDeger);
end;
GO

-- TRIGGER 3: trg_SiparisTamamlandigindaCiro
-- Sipariş teslim edildiğinde restoran cirosunu ve kurye durumunu günceller.
create trigger trg_SiparisTamamlandigindaCiro
on Siparisler
after update
as
begin
    set nocount on;

    if not exists (
        select 1 from inserted i join deleted d on i.SiparisID = d.SiparisID
        where i.Durum = 'Teslim Edildi' and d.Durum <> 'Teslim Edildi'
    )
        return;

    declare @ResNo     int;
    declare @ParaTutar  decimal(10,2);
    declare @KurNo     int;

    select @ResNo     = RestoranID,
           @ParaTutar = ToplamTutar,
           @KurNo     = KuryeID
    from inserted
    where Durum = 'Teslim Edildi';

    update Restoranlar
    set ToplamCiro = ToplamCiro + @ParaTutar
    where RestoranID = @ResNo;

    if @KurNo is not null
    begin
        update Kuryeler
        set IsAvailable = 1
        where KuryeID = @KurNo;
    end;
end;
GO

-- TRIGGER 4: trg_PuanHesapla
-- Yeni yorum geldiğinde restoranın ortalama puanını günceller.
create trigger trg_PuanHesapla
on Yorumlar
after insert
as
begin
    set nocount on;
    declare @TargetResID int;
    select @TargetResID = RestoranID from inserted;

    update Restoranlar
    set OrtalamaPuan = (
        select avg(cast(Puan as decimal(5,2)))
        from Yorumlar
        where RestoranID = @TargetResID
          and IsActive = 1
    )
    where RestoranID = @TargetResID;
end;
GO
