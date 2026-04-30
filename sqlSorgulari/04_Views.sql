-- ************************************************************
-- PROJE: YEMEK SİPARİŞ SİSTEMİ
-- DOSYA: 04_Views.sql
-- İÇERİK: Veritabanı Görünümleri (Views)
-- ************************************************************

use YemekSiparisDB;
GO

-- VIEW 1: vw_GuncelMenuListesi
-- Aktif durumdaki tüm restoranların menülerini listeler.
create view vw_GuncelMenuListesi as
select
    R.RestoranID,
    R.Ad as IsletmeAdi,
    R.OrtalamaPuan as Puan,
    K.KategoriAdi,
    U.UrunID,
    U.UrunAdi,
    U.Aciklama,
    U.Fiyat,
    U.HazirlamaSuresi as Sure
from Restoranlar R
join Urunler U          on R.RestoranID = U.RestoranID
join MenuKategorileri K on U.KategoriID = K.KategoriID
where R.IsActive = 1
  and U.IsActive = 1
  and K.IsActive = 1;
GO

-- VIEW 2: vw_HavuzIstatistikRaporu
-- Askıda yemek havuzunun finansal ve operasyonel özetini sunar.
create view vw_HavuzIstatistikRaporu as
select
    H.ToplamBakiye as KasaBakiyesi,
    H.ToplamBagis as BagisAdedi,
    isnull(sum(B.Miktar), 0) as ToplamGirenTutar,
    H.ToplamKullanimSayisi as HarcamaAdedi,
    isnull(sum(A.KullanilanMiktar), 0) as ToplamCikanTutar,
    H.SonGuncelleme as Tarih
from AskidaYemekHavuzu H
left join Bagislar B on B.IsActive = 1
left join AskidaSiparisler A on 1 = 1
group by H.ToplamBakiye, H.ToplamBagis, H.ToplamKullanimSayisi, H.SonGuncelleme;
GO

-- VIEW 3: vw_DetayliSiparisOzeti
-- Sipariş, müşteri, restoran ve ödeme detaylarını birleştiren kapsamlı görünüm.
create view vw_DetayliSiparisOzeti as
select
    S.SiparisID as No,
    S.SiparisTarihi,
    S.TeslimTarihi,
    S.Durum,
    (K.Ad + ' ' + K.Soyad) as MusteriIsim,
    K.Telefon as Iletisim,
    (A.Ilce + ' / ' + A.Sehir) as Adres,
    R.Ad as RestoranIsmi,
    R.Telefon as RestoranNo,
    (KR.Ad + ' ' + KR.Soyad) as KuryeIsim,
    U.UrunAdi,
    SD.Adet,
    SD.BirimFiyat,
    (SD.Adet * SD.BirimFiyat) as ToplamKalem,
    S.ToplamTutar as GenelToplam,
    O.OdemeYontemi,
    O.OdemeDurumu
from Siparisler S
join Kullanicilar K    on S.MusteriID = K.KullaniciID
join Adresler A         on S.TeslimatAdresID = A.AdresID
join Restoranlar R      on S.RestoranID = R.RestoranID
left join Kullanicilar KR on S.KuryeID = KR.KullaniciID
join SiparisDetaylari SD on S.SiparisID = SD.SiparisID
join Urunler U          on SD.UrunID = U.UrunID
left join Odemeler O    on S.SiparisID = O.SiparisID
where S.IsActive = 1;
GO
