# Week 6: Authentication, Security, and FCM

Flutter project untuk latihan Firebase Cloud Messaging, local notification, dan
deep link ke halaman pengumuman.

> 📘 **Dokumentasi Arsitektur:** Proyek ini menggunakan **Clean Architecture (Layer-First)** dengan penerapan prinsip **SOLID** (`domain/`, `data/`, `presentation/`). Detail lengkap dapat dibaca di [ARCHITECTURE.md](ARCHITECTURE.md).

## Pengujian FCM

Gunakan payload yang sama untuk menguji ketiga kondisi aplikasi. Ganti topik atau
isi pesan bila diperlukan, tetapi pertahankan `data.route` agar navigasi ikut
teruji.

```json
{
	"message": {
		"topic": "pengumuman-kampus",
		"notification": {
			"title": "Jadwal kuliah berubah",
			"body": "Kelas Mobile pindah ke Ruang A2 jam 13.00"
		},
		"data": {
			"route": "/pengumuman/3",
			"id": "3"
		}
	}
}
```

| State | Yang diharapkan | Cara uji |
| --- | --- | --- |
| Foreground | Banner lokal muncul; ketuk banner untuk membuka `/pengumuman/3`. | Biarkan aplikasi terbuka, lalu kirim payload dari Firebase Console atau backend. |
| Background | Banner sistem muncul; ketuk banner untuk membuka `/pengumuman/3`. | Tekan Home, kirim payload, lalu ketuk banner. |
| Terminated | Aplikasi terbuka ke `/pengumuman/3` melalui `getInitialMessage`. | Tutup aplikasi dari recent apps, kirim payload, lalu ketuk banner. Hindari force-stop karena Android dapat menahan pengiriman FCM sampai aplikasi dibuka manual. |

## Topic Messaging

Topik digunakan untuk broadcast, misalnya pengumuman bagi seluruh mahasiswa.
`PushService.initialize()` otomatis subscribe ke `pengumuman-kampus`. Gunakan
method berikut untuk mengatur langganan secara manual:

```dart
await pushService.subscribeToCampusAnnouncements();
await pushService.unsubscribeFromCampusAnnouncements();
```

Token perangkat tetap digunakan untuk pesan personal, seperti nilai atau
tagihan; jangan gunakan topic untuk pesan personal.

## Platform dan Lifecycle

- Android 13+: `requestPermission()` meminta izin runtime notifikasi. Android
	versi sebelumnya tidak menampilkan prompt runtime ini.
- iOS: `requestPermission()` meminta izin alert, badge, dan sound. Local
	notification menggunakan pengaturan foreground yang sesuai.
- Background handler adalah fungsi top-level dengan `@pragma('vm:entry-point')`.
	Handler berjalan pada isolate terpisah; jangan gunakan `BuildContext`, widget,
	GoRouter, atau state Riverpod di dalamnya.
- `PushService` mengambil token awal, mengirimnya ke `POST /devices`, dan
	mengirim token baru melalui listener `onTokenRefresh`.

> **Konfigurasi backend:** ganti `baseUrl` contoh di `lib/data/api_client.dart`
> dengan URL API kampus. Service mengirim `fcm_token` dan nama platform ke
> endpoint `/devices`.
