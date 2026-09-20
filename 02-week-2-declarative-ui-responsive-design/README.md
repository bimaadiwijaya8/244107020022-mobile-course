# Dokumentasi Eksperimen Layout Dashboard Akademik

## 1. Prompt Desain

### Prompt
"Bandingkan dua tata letak dashboard akademik untuk Flutter: versi GridView
dan versi LayoutBuilder + Column. Jelaskan trade-off responsivitas,
fleksibilitas layout, kemudahan implementasi, dan aksesibilitas."

### Output Penting
- GridView cocok untuk kumpulan menu dalam bentuk kartu.
- LayoutBuilder + Column memberikan kontrol lebih besar terhadap responsivitas.
- GridView perlu menyesuaikan jumlah kolom pada layar kecil.
- LayoutBuilder dapat digunakan untuk menentukan layout berdasarkan lebar layar.

### Keputusan
Menggunakan LayoutBuilder + Column sebagai struktur utama dashboard.
GridView digunakan pada bagian menu yang membutuhkan tampilan berbentuk grid.

### Alasan Teknis
LayoutBuilder memungkinkan layout menyesuaikan diri berdasarkan constraint
yang diberikan oleh parent sehingga lebih mudah menangani perbedaan ukuran
layar.

---

## 2. Penguatan Konsep Expanded

### Prompt
"Jelaskan kapan penggunaan Expanded justru menyebabkan overflow di dalam Row
pada Flutter. Berikan contoh kode yang gagal dan perbaikannya."

### Kesimpulan
Expanded digunakan untuk membuat child mengisi ruang yang tersedia pada
Row atau Column. Penggunaannya perlu memperhatikan constraint dari parent
agar tidak terjadi konflik ukuran atau overflow.

---

## 3. Verification

### Prompt
"Periksa kembali rekomendasi layout di atas: apakah tetap responsif di bawah
600px, apakah mengurangi aksesibilitas, dan apakah ada widget yang tidak
tersedia di Flutter stabil saat ini?"

### Hasil Verifikasi
- Menguji layout pada layar kurang dari 600px.
- Menguji tampilan pada layar yang lebih besar.
- Memeriksa kemungkinan overflow pada Row dan Column.
- Memeriksa teks panjang.
- Memeriksa ukuran area interaksi.
- Memeriksa penggunaan widget/API terhadap Flutter stable yang digunakan.

---

## 4. Bukti Pengujian

### Screenshot
Masukkan screenshot hasil pengujian:

- [ ] Tampilan pada layar < 600px
- [ ] Tampilan pada layar desktop/tablet
- [ ] Pengujian tanpa overflow
- [ ] Pengujian teks panjang
- [ ] Pengujian aksesibilitas

### Kesimpulan
Layout dipilih berdasarkan hasil pengujian responsivitas dan fleksibilitas,
bukan hanya berdasarkan tampilan visual.