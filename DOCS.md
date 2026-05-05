# İSPARK Projesi - Kapsamlı Fonksiyonel Dökümantasyon

Bu döküman, İSPARK otopark takip uygulaması içerisinde yer alan tüm temel modüllerin, servislerin, algoritmaların ve sayfa içi fonksiyonların detaylı işleyişini açıklamaktadır.

---

## 1. Servis Katmanı (`lib/extras/localservices.dart`)

Uygulamanın dış dünyayla (API) iletişim kurduğu temel katmandır. Supabase altyapısı kullanılmaktadır.

### `IsparkService` Sınıfı

*   **`fetchParkings()`**:
    *   **Amacı**: İSPARK otoparklarının güncel verilerini sunucudan çekmek.
    *   **İşleyiş**: `Supabase.instance.client.functions.invoke('ispark-otopark-listesi-retrieve')` fonksiyonunu çağırarak Edge Function üzerinden veri talep eder.
    *   **Veri İşleme**: Gelen raw veriyi JSON olarak parse eder (`jsonDecode`). Yanıt içerisindeki `success` bayrağını kontrol eder. Eğer başarılıysa `data` dizisini map'leyerek `ParkingLot` nesnelerinden oluşan bir liste oluşturur.
    *   **Hata Yönetimi**: API isteği başarısız olursa veya `success` false dönerse özel bir `Exception` fırlatır.
    *   **Dönüş Değeri**: `Future<List<ParkingLot>>`.

---

## 2. Durum Yönetimi Katmanı (Riverpod / Provider)

Uygulama genelinde verilerin anlık olarak güncellenmesi ve sayfalara dağıtılması için Riverpod ve Provider kullanılmıştır.

### `FavoriteParksNotifier` Sınıfı (`lib/providers/favorite_provider.dart`)
Riverpod'un `StateNotifier` sınıfından türer. Uygulama genelinde favori otopark listesini tutar.

*   **`loadFavorites()`**:
    *   **Amacı**: Veritabanındaki güncel favorileri belleğe yüklemek.
    *   **İşleyiş**: `DBInstance.getInstance()` ile veritabanı örneğini alır. `favoritesDao.getAllFavorites()` çağrısı ile verileri alır ve sınıfın `state` değişkenine atayarak dinleyen (watch) tüm widget'ların yeniden çizilmesini tetikler.
*   **`addFavorite(Favorite favorite)`**:
    *   **Parametreler**: Eklenmek istenen `Favorite` nesnesi.
    *   **İşleyiş**: `favoritesDao.insertFavorite` ile veritabanına kayıt atar. Başarılı olursa `loadFavorites()`'i çağırarak state'i günceller.
*   **`removeFavorite(int parkId)`**:
    *   **Parametreler**: Çıkarılmak istenen otoparkın benzersiz ID'si (`parkId`).
    *   **İşleyiş**: `favoritesDao.deleteFavoriteByParkID` ile veritabanından siler ve `loadFavorites()` ile state'i günceller.

### `ThemeProvider` ve `BottomTabState` Sınıfları (`lib/global/universaltheme.dart`)
`ChangeNotifier` tabanlıdır. `Provider` paketi ile kullanılır.

*   **`BottomTabState.setTab(int index)`**: Alt navigasyon barındaki (BottomNavigationBar) aktif sekmeyi değiştirir ve `notifyListeners()` ile sayfayı yeniler.
*   **`ThemeProvider`**:
    *   Uygulamanın font boyutunu (`_fontsize`) ve font ailesini (`_fontFamily`) yönetir.
    *   `_loadSettings()`: Uygulama açılışında `SharedPreferences` üzerinden kaydedilmiş tercihleri yükler.
    *   `updateFontSize(double newSize)` / `updateFontFamily(String newFont)`: Yeni ayarı uygular, `SharedPreferences`'a kaydeder ve arayüzü günceller.
    *   `themeData` (getter): Seçili font ve boyut ayarlarına göre dinamik olarak bir `ThemeData` nesnesi üretir ve tüm uygulamaya Material3 standartlarında bir renk/tipografi şeması sunar.

---

## 3. Veritabanı Katmanı (`lib/database/dao/favoritedao.dart`)

Uygulamanın yerel depolaması için Floor (SQLite abstraction) kütüphanesi kullanılmıştır.

### `Favoritedao` Arayüzü (DAO)

*   **`getAllFavorites()`**: `@Query('SELECT * FROM favorites')` - Favoriler tablosundaki tüm satırları `Favorite` nesneleri listesi olarak döndürür.
*   **`findFavorite(int id)`**: `@Query('SELECT * FROM favorites WHERE parkID = :id')` - Verilen otopark ID'sine göre tek bir favori kaydı arar. Var mı yok mu kontrolü için (`DetailedParkPage`'de kalp ikonunun durumu için) kullanılır.
*   **`insertFavorite(Favorite favorite)`**: `@Insert(onConflict: OnConflictStrategy.replace)` - Çakışma durumunda üzerine yazma stratejisi ile yeni favori kaydeder.
*   **`deleteFavoriteByParkID(int parkID)`**: `@Query('DELETE FROM favorites WHERE parkID = :parkID')` - Sadece otopark ID'si ile silme işlemi yapar.

---

## 4. Konum ve Mesafe Algoritmaları (`lib/extras/locationfunctions.dart`)

Uygulamanın kalbini oluşturan, kullanıcıya en uygun otoparkları bulan matematiksel ve algoritmik yapıları barındırır.

### `Localfunctions` Sınıfı

*   **`getCurrentLocation()`**:
    *   Öncelikle `_checkPermissions()` ile cihazın konum izinlerini ve `isLocationServiceEnabled()` ile konum servisinin açık olup olmadığını kontrol eder. İzin yoksa veya kapalıysa `null` döner.
    *   Eğer her şey uygunsa `Geolocator.getCurrentPosition` ile yüksek doğruluklu anlık konumu çeker ve `LatLng` nesnesi olarak döndürür.
*   **`calculateDistance(double lat1, double lon1, double lat2, double lon2)`**:
    *   **Amacı**: İki coğrafi nokta arasındaki "Kuş Uçuşu" mesafeyi hesaplamak.
    *   **Matematiksel Model**: *Haversine Formülü* kullanılır. Dünyanın küresel yapısını hesaba katarak enlem ve boylamlar arasındaki mesafeyi metre cinsinden çok hassas bir şekilde verir. Formülde Dünyanın ortalama yarıçapı olan 6371 km'nin iki katı (12742 km) kullanılır.
*   **`getNearbyParkings(LatLng userLocation, List<ParkingLot> parkings, double radius)`**:
    *   Tüm otopark listesini alır ve `calculateDistance` metodunu kullanarak kullanıcının belirlediği `radius` (yarıçap) değerinden daha yakın olanları filtreleyip liste olarak döner.

### 📌 Akıllı Otopark Bulma Algoritması: `getTop5NearestParkings`
Bu metot, standart "en yakın olanı göster" mantığının ötesine geçerek, otoparkın ne kadar müsait (boş) olduğunu da hesaba katarak bir **Fayda/Maliyet Skoru** çıkarır.

1.  İlk olarak `getNearbyParkings` ile belirli yarıçaptaki otoparkları filtreler (`candidates`).
2.  Liste üzerinde özel bir sıralama (`sort`) işlemi uygulanır.
3.  Her otopark için bir `score` (puan) hesaplanır. **Skor ne kadar düşükse, otopark o kadar üst sırada yer alır.**

**Puanlama Formülü**: `Skor = Gerçek Mesafe (Metre) - (Boşluk Oranı * 1000)`

*   **Boşluk Oranı**: `boş_kapasite / toplam_kapasite` (Örn: %50 boş ise 0.5)
*   **İşleyiş Mantığı**: Algoritma, otoparkın boşluk oranına göre bir "indirim" uygular. Bir otopark tamamen boş ise (oran: 1.0), algoritma o otoparkın mesafesini sanal olarak 1000 metre kısaltır. Eğer otopark tamamen doluysa (oran: 0.0), hiçbir indirim uygulanmaz ve otopark salt mesafesiyle değerlendirilir.
*   **Sonuç**: Bu sayede sistem, 300 metre yakında olan ama tıklım tıklım dolu bir otopark yerine, 700 metre mesafede olan ama tamamen boş bir otoparkı kullanıcıya birinci sırada tavsiye edebilir.

---

## 5. Sayfa Mantıkları ve UI Fonksiyonları

### `_MapPageState` (`lib/pages/mappage.dart`)
Ana harita ekranının mantığını yönetir.

*   **`_init()`**: Sayfa ilk açıldığında çalışır. Konum alır (`_localfunctions.getCurrentLocation`), API'den otoparkları çeker (`_isparkService.fetchParkings`), yükleme ekranını kapatır ve otomatik yenilemeyi başlatır.
*   **`_startAutoRefresh()`**:
    *   İki görevi vardır: Biri periyodik olarak (10 dakikada bir) verileri sunucudan çeken bir `Timer` başlatmak.
    *   Diğeri ise kullanıcının konum değişimlerini `getLocationStream` ile dinlemek.
*   **`_checkLocationAndRefresh(LatLng newLocation)`**: Konum değiştikçe tetiklenir. Kullanıcı son veri çekilen noktadan 200 metreden fazla uzaklaştıysa arka planda verileri sessizce tazeler.
*   **`_refreshParkingData()`**: API'den güncel verileri çeker. `showAllParks` değişkeni `true` ise haritada her yeri gösterir, `false` ise `getTop5NearestParkings` ile sadece en iyi 5 otoparkı listeler.

### `_DetailedParkPageState` (`lib/pages/detailedparkpage.dart`)
Otoparkın detaylarını, doluluk oranını ve rezervasyon işlemlerini barındırır.

*   **Favori İşlemleri (`_checkIfFavorite`, `_toggleFavorite`)**:
    *   Sayfa açılırken bu otoparkın veritabanında olup olmadığı sorgulanır ve kalp ikonu dolgulu veya boş hale getirilir.
    *   Tıklandığında, UI'da bir loading durumu (`_isFavoriteBusy`) oluşturulur ve `favoriteParksProvider` üzerinden ekleme/çıkarma işlemi yapılır, kullanıcıya anında `SnackBar` ile geri bildirim verilir.
*   **Haritaya Yönlendirme (`_openMapViewer`)**: Cihazdaki varsayılan harita uygulamasını (Google Maps vb.) açmak için `url_launcher` kullanarak `google.navigation:q=$lat,$lng` URL scheme'ini tetikler.
*   **Rezervasyon Sistemi (`_createReservation`, `_cancelReservation`)**:
    *   **Validasyonlar**: Formdaki plaka (`_validatePlate`) ve telefon numarası (`_validatePhone`) Regex ile doğrulanır (Örn: 34ABC1234, 05XXXXXXXXX formatı). Hata varsa TextField altında gösterilir.
    *   **OTP Aşaması (Demo)**: Doğrulamalar geçilirse, Supabase'deki `ispark-rezervasyon-otp-handler` çağrılır. Gelen OTP kodu demo amaçlı ekranda bir Dialog penceresinde gösterilir.
    *   **Rezervasyon Kaydı**: Ardından `ispark-rezervasyon-handler` çağrılarak işlem tamamlanır ve UI güncellenir. İptal kısmında da aynı validasyon ve OTP doğrulama süreci `ispark-rezervasyon-iptal-handler` ile yürütülür.

### Dinamik İşaretleyiciler (`ParkingMarkers` - `lib/extras/parkingmarkers.dart`)
Harita üzerindeki her bir otopark pininin nasıl görüneceğini belirler.

*   **Boyutlandırma (Scale)**: Ekran genişliğine göre (`MediaQuery.of(context).size.width / 375.0`) dinamik bir ölçekleme çarpanı (scale) kullanılarak işaretçilerin her ekranda orantılı görünmesi sağlanır.
*   **Dinamik Renklendirme**: `boşluk_oranı (ratio)` hesaplanır.
    *   Ratio > %50 ise yeşil (Müsait).
    *   Ratio > %20 ise turuncu (Yoğun).
    *   Aksi halde kırmızı (Dolu/Çok Yoğun) renk atanır ve haritadaki pinin rengi, gölgesi (shadow) bu renge göre şekillenir.
