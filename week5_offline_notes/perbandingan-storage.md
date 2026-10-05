# Perbandingan Storage Flutter: Offline Notes App

Berikut adalah perbandingan antara **SharedPreferences**, **Hive**, **sqflite (SQLite)**, dan **Drift** untuk kebutuhan aplikasi Flutter Offline Notes (CRUD catatan dan preferensi tema).

## 1. Perbandingan Berdasarkan Kriteria

| Kriteria | SharedPreferences | Hive | sqflite (SQLite) | Drift |
| :--- | :--- | :--- | :--- | :--- |
| **Kompleksitas Query** | Sangat Rendah (Key-Value) | Rendah (Key-Value/NoSQL) | Tinggi (SQL murni) | Sangat Tinggi (SQL via Dart/Builder) |
| **Kebutuhan Relasi** | Tidak ada | Terbatas (HiveLists) | Sangat Kuat (JOINs, Foreign Keys) | Sangat Kuat (JOINs, Foreign Keys, Type-Safe) |
| **Reaktivitas (Stream)**| Tidak didukung bawaan | Ya (ValueListenable) | Tidak didukung bawaan | **Ya (Bawaan sangat baik)** |
| **Type-Safety** | Rendah (Hanya tipe dasar) | Sedang (Perlu TypeAdapter) | Rendah (Map<String, dynamic>) | **Sangat Tinggi (Generate class otomatis)** |
| **Ukuran Boilerplate** | Sangat Kecil | Sedang (TypeAdapter) | Besar (Query string manual, map parsing) | Sedang - Besar (Perlu build_runner) |
| **Kemudahan Testing** | Sangat Mudah (Mocking) | Mudah | Sedang (Perlu setup DB di memory/mock) | Mudah (Bisa jalankan di memory bawaan Drift) |

---

## 2. Trade-Off Setiap Pilihan

*   **SharedPreferences:**
    *   **Kelebihan:** Paling sederhana, ringan, bawaan, cocok untuk data kecil.
    *   **Kekurangan:** Hanya mendukung tipe primitif, sinkron di beberapa OS, sangat lambat untuk membaca/menulis banyak data.
*   **Hive:**
    *   **Kelebihan:** Sangat cepat (disimpan di memori), reaktif bawaan, sintaks mudah.
    *   **Kekurangan:** Tidak cocok untuk query kompleks (harus *filter* di memori), kurang tangguh untuk relasi antar data, file database bisa membengkak jika sering update.
*   **sqflite:**
    *   **Kelebihan:** Standar industri untuk RDBMS mobile, tangguh untuk relasi dan query rumit.
    *   **Kekurangan:** Banyak boilerplate, rawan typo (SQL string), parsing dari/ke objek manual, tidak *reactive* secara bawaan.
*   **Drift:**
    *   **Kelebihan:** Abstraksi SQL terbaik di Dart, *type-safe*, auto-complete query, dukungan Stream sangat stabil, skema tersinkronisasi.
    *   **Kekurangan:** Kurva belajar lumayan, harus pakai `build_runner` yang membuat *build time* lebih lama.

---

## 3. Rekomendasi Final

| Kebutuhan | Solusi Direkomendasikan | Alasan Utama |
| :--- | :--- | :--- |
| **Preferensi Tema** | **SharedPreferences** | Preferensi tema (Light/Dark) hanya butuh tipe primitif (boolean atau string). Sangat *overkill* jika menggunakan database. SharedPreferences adalah alat yang tepat dan paling efisien untuk menyimpan *settings* ringan yang langsung dibaca saat aplikasi berjalan. |
| **CRUD Catatan** | **Drift** | Karena target notes bisa **1000+ catatan**, Anda memerlukan kemampuan Pagination (LIMIT/OFFSET), pencarian teks (LIKE query), dan *sorting*. Selain itu, Drift menyediakan **Stream** bawaan yang membuat UI (List catatan) otomatis ter-update saat ada CRUD, dipadukan dengan keamanan *type-safe*. |

*(Catatan Alternatif: Jika Anda sangat tidak suka RDBMS, **Hive** bisa digunakan, namun filter 1000+ data dan pencarian teks bisa mulai terasa berat di memory HP low-end).*

---

## 4. Skema Tabel (Drift) untuk 1000+ Catatan

Berikut adalah skema tabel (kotak) menggunakan Drift yang efisien untuk menampung ribuan catatan, mendukung fitur standar notes seperti judul, konten, tanggal, warna (label), dan status arsip.

```dart
import 'package:drift/drift.dart';

// Definisi Tabel Notes
class Notes extends Table {
  // Primary Key auto-increment
  IntColumn get id => integer().autoIncrement()();
  
  // Judul catatan (maks 255 karakter, beri index agar search cepat)
  TextColumn get title => text().withLength(min: 0, max: 255)();
  
  // Konten utama catatan
  TextColumn get content => text()();
  
  // Warna label dalam format integer (0xAARRGGBB)
  IntColumn get color => integer().withDefault(const Constant(0xFFFFFFFF))();
  
  // Status apakah catatan diarsipkan
  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();
  
  // Tanggal dibuat
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  
  // Tanggal terakhir diubah (penting untuk sorting "Terbaru")
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
}
```

**Kenapa desain ini baik untuk 1000+ data?**
1. **Auto-Increment ID:** Efisien untuk pencarian tunggal dan *indexing*.
2. **Boolean `isArchived`:** Sangat cepat difilter dalam query SQL (`WHERE is_archived = 0`) dibanding harus membuat dua tabel berbeda atau mengecek string.
3. **`updatedAt`:** Fitur esensial untuk aplikasi catatan karena pengguna biasanya ingin melihat catatan yang "terakhir diedit" berada di paling atas (`ORDER BY updated_at DESC`). SQLite bisa melakukan sorting ini dalam waktu hitungan milidetik.
4. Tipe data seperti warna diubah menjadi `IntColumn` (*integer hex color*) agar hemat penyimpanan dan cepat dibaca Flutter.
