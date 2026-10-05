# Jawaban Praktikum

## Pertanyaan Praktikum 1
1. **Mengapa `SharedPreferences.getInstance()` tidak boleh dipanggil di dalam method `build()` widget?**
   Method `build()` berjalan secara sinkron dan bisa dipanggil puluhan kali per detik (misal saat animasi atau *state* berubah). Karena `getInstance()` mengembalikan `Future` (asinkron) dan melakukan operasi I/O (akses *disk*), memanggilnya di dalam `build()` akan menyebabkan _memory leak_, _re-rendering_ yang berlebihan, dan membuat UI aplikasi menjadi *laggy* (patah-patah).

2. **Jelaskan alur data dari saat switch ditekan sampai nilai tersimpan di disk dan tema berubah.**
   - User menekan *Switch* -> UI memanggil method `toggle()` pada `DarkModeNotifier`.
   - `toggle()` segera mengubah *state* secara sinkron (membalik *true/false*).
   - Perubahan *state* memicu Riverpod untuk memberitahu widget yang sedang me-*watch* (seperti `MaterialApp`), sehingga tema UI langsung berubah secara instan.
   - Bersamaan dengan itu (di *background*), nilai *state* yang baru disimpan secara asinkron ke dalam memori perangkat menggunakan `SharedPreferences.getInstance().then((prefs) => prefs.setBool(...))`.

3. **Apa kelebihan dan risiko pendekatan optimistic update pada `toggle()`?**
   - **Kelebihan:** Responsibilitas aplikasi terasa sangat cepat di mata pengguna karena UI langsung berubah tanpa menunggu proses penulisan ke *disk* (I/O) selesai.
   - **Risiko:** Jika proses penyimpanan ke *disk* gagal (misalnya karena *storage* penuh), *state* di UI (tema sudah berubah) menjadi tidak sinkron dengan *disk* (menyimpan data lama). Jika aplikasi di-*restart*, tema akan kembali ke keadaan semula (sebelum di-toggle).

---

## Pertanyaan Praktikum 2
1. **Mengapa kolom `dirty` bertipe `INTEGER` dan bukan `BOOLEAN`?**
   Karena *engine* SQLite secara bawaan (native) tidak memiliki kelas penyimpanan (*storage class*) khusus untuk boolean. SQLite menyimpan nilai boolean sebagai integer, yaitu `0` untuk *false* dan `1` untuk *true*.

2. **Apa fungsi parameter `openDb` pada constructor `NoteRepository`?**
   Sebagai *Dependency Injection*. Parameter ini memungkinkan kita menyuntikkan *database* yang berbeda. Saat aplikasi berjalan, ia menggunakan *database* asli, sedangkan saat *unit testing*, kita bisa menyuntikkan *database in-memory* (yang berjalan sementara di RAM) sehingga *testing* menjadi sangat cepat dan terisolasi.

3. **Mengapa query memakai `where: 'id = ?'` dan `whereArgs`, bukan interpolasi string (`id = $id`)?**
   Untuk mencegah serangan *SQL Injection* dan menghindari *error syntax*. Penggunaan `?` dengan `whereArgs` akan memanfaatkan *prepared statements*, di mana SQLite akan secara otomatis melakukan _escaping_ karakter berbahaya pada parameter, memastikan string tetap diperlakukan sebagai data dan bukan perintah SQL.

4. **Apa yang terjadi jika Anda menambah kolom baru di `onCreate` tanpa menaikkan `version`?**
   Bagi pengguna baru, aplikasi akan berjalan normal karena `onCreate` dieksekusi lengkap. Namun bagi **pengguna lama** yang sudah memiliki *database* (sebelum kolom ditambahkan), aplikasi mereka tidak akan memicu fungsi `onUpgrade`. Akibatnya, *database* mereka tidak akan memiliki kolom baru tersebut dan aplikasi akan *crash* (*Exception: no such column*) saat mencoba membaca atau menulis data.

---

## Pertanyaan Praktikum 3
1. **Mengapa setelah setiap mutasi perlu meng-invalidate `notesProvider` dan `dirtyCountProvider`? Apa yang terjadi jika hanya salah satu?**
   - Kedua provider perlu di-invalidate agar Riverpod membuang data lama (cache) dan memuat ulang data (query ulang ke DB) sehingga UI selalu mendapatkan *state* terbaru.
   - **Jika hanya `notesProvider` yang di-invalidate:** Daftar catatan (*ListView*) akan langsung bertambah/berubah, tetapi ikon *badge* awan sinkronisasi jumlahnya tetap (stale).
   - **Jika hanya `dirtyCountProvider` yang di-invalidate:** *Badge* jumlah akan bertambah, tetapi daftar *ListView* catatan tidak memunculkan data yang baru saja ditambahkan/diubah.

2. **Bagaimana cara Anda memicu state error secara sengaja untuk menguji tampilan `_ErrorView`?**
   Anda dapat dengan sengaja melempar *exception* di fungsi repository. Contohnya, ubah sesaat bagian dalam `fetchNotes`:
   ```dart
   Future<List<Note>> fetchNotes() async {
     throw Exception('Gimik error jaringan/database');
     // ... kode asli
   }
   ```
   Lalu simpan dan cek aplikasi. Tampilan `_ErrorView` akan muncul.

3. **Mengapa aplikasi tetap berfungsi dalam mode pesawat walaupun tidak ada kode khusus untuk mode offline?**
   Karena pola arsitektur aplikasi menggunakan **Offline-First**. Seluruh interaksi UI (Read, Create, Update, Delete) selalu berkomunikasi langsung dengan SQLite (database lokal di memori HP). Oleh karena itu, ketiadaan jaringan internet sama sekali tidak memutus alur logika utama aplikasi. Jaringan hanya diperlukan di titik akhir (fitur Sinkronisasi API).

---

## Pertanyaan Praktikum 4
1. **Apa perbedaan *cache-first* dan *network-first*? Berikan satu contoh data yang lebih cocok memakai *network-first*.**
   - **Cache-first:** Aplikasi membaca dan menampilkan data dari *database* lokal lebih dahulu. Jaringan lalu diambil (*fetch*) di latar belakang untuk memperbarui data lokal secara pasif.
   - **Network-first:** Aplikasi memaksa menarik data terbaru langsung dari *server* internet terlebih dahulu. Jika jaringan putus atau *timeout*, barulah jatuh ke data *cache* (*fallback*).
   - **Contoh untuk *network-first*:** Saldo rekening perbankan, ketersediaan kursi tiket pesawat, atau harga saham (karena data harus selalu sangat relevan dan se-akurat detik tersebut).

2. **Jelaskan skenario kehilangan data yang dapat terjadi akibat `markAllSynced()`, lalu usulkan perbaikannya.**
   - **Skenario Hilang:**
     1. User punya 3 catatan kotor (`dirty = 1`).
     2. Proses `sync()` berjalan dan *upload* ke API memakan waktu 3 detik.
     3. Dalam jeda 3 detik itu, user menekan tombol '+' dan menambah 1 catatan baru. Jumlah data *dirty* di SQLite menjadi 4.
     4. API mengembalikan respons *Sukses* untuk 3 catatan awal.
     5. Method `markAllSynced()` dieksekusi: `UPDATE notes SET dirty = 0 WHERE dirty = 1`. **Semua 4 catatan** diubah menjadi bersih, padahal catatan ke-4 belum pernah dikirim. Data ke-4 hilang dari antrean sinkronisasi server!
   - **Usulan Perbaikan:** `markAllSynced()` harus menerima parameter _List_ atau *array* ID yang spesifik berhasil terkirim. Sintaks: `UPDATE notes SET dirty = 0 WHERE id IN (1, 2, 3)`.

3. **Mengapa diperlukan saklar `forceOffline` padahal sudah ada mode pesawat?**
   Agar sangat mudah melakukan *testing*, *debugging*, atau demonstrasi logika *offline* di lingkungan *emulator*. Mematikan data/Wi-Fi di OS atau *emulator* bisa memutus koneksi proses lain seperti fitur _hot-reload_ Flutter, log Firebase, koneksi Chrome DevTools, dsb.

4. **Mengapa `fetchAndCache()` menulis cache di dalam transaksi?**
   Transaksi menjamin integritas data (sifat *Atomic*: berhasil semua atau gagal semua). Jika *insert* ke *database* terputus di pertengahan karena aplikasi di-kill atau memori penuh (misalnya, *loop* berhenti di item ke-50 dari 100), transaksi akan otomatis dibatalkan (*rollback*). Ini mencegah basis data menyimpan status *cache* yang rusak atau setengah jadi.

---

## Pertanyaan Praktikum 5
1. **Mengapa kita menguji provider dengan `ProviderContainer` + `overrideWithValue` dan bukan dengan membuka database asli?**
   Karena ini merupakan **Unit Test**. Kita hanya menguji logika/state milik si Provider. Dengan melakukan _mock_ (melalui `overrideWithValue`), test berjalan sangat kencang (hitungan milidetik), bebas _side-effect_ (tidak mengisi memori OS dengan file DB palsu berulang kali), dan dapat secara presisi merekayasa respons yang kita inginkan (memaksa lempar _Error_ untuk menguji handling UI).

2. **Apa manfaat parameter `latency` pada `syncNotes` bagi pengujian?**
   `latency` memungkinkan *developer* untuk mensimulasikan kelewatan jaringan (misal: 3 detik). Hal ini mempermudah untuk menguji fitur asinkron seperti apakah indikator _loading_ (_CircularProgressIndicator_) muncul di UI secara akurat, dan melihat apa efek *race-condition* saat pengguna tetap berinteraksi ketika aplikasi masih "berpikir" mengunggah ke internet.

3. **Tuliskan satu test tambahan yang menurut Anda penting namun belum ada, beserta alasannya.**
   **Materi Test:** `test('Meresolusi konflik waktu dengan benar lewat resolveConflict')`
   **Alasan:** Sinkronisasi _Offline-First_ sering kali menemui situasi bentrok (konflik) di mana *server* dan *klien* sama-sama mengubah dokumen yang sama (karena terputus internet panjang). Jika _Timestamp Resolution_ (misal: `last-write-wins`) pada `resolveConflict` gagal, pengguna akan kehilangan hasil kerja (edit) penting mereka secara permanen. Ini adalah pilar terpenting untuk diuji secara teliti di sistem berbasis sinkronisasi.
