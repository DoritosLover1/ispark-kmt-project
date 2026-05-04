# 🚗 ISpark Project - Akıllı Otopark Rehberi

![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

İspark Project, İstanbul'daki İŞPARK otoparklarını kolayca bulmanızı, detaylarını incelemenizi ve favorilerinize eklemenizi sağlayan, modern teknolojilerle geliştirilmiş profesyonel bir mobil uygulamadır. Aynı zamanda sizlere otoparklarda rezervasyon yapmanızı sağlamak için geliştirilmiş olup **ŞUANLIK SADECE KONUM VE FAVORİLERE EKLEME ÖZELLİĞİ BULUNMAKTADIR**. (UYGULAMA SİMÜLASYON DURUMUNDADIR GERÇEK KULLANIM İÇİN KENDİ VERİ TABANI VE API BAĞLANTILARINI YAPMANIZ GEREKLİDİR)

---

## ✨ Özellikler (Features)

- 📍 **Canlı Harita Entegrasyonu:** Flutter Map ve MapTiler kullanarak hibrit harita üzerinde tüm İSpark noktalarını görüntüleyin.
- 🔍 **Akıllı Filtreleme:** Bulunduğunuz konuma en yakın otoparkları özel bir yarıçap (radius) sürgüsü ile filtreleyin.
- ⭐ **Favoriler Sistemi:** Sık kullandığınız otoparkları favorilerinize ekleyerek hızlıca erişin (Floor & Supabase senkronizasyonu).
- 🕒 **Gerçek Zamanlı Veri:** 15 dakikada bir otomatik yenilenen otopark doluluk ve konum bilgileri.
- 🌓 **Tema Desteği:** Kullanıcı tercihlerine göre dinamik Tema yönetimi.
- 📱 **Detaylı Bilgi Sayfası:** Otopark kapasitesi, çalışma saatleri ve yol tarifi gibi detaylara anında erişim.

---

## 🛠️ Kullanılan Teknolojiler (Tech Stack)

### Ana Katmanlar

- **Framework:** [Flutter](https://flutter.dev)
- **Arka Plan (Backend):** [Supabase](https://supabase.io) (Veri yönetimi ve uzaktan depolama)
- **Yerel Veritabanı:** [Floor](https://pub.dev/packages/floor) (SQLite tabanlı yerel persistence)

### Kütüphaneler ve Araçlar

- **Harita:** `flutter_map` & `latlong2`
- **Konum Servisleri:** `geolocator` & `permission_handler`
- **Durum Yönetimi (State Management):** `flutter_riverpod` & `provider`
- **Tasarım:** `google_fonts`, `webview_flutter`
- **Çevresel Değişkenler:** `flutter_dotenv`

---

## 🚀 Başlarken (Getting Started)

Projeyi yerel makinenizde çalıştırmak için aşağıdaki adımları takip edebilirsiniz:

### 1. Depoyu Klonlayın

```bash
git clone https://github.com/kullaniciadi/ispark_project.git
cd ispark_project
```

### 2. Bağımlılıkları Yükleyin

```bash
flutter pub get
```

### 3. Ortam Değişkenlerini (Environment Variables) Ayarlayın

Kök dizinde bir `.env` dosyası oluşturun ve gerekli anahtarları ekleyin:

```env
MAPTILER_MAPS_API_KEY=your_maptiler_key
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```
Dikkat edilmesi gereken bi konu ise bu projeyi doğrudan bu hâliyle kullanamazsınız. Sadece haritada görme ve favorilere ekleme özelliği var. Diğer özellikleri için **SUPABASE** ya da **Firebase** gibi hizmetlerden yararlanmanız gerekmetedir. Burada yazılar API adları parametreler burada var olan **SUPABASE**'de kodlanılmış olan **Edge Functions**'lara özeldir ve kendimize ait bir veri tabanı bulunmaktadır. Burada kişiselleştirmek isterseniz, kendiniz Edge Functions ve Database kısımlarına göre değiştirmeniz işlemeniz gerekmektedir. Ayrıca kendinize ait olan** SUPABASE_URL**, **SUPABASE_ANON_KEY** ve **MAPTILER_MAPS_API_KEY** kullanmanız zorunludur.

### 4. Kod Oluşturucu (Build Runner) Çalıştırın

Floor veritabanı dosyalarının oluşturulması için:

```bash
flutter pub run build_runner build
```

### 5. Uygulamayı Başlatın

```bash
flutter run
```

---

## 🎨 Ekran Görüntüleri (Screenshots)

| Hoşgeldiniz | Harita Görünümü | Favoriler | Ayarlar |
| :---: | :---: | :---: | :---: |
| ![Welcome](https://raw.githubusercontent.com/DoritosLover1/ispark-kmt-project/db_init/screenshots/welcome.jpg) | ![Map](https://raw.githubusercontent.com/DoritosLover1/ispark-kmt-project/db_init/screenshots/map.jpg) | ![Favorites](https://raw.githubusercontent.com/DoritosLover1/ispark-kmt-project/db_init/screenshots/favorites.jpg) | ![Settings](https://raw.githubusercontent.com/DoritosLover1/ispark-kmt-project/db_init/screenshots/settings.jpg) |

### 📽️ Uygulama Tanıtım Videosu

https://github.com/user-attachments/assets/a6f00dcd-6c23-48a8-b66f-7268de01ab1b

---

## 🤝 Katkıda Bulunma (Contributing)

1. Projeyi fork'layın.
2. Yeni bir özellik dalı (branch) oluşturun (`git checkout -b feature/YeniOzellik`).
3. Değişikliklerinizi commit'leyin (`git commit -m 'Eklendi: Yeni Özellik'`).
4. Dalınızı push'layın (`git push origin feature/YeniOzellik`).
5. Bir Pull Request açın.
