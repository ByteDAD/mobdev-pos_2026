# MobDev POS (Option 2)

## Ringkasan Aplikasi
Aplikasi POS sederhana untuk mengelola produk, supplier, pembelian, dan profil pengguna. Fitur utama:
- Login & Register
- Dashboard ringkas (total produk, stok, nilai stok)
- Kelola Produk (CRUD, foto via URL, kategori/merk, favorit, filter)
- Kelola Supplier (CRUD, filter)
- Pembelian (buat PO, detail PO, status Diproses/Dikirim/Selesai, filter)
- Log aktivitas & Notifikasi (ikon bel + badge)
- Pengaturan (notifikasi, badge, peringatan stok rendah)

## Packages / Third‑Party
- Flutter SDK (Material)
- Tidak ada package pihak ketiga tambahan.

## Lesson Learned
Selama membuat aplikasi ini, saya belajar membangun arsitektur sederhana yang tetap rapi dengan state yang terpusat (store) agar data produk, supplier, pembelian, dan profil bisa dipakai lintas halaman. Saya juga belajar bahwa desain UI yang cukup konsisten sangat bergantung pada theme yaitu menentukan primary/accent yang nyaman dan menerapkannya ke komponen seperti AppBar, Card, NavigationBar, dan Drawer memberi hasil yang lebih profesional.

Pada bagian fitur, saya belajar menghubungkan form dengan data list (CRUD), membuat filter yang muncul hanya ketika dibutuhkan, serta menambahkan status pembelian yang bisa diubah agar proses bisnis terlihat jelas (diproses/dikirim/selesai). Integrasi gambar via URL mengajarkan pentingnya permission internet di Android dan fallback saat gambar gagal dimuat. Selain itu, log aktivitas dan notifikasi membantu saya memahami pentingnya feedback untuk pengguna terhadap perubahan data.

Referensi yang digunakan: dokumentasi resmi Flutter (Material widgets, Navigation, forms) dan contoh UI dari assignment.
