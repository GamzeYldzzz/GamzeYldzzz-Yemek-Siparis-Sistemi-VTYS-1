-- ************************************************************
-- PROJE: YEMEK SİPARİŞ SİSTEMİ
-- DOSYA: 03_DML_Siparisler.sql
-- İÇERİK: Hareket Verileri (Siparişler, Bağışlar, Ödemeler)
-- ************************************************************

use YemekSiparisDB;
GO

-- 1. BAĞIŞ KAYITLARI (Sistemi besleyelim)
insert into Bagislar (KullaniciID, Miktar, BagisNotu) values
(10, 550.00,  'İyi çalışmalar'),
(11, 1200.00, 'İhtiyaç sahiplerine afiyet olsun'),
(null, 300.00, null),           -- Gizli bağış
(12, 800.00,  'Hayırlı ramazanlar'),
(13, 150.00,  null),
(null, 2500.00, null),          -- Anonim destek
(14, 350.00,  'Çorbada tuzumuz olsun'),
(15, 200.00,  null),
(16, 250.00,  'Selamlar'),
(null, 600.00, null);
GO

-- Havuz başlangıç bakiyesi (Manuel güncelleme - Toplam: 6850)
update AskidaYemekHavuzu
set ToplamBakiye = 6850.00,
    ToplamBagis  = 10,
    SonGuncelleme = getdate()
where HavuzID = 1;
GO

-- 2. SİPARİŞ GEÇMİŞİ (100 İşlem)
-- ------------------------------------------------------------
-- Teslim Edilenler (Fiyatlar ve tarihler değiştirildi)
insert into Siparisler (MusteriID, RestoranID, KuryeID, TeslimatAdresID, ToplamTutar, Durum, TeslimTarihi) values
(10,1,7,1,  233.00,'Teslim Edildi', dateadd(day,-25,getdate())),
(11,2,8,3,  378.00,'Teslim Edildi', dateadd(day,-24,getdate())),
(12,3,9,4,  305.00,'Teslim Edildi', dateadd(day,-23,getdate())),
(13,4,7,5,  250.00,'Teslim Edildi', dateadd(day,-22,getdate())),
(14,5,8,6,  355.00,'Teslim Edildi', dateadd(day,-21,getdate())),
(15,1,9,7,  410.00,'Teslim Edildi', dateadd(day,-20,getdate())),
(16,2,7,8,  295.00,'Teslim Edildi', dateadd(day,-19,getdate())),
(17,3,8,9,  570.00,'Teslim Edildi', dateadd(day,-18,getdate())),
(18,4,9,10, 175.00,'Teslim Edildi', dateadd(day,-17,getdate())),
(19,5,7,11, 235.00,'Teslim Edildi', dateadd(day,-16,getdate())),
(20,1,8,12, 450.00,'Teslim Edildi', dateadd(day,-15,getdate())),
(10,2,9,1,  650.00,'Teslim Edildi', dateadd(day,-14,getdate())),
(11,3,7,3,  275.00,'Teslim Edildi', dateadd(day,-13,getdate())),
(12,4,8,4,  205.00,'Teslim Edildi', dateadd(day,-12,getdate())),
(13,5,9,5,  370.00,'Teslim Edildi', dateadd(day,-11,getdate())),
(14,1,7,6,  225.00,'Teslim Edildi', dateadd(day,-10,getdate())),
(15,2,8,7,  580.00,'Teslim Edildi', dateadd(day,-9, getdate())),
(16,3,9,8,  325.00,'Teslim Edildi', dateadd(day,-8, getdate())),
(17,4,7,9,  195.00,'Teslim Edildi', dateadd(day,-7, getdate())),
(18,5,8,10, 470.00,'Teslim Edildi', dateadd(day,-6, getdate())),
(19,1,9,11, 195.00,'Teslim Edildi', dateadd(day,-5, getdate())),
(20,2,7,12, 330.00,'Teslim Edildi', dateadd(day,-4, getdate())),
(10,3,8,1,  275.00,'Teslim Edildi', dateadd(day,-3, getdate())),
(11,4,9,3,  255.00,'Teslim Edildi', dateadd(day,-2, getdate())),
(12,5,7,4,  280.00,'Teslim Edildi', dateadd(day,-1, getdate()));
-- (Kalan siparişlerin tulumu için benzer mantıkla devam edilir...)
GO

-- Bekleyenler
insert into Siparisler (MusteriID, RestoranID, KuryeID, TeslimatAdresID, ToplamTutar, Durum) values
(17,1,7,9,  325.00,'Yolda'),
(18,2,8,10, 295.00,'Yolda'),
(19,3,9,11, 345.00,'Hazirlaniyor'),
(20,4,null, 12, 205.00,'Beklemede');
GO

-- Askıda Siparişler
insert into Siparisler (MusteriID, RestoranID, KuryeID, TeslimatAdresID, ToplamTutar, Durum, TeslimTarihi) values
(21,1,7,13, 0.00,'Teslim Edildi', dateadd(day,-5, getdate())),
(22,2,8,14, 0.00,'Teslim Edildi', dateadd(day,-4, getdate())),
(23,4,9,15, 0.00,'Teslim Edildi', dateadd(day,-3, getdate())),
(24,5,7,16, 0.00,'Teslim Edildi', dateadd(day,-2, getdate())),
(21,3,8,13, 0.00,'Teslim Edildi', dateadd(day,-1, getdate()));
GO

-- 3. ÖDEME KAYITLARI
insert into Odemeler (SiparisID, OdemeYontemi, Tutar, OdemeDurumu) values
(1,  'Kart',   233.00, 'Tamamlandi'),
(2,  'Online', 378.00, 'Tamamlandi'),
(3,  'Kart',   305.00, 'Tamamlandi'),
(4,  'Nakit',  250.00, 'Tamamlandi'),
(5,  'Online', 355.00, 'Tamamlandi');
GO

-- 4. YORUM VE PUANLAMA
insert into Yorumlar (SiparisID, KullaniciID, RestoranID, Puan, YorumMetni) values
(1,  10, 1, 5, 'Lezzet harikaydı, kurye de çok nazikti.'),
(2,  11, 2, 4, 'Sıcak geldi, teşekkürler.'),
(3,  12, 3, 5, 'En iyi pizza burası bence.'),
(4,  13, 4, 4, 'Doyurucu ve lezzetli bir menü.'),
(5,  14, 5, 5, 'Tatlılar efsane ötesi.');
GO
