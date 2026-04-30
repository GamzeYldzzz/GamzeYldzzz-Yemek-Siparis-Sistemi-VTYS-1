-- ************************************************************
-- VTYS-1 PROJESİ: YEMEK SİPARİŞ PLATFORMU
-- DOSYA: 01_DDL_Tables.sql
-- İÇERİK: Veritabanı Şeması ve Tablo Yapılandırmaları
-- ÖĞRENCİ: Gamze Yıldız — 24390008086
-- ************************************************************

-- Veritabanı Hazırlığı
IF NOT EXISTS (select * from sys.databases where name = 'YemekSiparisDB')
    create database YemekSiparisDB;
GO

use YemekSiparisDB;
GO

-- ------------------------------------------------------------
-- TABLO 1: Kullanicilar
-- Sistemdeki aktörler (Müşteri, Restoran, Kurye, Admin)
-- ------------------------------------------------------------
create table Kullanicilar (
    KullaniciID   int           primary key identity(1,1),
    Ad            nvarchar(50)  not null,
    Soyad         nvarchar(50)  not null,
    Eposta        nvarchar(100) not null unique,
    Telefon       varchar(15)   not null unique,
    SifreHash     nvarchar(255) not null,
    Rol           nvarchar(20)  not null
                  check (Rol in ('Musteri','RestoranSahibi','Kurye','Admin')),
    IsVerifiedNeedy bit         default 0,  -- Onaylı ihtiyaç sahipleri
    KayitTarihi   datetime      default getdate(),
    IsActive      bit           default 1   -- Pasif/Aktif durumu
);
GO

-- ------------------------------------------------------------
-- TABLO 2: Adresler
-- Kullanıcıların kayıtlı teslimat noktaları
-- ------------------------------------------------------------
create table Adresler (
    AdresID       int           primary key identity(1,1),
    KullaniciID   int           not null,
    AdresBasligi  nvarchar(50)  not null,  -- Ev, İş, Okul vb.
    AdresTarifi   nvarchar(255) not null,
    Ilce          nvarchar(50)  not null,
    Sehir         nvarchar(50)  not null,
    IsActive      bit           default 1,
    constraint FK_Kullanici_Adresler foreign key (KullaniciID)
        references Kullanicilar(KullaniciID)
);
GO

-- ------------------------------------------------------------
-- TABLO 3: Restoranlar
-- Restoran profilleri ve finansal özet
-- ------------------------------------------------------------
create table Restoranlar (
    RestoranID    int           primary key identity(1,1),
    SahipID       int           not null,
    Ad            nvarchar(100) not null,
    Adres         nvarchar(255) not null,
    Telefon       varchar(15)   not null,
    OrtalamaPuan  decimal(3,2)  default 0.00
                  check (OrtalamaPuan between 0 and 5),
    ToplamCiro    decimal(15,2) default 0.00,
    AcilisYili    int,
    IsActive      bit           default 1,
    constraint FK_Sahibi_Restoran foreign key (SahipID)
        references Kullanicilar(KullaniciID)
);
GO

-- ------------------------------------------------------------
-- TABLO 4: MenuKategorileri
-- ------------------------------------------------------------
create table MenuKategorileri (
    KategoriID    int           primary key identity(1,1),
    KategoriAdi   nvarchar(50)  not null unique,
    IsActive      bit           default 1
);
GO

-- ------------------------------------------------------------
-- TABLO 5: Urunler
-- Menüdeki kalemler ve fiyatlandırma
-- ------------------------------------------------------------
create table Urunler (
    UrunID        int           primary key identity(1,1),
    RestoranID    int           not null,
    KategoriID    int           not null,
    UrunAdi       nvarchar(100) not null,
    Aciklama      nvarchar(max),
    Fiyat         decimal(10,2) not null
                  check (Fiyat > 0),
    HazirlamaSuresi int,
    IsActive      bit           default 1,
    constraint FK_Restoran_Urunler foreign key (RestoranID)
        references Restoranlar(RestoranID),
    constraint FK_Kategori_Urunler foreign key (KategoriID)
        references MenuKategorileri(KategoriID)
);
GO

-- ------------------------------------------------------------
-- TABLO 6: Kuryeler
-- Saha personelinin detayları
-- ------------------------------------------------------------
create table Kuryeler (
    KuryeID       int           primary key,
    AracTipi      nvarchar(30)  not null,
    PlakaNo       varchar(15),
    IsAvailable   bit           default 1,
    constraint FK_Kullanici_Kuryeler foreign key (KuryeID)
        references Kullanicilar(KullaniciID)
);
GO

-- ------------------------------------------------------------
-- TABLO 7: Siparisler
-- İşlemlerin ana merkezi
-- ------------------------------------------------------------
create table Siparisler (
    SiparisID     int           primary key identity(1,1),
    MusteriID     int           not null,
    RestoranID    int           not null,
    KuryeID       int,
    TeslimatAdresID int         not null,
    ToplamTutar   decimal(10,2) not null default 0
                  check (ToplamTutar >= 0),
    Durum         nvarchar(20)  not null default 'Beklemede'
                  check (Durum in ('Beklemede','Hazirlaniyor','Yolda','Teslim Edildi','Iptal Edildi')),
    SiparisTarihi datetime      default getdate(),
    TeslimTarihi  datetime,
    IsActive      bit           default 1,
    constraint FK_Musteri_Siparisler foreign key (MusteriID)
        references Kullanicilar(KullaniciID),
    constraint FK_Restoran_Siparisler foreign key (RestoranID)
        references Restoranlar(RestoranID),
    constraint FK_Kurye_Siparisler foreign key (KuryeID)
        references Kuryeler(KuryeID),
    constraint FK_Adres_Siparisler foreign key (TeslimatAdresID)
        references Adresler(AdresID)
);
GO

-- ------------------------------------------------------------
-- TABLO 8: SiparisDetaylari
-- ------------------------------------------------------------
create table SiparisDetaylari (
    DetayID       int           primary key identity(1,1),
    SiparisID     int           not null,
    UrunID        int           not null,
    Adet          int           not null check (Adet > 0),
    BirimFiyat    decimal(10,2) not null,
    constraint FK_Siparis_Detaylar foreign key (SiparisID)
        references Siparisler(SiparisID),
    constraint FK_Urun_Detaylar foreign key (UrunID)
        references Urunler(UrunID)
);
GO

-- ------------------------------------------------------------
-- TABLO 9: Odemeler
-- ------------------------------------------------------------
create table Odemeler (
    OdemeID       int           primary key identity(1,1),
    SiparisID     int           not null unique,
    OdemeYontemi  nvarchar(20)  not null
                  check (OdemeYontemi in ('Nakit','Kart','Online','AskidaYemek')),
    Tutar         decimal(10,2) not null check (Tutar >= 0),
    OdemeDurumu   nvarchar(20)  not null default 'Bekliyor'
                  check (OdemeDurumu in ('Bekliyor','Tamamlandi','Basarisiz','Iade')),
    OdemeTarihi   datetime      default getdate(),
    constraint FK_Siparis_Odemeler foreign key (SiparisID)
        references Siparisler(SiparisID)
);
GO

-- ------------------------------------------------------------
-- TABLO 10: Yorumlar
-- ------------------------------------------------------------
create table Yorumlar (
    YorumID       int           primary key identity(1,1),
    SiparisID     int           not null unique,
    KullaniciID   int           not null,
    RestoranID    int           not null,
    Puan          tinyint       not null
                  check (Puan between 1 and 5),
    YorumMetni    nvarchar(500),
    YorumTarihi   datetime      default getdate(),
    IsActive      bit           default 1,
    constraint FK_Siparis_Yorumlar foreign key (SiparisID)
        references Siparisler(SiparisID),
    constraint FK_Musteri_Yorumlar foreign key (KullaniciID)
        references Kullanicilar(KullaniciID),
    constraint FK_Restoran_Yorumlar foreign key (RestoranID)
        references Restoranlar(RestoranID)
);
GO

-- ------------------------------------------------------------
-- TABLO 11: AskidaYemekHavuzu
-- ------------------------------------------------------------
create table AskidaYemekHavuzu (
    HavuzID       int           primary key identity(1,1),
    ToplamBakiye  decimal(12,2) default 0.00,
    ToplamBagis   int           default 0,
    ToplamKullanimSayisi int    default 0,
    SonGuncelleme datetime      default getdate()
);
GO

-- Başlangıç kaydı
insert into AskidaYemekHavuzu default values;
GO

-- ------------------------------------------------------------
-- TABLO 12: Bagislar
-- ------------------------------------------------------------
create table Bagislar (
    BagisID       int           primary key identity(1,1),
    KullaniciID   int           null,
    Miktar        decimal(10,2) not null check (Miktar > 0),
    BagisNotu     nvarchar(200),
    BagisTarihi   datetime      default getdate(),
    IsActive      bit           default 1,
    constraint FK_Bagis_KullaniciDetay foreign key (KullaniciID)
        references Kullanicilar(KullaniciID)
);
GO

-- ------------------------------------------------------------
-- TABLO 13: AskidaSiparisler
-- ------------------------------------------------------------
create table AskidaSiparisler (
    AskidaSiparisID int         primary key identity(1,1),
    MusteriID       int         not null,
    SiparisID       int         not null unique,
    KullanilanMiktar decimal(10,2) not null,
    KullanimTarihi  datetime    default getdate(),
    constraint FK_Musteri_AskidaSiparis foreign key (MusteriID)
        references Kullanicilar(KullaniciID),
    constraint FK_Siparis_AskidaSiparis foreign key (SiparisID)
        references Siparisler(SiparisID)
);
GO
