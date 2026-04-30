-- ************************************************************
-- PROJE: YEMEK SİPARİŞ SİSTEMİ
-- DOSYA: 02_DML_MockData.sql
-- İÇERİK: Örnek Veri Seti (Kullanıcılar, Restoranlar, Ürünler)
-- ************************************************************

use YemekSiparisDB;
GO

-- 1. KULLANICILAR (Yönetici, İşletmeciler, Kuryeler ve Müşteriler)
insert into Kullanicilar (Ad, Soyad, Eposta, Telefon, SifreHash, Rol, IsVerifiedNeedy) values
-- Sistem Yöneticisi
('Kemal',   'Yurt',    'admin@yemeksiparis.com',  '5550000001', 'admin_hash',  'Admin',          0),
-- İşletme Sahipleri
('Caner',   'Ozdemir', 'caner.oz@mail.com',        '5550000002', 'hash_can',   'RestoranSahibi', 0),
-- Ece is changed to Eda
('Eda',     'Aydin',   'eda.aydin@mail.com',        '5550000003', 'hash_ece',   'RestoranSahibi', 0),
('Gizem',   'Bakir',   'gizem.b@mail.com',          '5550000004', 'hash_giz',   'RestoranSahibi', 0),
('Hakan',   'Sener',   'hakan.s@mail.com',          '5550000005', 'hash_hak',   'RestoranSahibi', 0),
('Merve',   'Guler',   'merve.g@mail.com',          '5550000006', 'hash_mer',   'RestoranSahibi', 0),
-- Kurye Personeli
('Burak',   'Turan',   'burak.kurye@mail.com',      '5550000007', 'hash_bur',   'Kurye',          0),
('Deniz',   'Yalcin',  'deniz.kurye@mail.com',      '5550000008', 'hash_den',   'Kurye',          0),
('Umut',    'Koc',     'umut.kurye@mail.com',        '5550000009', 'hash_umt',   'Kurye',          0),
-- Standart Müşteriler
('Ahmet',   'Yilmaz',  'ahmet@mail.com',             '5550000010', 'hash_ahm',   'Musteri',        0),
('Selin',   'Yildiz',  'selin@mail.com',              '5550000011', 'hash_sel',   'Musteri',        0),
('Ali',     'Aras',    'ali.aras@mail.com',           '5550000012', 'hash_ali',   'Musteri',        0),
('Zeynep',  'Korkmaz', 'zeynep@mail.com',             '5550000013', 'hash_zey',   'Musteri',        0),
('Serkan',  'Dogan',   'serkan@mail.com',             '5550000014', 'hash_ser',   'Musteri',        0),
('Pelin',   'Seker',   'pelin@mail.com',              '5550000015', 'hash_pel',   'Musteri',        0),
('Mert',    'Celik',   'mert.celik@mail.com',         '5550000016', 'hash_mert',  'Musteri',        0),
('Buse',    'Kaplan',  'buse.k@mail.com',             '5550000017', 'hash_buse',  'Musteri',        0),
('Tolga',   'Arslan',  'tolga@mail.com',              '5550000018', 'hash_tolg',  'Musteri',        0),
('Irem',    'Polat',   'irem@mail.com',               '5550000019', 'hash_irem',  'Musteri',        0),
('Cagri',   'Sahin',   'cagri@mail.com',              '5550000020', 'hash_cag',   'Musteri',        0),
-- İhtiyaç Sahipleri
('Ayse',    'Demir',   'ayse.ihtiyac@mail.com',      '5550000021', 'hash_ays',   'Musteri',        1),
('Fatma',   'Celik',   'fatma.ihtiyac@mail.com',     '5550000022', 'hash_fat',   'Musteri',        1),
('Murat',   'Aksoy',   'murat.ihtiyac@mail.com',     '5550000023', 'hash_mur',   'Musteri',        1),
('Elif',    'Sari',    'elif.ihtiyac@mail.com',       '5550000024', 'hash_eli',   'Musteri',        1);
GO

-- 2. ADRESLER
insert into Adresler (KullaniciID, AdresBasligi, AdresTarifi, Ilce, Sehir) values
(10, 'Ev',       'Cumhuriyet Mah. Lale Sok. No:10 D:5',    'Besiktas',  'Istanbul'),
(10, 'İş',       'Maslak İş Merkezi A Blok Kat:2',         'Sariyer',   'Istanbul'),
(11, 'Ev',       'Bagdat Cad. No:150 D:4',                 'Kadikoy',   'Istanbul'),
(12, 'Ev',       'Ataturk Bulv. No:60',                    'Sisli',     'Istanbul'),
(13, 'Ev',       'Fatih Cad. No:25 D:1',                   'Fatih',     'Istanbul'),
(14, 'Ev',       'Bagcilar Meydan No:5',                   'Bagcilar',  'Istanbul'),
(15, 'Ev',       'Uskudar Sahil No:12',                    'Uskudar',   'Istanbul'),
(16, 'Ev',       'Pendik Sahil Sitesi C:2',                'Pendik',    'Istanbul'),
(17, 'Ev',       'Kartal Cad. No:40 D:3',                  'Kartal',    'Istanbul'),
(18, 'Ev',       'Maltepe Bulv. No:80',                    'Maltepe',   'Istanbul'),
(19, 'Ev',       'Avcilar Merkez No:15',                   'Avcilar',   'Istanbul'),
(20, 'Ev',       'Beylikduzu Meydan No:1',                 'Beylikduzu','Istanbul'),
(21, 'Ev',       'Zeytinburnu Mah. No:10',                 'Zeytinburnu','Istanbul'),
(22, 'Ev',       'Bayrampasa Cad. No:20',                  'Bayrampasa','Istanbul'),
(23, 'Ev',       'Gaziosmanpasa Mah. No:2',                'GOP',       'Istanbul'),
(24, 'Ev',       'Sultangazi Cad. No:15',                  'Sultangazi','Istanbul');
GO

-- 3. KURYELER
insert into Kuryeler (KuryeID, AracTipi, PlakaNo, IsAvailable) values
(7, 'Motosiklet', '34 ABC 123', 1),
(8, 'Bisiklet',   null,         1),
(9, 'Motosiklet', '34 XYZ 789', 1);
GO

-- 4. RESTORANLAR
insert into Restoranlar (SahipID, Ad, Adres, Telefon, AcilisYili) values
(2, 'Burger Dünyası',   'Besiktas, Istanbul',    '2120000001', 2018),
(3, 'Kebapçı Lezzet',   'Kadikoy, Istanbul',     '2160000002', 2015),
(4, 'Pizza Station',    'Sisli, Istanbul',       '2120000003', 2019),
(5, 'Anne Yemekleri',   'Fatih, Istanbul',       '2120000004', 2012),
(6, 'Tatlı Bahçesi',    'Uskudar, Istanbul',     '2160000005', 2020);
GO

-- 5. KATEGORİLER
insert into MenuKategorileri (KategoriAdi) values
('Burger'), ('Kebap'), ('Pizza'), ('Ev Yemeği'), ('Tatlı'), ('İçecek'), ('Salata');
GO

-- 6. ÜRÜNLER (Fiyatlar ve isimlerde ufak oynamalar)
-- Burger Dünyası (RestoranID: 1)
insert into Urunler (RestoranID, KategoriID, UrunAdi, Aciklama, Fiyat, HazirlamaSuresi) values
(1,1,'Klasik Menü','Dana köfte, marul, turşu',185.00,15),
(1,1,'Peynirli Burger','Cheddar, özel sos',215.00,15),
(1,1,'Çıtır Tavuk','Tavuk göğsü, özel paneli',165.00,12),
(1,1,'Büyük Burger','Double köfte, ekstra peynir',325.00,20),
(1,1,'Vejetaryen','Sebze köftesi, humus',195.00,15),
(1,1,'Barbekü Burger','Barbekü sos, karamelize soğan',255.00,18),
(1,1,'Mantar Soslu','Taze mantar, krema sos',235.00,17),
(1,6,'Kola 0.33','Kutu kola',48.00,2),
(1,6,'Ayran','Doğal yayık',32.00,2),
(1,5,'Çikolatalı Sufle','Akışkan çikolata',125.00,10);

-- Kebapçı Lezzet (RestoranID: 2)
insert into Urunler (RestoranID, KategoriID, UrunAdi, Aciklama, Fiyat, HazirlamaSuresi) values
(2,2,'Acılı Adana','Zırh kıyması, özel baharat',285.00,20),
(2,2,'Acısız Urfa','Zırh kıyması',285.00,20),
(2,2,'Kuzu Çöp Şiş','Marine edilmiş kuzu eti',355.00,25),
(2,2,'Çıtır Lahmacun','Bol harçlı',90.00,12),
(2,2,'Sarma Beyti','Yoğurtlu ve soslu',325.00,22),
(2,2,'Ali Nazik','Köz patlıcan yatağında',345.00,25),
(2,2,'Izgara Karışık','Full porsiyon',560.00,30),
(2,6,'Şalgam Suyu','Büyük boy',38.00,2),
(2,6,'Yayık Ayran','Köpüklü',38.00,2),
(2,5,'Hatay Künefe','Peynirli, sıcak',155.00,15);

-- Pizza Station (RestoranID: 3)
insert into Urunler (RestoranID, KategoriID, UrunAdi, Aciklama, Fiyat, HazirlamaSuresi) values
(3,3,'Margarita','Mozzarella ve fesleğen',225.00,20),
(3,3,'Karışık','Sucuk, mantar, mısır, biber',295.00,22),
(3,3,'Pepperoni','Bol sucuklu',315.00,22),
(3,3,'4 Peynirli','Zengin peynir harcı',335.00,22),
(3,3,'Bahçe Bahçesi','Sebze severlere',255.00,20),
(3,3,'Tavuklu Pizza','Izgara tavuk parçalı',285.00,22),
(3,3,'Akdeniz','Zeytin ve beyaz peynirli',265.00,20),
(3,6,'Limonlu Ice Tea','Soğuk çay',48.00,2),
(3,6,'Sprite','Kutu 330ml',48.00,2),
(3,5,'İtalyan Tiramisu','Kahve aromalı',145.00,5);

-- Anne Yemekleri (RestoranID: 4)
insert into Urunler (RestoranID, KategoriID, UrunAdi, Aciklama, Fiyat, HazirlamaSuresi) values
(4,4,'Kurufasulye','İspir, tane tane',165.00,5),
(4,4,'Şehriyeli Pilav','Tereyağlı',85.00,5),
(4,4,'Karnıyarık','Kıymalı patlıcan',195.00,5),
(4,4,'Sulu Köfte','Sebzeli fırın köfte',215.00,10),
(4,4,'Etli Tas Kebabı','Lokum gibi et',255.00,8),
(4,4,'Süzme Mercimek','Limonlu',80.00,5),
(4,4,'Patlıcan Musakka','Bol kıymalı',190.00,8),
(4,7,'Mevsim Salata','Taze yeşillik',95.00,5),
(4,6,'Ev Limonatası','Taze sıkım',75.00,3),
(4,5,'Fırın Sütlaç','Geleneksel tarif',105.00,5);

-- Tatlı Bahçesi (RestoranID: 5)
insert into Urunler (RestoranID, KategoriID, UrunAdi, Aciklama, Fiyat, HazirlamaSuresi) values
(5,5,'Fıstık Sarma','Yoğun Antep fıstığı',230.00,5),
(5,5,'Sütlü Nuriye','Hafif ve lezzetli',185.00,5),
(5,5,'Dibini Sıyır','Klasik kazandibi',125.00,5),
(5,5,'Çikolata Soslu','Profiterol',145.00,5),
(5,5,'Çilekli Magnolia','Taze meyveli',135.00,5),
(5,5,'Trileçe','Karamel soslu',125.00,5),
(5,5,'Mozaik Dilimi','Bitter çikolatalı',115.00,5),
(5,5,'Saray Muhallebisi','Gül kokulu',100.00,5),
(5,6,'Közde Türk Kahvesi','Lokum ile',70.00,8),
(5,6,'Sıcak Sahlep','Tarçınlı',95.00,5);
GO
