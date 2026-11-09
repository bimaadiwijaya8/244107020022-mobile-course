# Dokumentasi Arsitektur SOLID (Layer-First Clean Architecture)

Dokumen ini menjelaskan struktur arsitektur baru proyek Flutter `clear_architecture` yang telah dimigrasikan mengikuti prinsip **SOLID** dan pola **Clean Architecture (Layer-First)**.

---

## 1. Ringkasan Perubahan

Sebelumnya, proyek memiliki struktur campuran di mana modul data, presentasi, messaging, dan state management berada sejajar di root `lib/`, serta logika UI dan routing tertumpuk di dalam `lib/main.dart`:

```
lib/ (Sebelum)
├── data/
├── messaging/
├── providers/
├── ui/
└── main.dart (berisi konfigurasi GoRouter, NotificationHomePage, AnnouncementPage, dsb.)
```

Struktur tersebut telah direfaktor menjadi **Layer-First Clean Architecture** dengan 3 layer utama di dalam `lib/`:
1. **`domain/`**: Lapisan bisnis inti (Pure Dart), independen dari UI, framework, maupun database.
2. **`data/`**: Lapisan data yang mengimplementasikan kontrak domain dan berkomunikasi dengan SDK eksternal (Firebase Auth, FlutterSecureStorage, FCM, Dio).
3. **`presentation/`**: Lapisan antarmuka pengguna (UI widgets, Riverpod state notifiers, dan konfigurasi GoRouter).

---

## 2. Diagram Arsitektur

```
+-------------------------------------------------------------------------+
|                           PRESENTATION LAYER                            |
|   Pages (Login, Home, Notif, Pengumuman)  <--->  Riverpod Providers     |
+-------------------------------------------------------------------------+
                                    |
                                    v (memanggil)
+-------------------------------------------------------------------------+
|                              DOMAIN LAYER                               |
|   Use Cases (LoginUseCase, RegisterUseCase, ShowNotif, CancelNotif)     |
|                                   |                                     |
|   Entities (AuthSession, UserEntity, NotificationItem)                  |
|                                   ^                                     |
|   Repository Contracts (AuthRepository, TokenRepo, PushRepo) [INTERFACE]|
+-------------------------------------------------------------------------+
                                    ^
                                    | (mengimplementasikan / Dependency Inversion)
+-------------------------------------------------------------------------+
|                               DATA LAYER                                |
|   Repositories Impl (AuthRepositoryImpl, TokenRepoImpl, PushRepoImpl)   |
|   Models / DTOs (AuthSessionModel, UserModel, NotificationModel)        |
|   Data Sources (Firebase Auth, SecureStorage, FCM / LocalNotif, Dio)    |
+-------------------------------------------------------------------------+
```

---

## 3. Struktur Direktori Lengkap (`lib/`)

```
lib/
├── firebase_options.dart                                   # Konfigurasi platform Firebase
├── main.dart                                               # Entry point aplikasi (hanya bootstrap & root widget)
│
├── domain/                                                 # === LAYER 1: DOMAIN ===
│   ├── entities/                                           # Entitas model domain murni
│   │   ├── auth_session.dart                               # Token sesi (access & refresh)
│   │   ├── notification_item.dart                          # Item notifikasi
│   │   └── user_entity.dart                                # Model pengguna (uid, email)
│   ├── repositories/                                       # Kontrak antarmuka (Interface)
│   │   ├── auth_repository.dart                            # Kontrak autentikasi
│   │   ├── push_notification_repository.dart               # Kontrak notifikasi push & lokal
│   │   └── token_repository.dart                           # Kontrak penyimpanan token
│   └── usecases/                                           # Logika bisnis per kasus penggunaan
│       ├── auth/
│       │   ├── check_auth_status_usecase.dart              # Validasi sesi aktif
│       │   ├── get_current_user_usecase.dart               # Mengambil user saat ini
│       │   ├── login_usecase.dart                          # Login & simpan token
│       │   ├── logout_usecase.dart                         # Logout & bersihkan token
│       │   ├── refresh_token_usecase.dart                  # Perbarui ID token
│       │   └── register_usecase.dart                       # Registrasi akun baru & simpan token
│       └── notification/
│           ├── cancel_notification_usecase.dart            # Hapus notifikasi di drawer / status bar
│           └── show_local_notification_usecase.dart        # Tampilkan notifikasi lokal & badge
│
├── data/                                                   # === LAYER 2: DATA ===
│   ├── datasources/                                        # Akses I/O dan SDK eksternal
│   │   ├── auth_remote_datasource.dart                     # FirebaseAuth SDK & error mapping
│   │   ├── push_notification_remote_datasource.dart        # FCM, Local Notifications, & background handler
│   │   └── token_local_datasource.dart                     # FlutterSecureStorage SDK
│   ├── models/                                             # Data Transfer Objects (DTO)
│   │   ├── auth_session_model.dart                         # Parsing JSON/model sesi
│   │   ├── notification_model.dart                         # Parsing model notifikasi
│   │   └── user_model.dart                                 # Mapping dari Firebase User ke UserModel
│   ├── network/
│   │   └── api_client.dart                                 # Client Dio dengan Interceptor refresh token
│   └── repositories/                                       # Implementasi konkret domain repositories
│       ├── auth_repository_impl.dart                       # Implementasi AuthRepository
│       ├── push_notification_repository_impl.dart          # Implementasi PushNotificationRepository
│       └── token_repository_impl.dart                      # Implementasi TokenRepository
│
└── presentation/                                           # === LAYER 3: PRESENTATION ===
    ├── pages/                                              # Layar / Halaman UI
    │   ├── announcement/
    │   │   └── announcement_page.dart                      # Layar detail pengumuman (/pengumuman/:id)
    │   ├── home/
    │   │   └── notification_home_page.dart                 # Layar beranda utama
    │   ├── login/
    │   │   └── login_page.dart                             # Layar login & register
    │   └── notifications/
    │       └── notifications_page.dart                     # Layar kotak masuk notifikasi
    ├── providers/                                          # State Management (Riverpod)
    │   ├── auth_provider.dart                              # Notifier status autentikasi & user
    │   ├── dependency_injection.dart                       # Providers untuk UseCases & Repositories
    │   └── notification_provider.dart                      # Notifier daftar notifikasi & badge launcher
    └── router/                                             # Navigasi & Routing
        └── app_router.dart                                 # GoRouter & logika route guard (redirect)
```

---

## 4. Penerapan Prinsip SOLID

### 1. Single Responsibility Principle (SRP)
- **Tiap Use Case memiliki satu tujuan spesifik**: `LoginUseCase` hanya menangani alur login dan penyimpanan token, `RegisterUseCase` hanya menangani pendaftaran, `CancelNotificationUseCase` hanya menangani pembatalan notifikasi.
- **Pemisahan Data Source vs Repository**: `AuthRemoteDataSource` fokus berkomunikasi dengan API Firebase, sedangkan `AuthRepositoryImpl` mengoordinasikan mapping model ke entitas domain.
- **Pembersihan `main.dart`**: `main.dart` kini hanya berisi fungsi bootstrap `main()` dan widget root `MyApp`. Halaman seperti `NotificationHomePage` dan `AnnouncementPage` dipisahkan ke filenya masing-masing di `presentation/pages/`.

### 2. Open/Closed Principle (OCP)
- Komponen tingkat atas (Use Cases & UI) bergantung pada kontrak antarmuka di `domain/repositories/`.
- Jika di masa mendatang ingin mengganti Firebase Auth dengan backend REST kustom atau Supabase, kita cukup membuat kelas baru `CustomAuthRepositoryImpl implements AuthRepository` tanpa perlu memodifikasi kode di Domain Use Cases maupun Presentation UI.

### 3. Liskov Substitution Principle (LSP)
- `AuthRepositoryImpl` dapat disubstitusikan ke mana saja interface `AuthRepository` diharapkan.
- `AuthSessionModel` adalah turunan dari `AuthSession`, dan `UserModel` adalah turunan dari `UserEntity`. Keduanya dapat digunakan secara polimorfik tanpa menyebabkan inkonsistensi data atau runtime error.

### 4. Interface Segregation Principle (ISP)
- Antarmuka tidak digabung menjadi satu interface besar yang serba bisa.
- Kontrak dipisah menjadi antarmuka kecil yang kohesif:
  - `AuthRepository`: fokus pada operasi autentikasi dan status login.
  - `TokenRepository`: fokus pada persistensi token di penyimpanan aman.
  - `PushNotificationRepository`: fokus pada penerimaan notifikasi FCM dan drawer lokal.

### 5. Dependency Inversion Principle (DIP)
- Modul tingkat tinggi (`domain/usecases` dan `presentation/providers`) **tidak bergantung langsung** pada implementasi tingkat rendah seperti `FirebaseAuth.instance`, `FlutterSecureStorage`, atau `Dio`.
- Keduanya bergantung pada abstraksi interface yang didefinisikan di `domain/repositories/`.
- Resolusi ketergantungan dihubungkan secara bersih melalui Dependency Injection di `presentation/providers/dependency_injection.dart`.

---

## 5. Alur Kerja (Data Flow)

### A. Alur Autentikasi (Login / Register)
1. **User Action**: Pengguna menekan tombol "Masuk" pada `LoginPage`.
2. **Presentation**: `LoginPage` memanggil `ref.read(authStateProvider.notifier).login(email, password)`.
3. **Use Case**: `AuthNotifier` memanggil `LoginUseCase.execute(email, password)`.
4. **Data Repository**: `LoginUseCase` memanggil `AuthRepository.login(...)` yang dieksekusi oleh `AuthRepositoryImpl`.
5. **Data Source**: `AuthRemoteDataSourceImpl` mengirim kredensial ke Firebase Auth SDK dan mendapatkan `idToken` serta `refreshToken`.
6. **Token Persistence**: `LoginUseCase` menyimpan token ke dalam `TokenRepository` (`TokenLocalDataSourceImpl` menggunakan `FlutterSecureStorage`).
7. **Router Reactivity**: Perubahan `authStateProvider` dideteksi oleh listener di `app_router.dart`, yang otomatis mengarahkan user dari `/login` ke `/`.

### B. Alur Notifikasi (FCM & Local Notification)
1. **Penerimaan Notifikasi**: Pesan FCM diterima via `PushNotificationRemoteDataSourceImpl`.
2. **Presentation Notifier**: Callback `onMessageReceived` menambahkan data ke `notificationListProvider`.
3. **Badge Synchronization**: `notificationListProvider` otomatis memperbarui counter badge di icon aplikasi launcher via `AppBadgePlus.updateBadge(count)`.
4. **Mark As Read & Remove**: Ketika notifikasi diketuk / dibaca, `markAsReadAndRemove(id)` menghapus item dari list dan memanggil `CancelNotificationUseCase` untuk menghapus banner di notification drawer sistem.

---

## 6. Hasil Verifikasi & Pengujian

### Analisis Statis (`flutter analyze`)
```
Analyzing clear_architecture...
No issues found! (ran in 4.9s)
```
- **0 Error**, **0 Warning**, **0 Linter Issues**.

### Pengujian Otomatis (`flutter test`)
```
00:01 +8: All tests passed!
```
Semua 8 pengujian otomatis berhasil dijalankan, mencakup:
1. `Domain Use Cases Tests`: Memvalidasi `LoginUseCase`, `RegisterUseCase`, `LogoutUseCase`, dan `CheckAuthStatusUseCase` menggunakan Fake Repositories.
2. `NotificationProvider Tests`: Memvalidasi penambahan notifikasi, badge count, dan pembersihan otomatis notifikasi saat dibaca.
3. `Widget Tests`: Memvalidasi rendering antarmuka `LoginPage` dan elemen formnya.

