# Sistemin İş Kuralları ve Mantıksal Çerçevesi

Bu döküman, projenin arka planında çalışan iş mantığını, veritabanı kısıtlamalarını ve "Askıda Yemek" sisteminin teknik işleyişini detaylandırır.

---

## 1. Kullanıcı ve Yetkilendirme Yapısı

- Veritabanında 4 farklı kullanıcı tipi tanımlanmıştır: **Musteri**, **RestoranSahibi**, **Kurye** ve **Admin**.
- E-posta ve telefon numaraları sistemde **tekil (UNIQUE)** olarak tanımlanmıştır, çakışmaya izin verilmez.
- Veri bütünlüğü için "fiziksel silme" yerine **"soft delete"** (IsActive=0) yöntemi benimsenmiştir.
- İhtiyaç sahibi statüsü (`IsVerifiedNeedy`), sadece sistem yöneticisi (Admin) tarafından onaylanan müşterilere verilir.

## 2. İşletme ve Ürün Yönetimi

- Her restoranın mutlaka bir sahibi olmalıdır (Kullanicilar tablosuna bağlı).
- Puanlama sistemi **1 ile 5** arasında sınırlandırılmıştır (CHECK constraint).
- Ürünler hiyerarşik olarak kategorilere (Pizza, Kebap, Burger vb.) ayrılmıştır.
- Fiyat kolonları negatif değer alamaz (CHECK constraint).
- Bir restoranın toplam cirosu, siparişler teslim edildiğinde **Trigger** mekanizması ile otomatik olarak güncellenir.

## 3. Lojistik ve Kurye Operasyonları

- Kuryeler anlık olarak sadece tek bir paket taşıyabilir.
- Teslimat onaylandığında kurye statüsü otomatik olarak "müsait" (`IsAvailable=1`) durumuna döner.
- Kurye personeli, temel kullanıcı bilgilerine ek olarak araç tipi ve plaka gibi özel verilere sahiptir.

## 4. Sipariş ve Ödeme Akışları

- Siparişlerin toplam tutarı sıfırın altında olamaz.
- Sipariş süreci: `Beklemede` → `Hazirlaniyor` → `Yolda` → `Teslim Edildi` döngüsünü izler.
- Her başarılı teslimat sonrası restoran bakiyesi ve kurye durumu eş zamanlı olarak güncellenir.
- Ödemeler; Nakit, Kredi Kartı, Online ve Askıda Yemek seçeneklerini destekler.

## 5. Müşteri Geri Bildirimleri

- Sadece teslimatı tamamlanmış siparişler için puan ve yorum bırakılabilir.
- Puanlar 1-5 aralığındadır.
- Yeni yorum girişi, ilgili restoranın genel puan ortalamasını tetikleyiciler (trigger) vasıtasıyla yeniden hesaplatır.

## 6. Askıda Yemek Modülü (Özel Modül)

### Bağış Mekanizması
- Hayırseverler havuz bakiyesine veya doğrudan belirli bir yemeğin karşılığına bağış yapabilir.
- Bağışlar isteğe bağlı olarak **anonim** (KullaniciID = NULL) gerçekleştirilebilir.
- **Para Bağışı:** Belirtilen miktar doğrudan havuza aktarılır.
- **Yemek Bağışı:** Seçilen ürünün o anki fiyatı hesaplanarak TL karşılığı havuza işlenir.
- Havuz bakiyesi, her bağış sonrası otomatik olarak güncellenir.

### Kullanım Mekanizması
- Sadece doğrulanmış ihtiyaç sahipleri bu modülden yararlanabilir.
- Ödeme aşamasında havuz bakiyesi kontrol edilir; bakiye yetersizse işlem durdurulur ve hata verilir.
- Kullanım sonrası havuz bakiyesi düşülür ve kullanım tarihçesi kayıt altına alınır.

## 7. Veritabanı Programlanabilirliği

Sistemde veri tutarlılığını sağlamak için şu ileri düzey nesneler kullanılmıştır:
- **`sp_ParaBagisEkle`**: Güvenli bakiye bağışı.
- **`sp_YemekBagisEkle`**: Ürün bazlı bağış yönetimi.
- **`sp_AskidaSiparisGiris`**: İhtiyaç sahibi siparişlerinin atomik kontrolü.
- **View Yapıları**: Aktif menülerin ve havuz durumunun anlık izlenmesi.
- **Index Yapıları**: Sık sorgulanan alanlarda (tarih, müşteri no vb.) performans artışı.

## 8. Veri Güvenliği ve Arşivleme

- Sistemde `DELETE` komutu kesinlikle kullanılmaz.
- Tüm tablolarda bulunan `IsActive` alanı üzerinden veri kontrolü yapılır.
- Görünümler (View) sadece aktif verileri son kullanıcıya sunar.
