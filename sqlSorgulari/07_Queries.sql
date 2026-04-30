-- ************************************************************
-- PROJE: YEMEK SİPARİŞ SİSTEMİ
-- DOSYA: 07_Queries.sql
-- İÇERİK: Analitik Sorgular ve Raporlama
-- ************************************************************

use YemekSiparisDB;
GO

-- SORGU 1: Detaylı Sipariş Takibi
-- Tüm paydaşları birleştiren geniş kapsamlı rapor.
select
    S.SiparisID as Id,
    S.SiparisTarihi as Tarih,
    S.Durum,
    (M.Ad + ' ' + M.Soyad) as MusteriAdi,
    R.Ad as Isletme,
    isnull((K.Ad + ' ' + K.Soyad), 'Atanmadı') as KuryeAdi,
    U.UrunAdi as Urun,
    SD.Adet,
    SD.BirimFiyat as Fiyat,
    (SD.Adet * SD.BirimFiyat) as SatirTutar,
    S.ToplamTutar as GenelToplam,
    O.OdemeYontemi,
    O.OdemeDurumu
from Siparisler S
inner join Kullanicilar M on S.MusteriID = M.KullaniciID
inner join Restoranlar R on S.RestoranID = R.RestoranID
left join Kullanicilar K on S.KuryeID = K.KullaniciID
inner join SiparisDetaylari SD on S.SiparisID = SD.SiparisID
inner join Urunler U on SD.UrunID = U.UrunID
left join Odemeler O on S.SiparisID = O.SiparisID
where S.IsActive = 1
order by S.SiparisTarihi desc;
GO

-- SORGU 2: Restoran Performans Analizi
-- Son 30 gün içinde en çok ciro yapan popüler restoranlar.
select
    R.Ad as Isletme,
    count(S.SiparisID) as IslemAdedi,
    sum(S.ToplamTutar) as ToplamHasılat,
    avg(S.ToplamTutar) as OrtalamaSepet,
    max(S.SiparisTarihi) as SonIslem
from Restoranlar R
inner join Siparisler S on R.RestoranID = S.RestoranID
where S.Durum = 'Teslim Edildi'
  and S.SiparisTarihi >= dateadd(day, -30, getdate())
  and S.IsActive = 1
group by R.RestoranID, R.Ad
having count(S.SiparisID) >= 5
order by ToplamHasılat desc;
GO

-- SORGU 3: Potansiyel Bağışçı Analizi
-- Sipariş veren ama henüz havuz bağışı yapmamış müşteriler.
select
    K.KullaniciID,
    K.Ad,
    K.Soyad,
    K.Eposta,
    K.KayitTarihi
from Kullanicilar K
where K.Rol = 'Musteri'
  and K.IsActive = 1
  and exists (
      select 1 from Siparisler S
      where S.MusteriID = K.KullaniciID
        and S.IsActive = 1
  )
  and not exists (
      select 1 from Bagislar B
      where B.KullaniciID = K.KullaniciID
        and B.IsActive = 1
  )
order by K.KayitTarihi;
GO
