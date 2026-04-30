-- ************************************************************
-- PROJE: YEMEK SİPARİŞ SİSTEMİ
-- DOSYA: 06_Indexes.sql
-- İÇERİK: Performans İyileştirme İndeksleri
-- ************************************************************

use YemekSiparisDB;
GO

-- INDEX 1: Müşteri bazlı sipariş sorgularını hızlandırır.
create nonclustered index IDX_Siparis_Musteri
on Siparisler(MusteriID);
GO

-- INDEX 2: Restoran menü listeleme performansını artırır.
create nonclustered index IDX_Urun_Restoran
on Urunler(RestoranID)
include (UrunAdi, Fiyat, IsActive);
GO

-- INDEX 3: Tarihsel sipariş analizlerini optimize eder.
create nonclustered index IDX_Siparis_Tarih
on Siparisler(SiparisTarihi desc);
GO

-- INDEX 4: Bağış raporlama performansını iyileştirir.
create nonclustered index IDX_Bagis_Tarih
on Bagislar(BagisTarihi desc);
GO
