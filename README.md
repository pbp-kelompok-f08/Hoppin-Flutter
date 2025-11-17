# 📌 Proyek Django F08

## 👥 Anggota Kelompok
<details>
  <summary>Daftar Anggota</summary>

  - M Naufal Zhafran Rabiul Batara (2406361694)  
  - Fitto Fadhelli Voltanie Ariyana (2406423401)  
  - Yahya Muhandar Fathana (2406415936)  
  - Dion Wisdom Pasaribu (2406414536)  
  - Afifah Widhia Rahayu (2406402662)

</details>

---

## 📖 Deskripsi Aplikasi
<details>
  <summary>Lihat Deskripsi</summary>

Hoppin ditujukan bagi seluruh individu yang memiliki minat terhadap aktivitas olahraga, baik pemula maupun mereka yang telah rutin berolahraga. Platform ini menjadi wadah bagi masyarakat yang ingin tetap aktif, membangun relasi sosial, serta berpartisipasi dalam berbagai kegiatan olahraga di sekitar mereka. Melalui fitur seperti threads interaktif, sistem booking venue, dan Open Party / Find Party, Hoppin mempermudah pengguna untuk berbagi pengalaman, menemukan komunitas dengan minat serupa, serta berpartisipasi dalam event olahraga dengan mudah. Selain itu, Hoppin juga memberikan peluang bagi penyedia fasilitas olahraga, pelatih, dan penyelenggara acara untuk memperluas jangkauan audiensnya secara efisien. Dengan menggabungkan interaksi digital dan aktivitas nyata, Hoppin hadir sebagai platform yang mendukung gaya hidup sehat, aktif, dan terhubung bagi semua kalangan.

### Keunggulan dan Manfaat:
- **Share & Connect:** Bikin threads, diskusi, dan temukan komunitas dengan minat sama.  
- **Booking Mudah:** Temukan dan pesan venue untuk olahraga atau event kapan saja tanpa ribet.  
- **Temukan Teman Olahraga:** Open Party / Find Party memudahkan kamu gabung atau bikin event olahraga.  
- **Kategori Terstruktur:** Semua konten dan event tersusun rapi, cepat menemukan yang kamu butuhkan.  
- **Aktif & Sosial:** Tidak cuma online, tapi mendorong interaksi nyata dan gaya hidup aktif.

</details>

---

## 🧩 Daftar Modul
<details>
  <summary>Lihat Modul</summary>

### 1. Postingan (Threads)
- **Fitur:** Pengguna dapat membuat, membaca, dan berinteraksi dengan postingan berbasis teks, mirip dengan Twitter.  
- **Fungsi:** Diskusi, berbagi informasi, dan interaksi sosial.

### 2. Venue (Booking Venue)
- **Fitur:** Pengguna dapat mencari, melihat detail, dan memesan venue untuk kegiatan olahraga atau acara komunitas.  
- **Fungsi:** Mempermudah pencarian dan reservasi tempat.

### 3. Match (Open Party / Find Party)
- **Fitur:** Pengguna dapat membuat atau bergabung dengan acara olahraga sesuai minat dan lokasi.  
- **Fungsi:** Meningkatkan partisipasi dalam kegiatan olahraga komunitas.

### 4. Pengguna
- **Fitur:** Manajemen akun pengguna, termasuk registrasi, login, profil, dan pengaturan privasi. Pengguna juga dapat mengkustomisasi dan mengedit profile mereka
- **Fungsi:** Personalisasi pengalaman pengguna dan kontrol akses.

### 5. Live Chat
- **Fitur:**  Pengguna dapat mengirim pesan kepada pengguna lain secara real time. 
- **Fungsi:** Mempermudah proses booking atau matching dengan komunikasi.
</details>

---

## 📊 Sumber Initial Dataset
<details>
  <summary>Lihat Dataset</summary>

### 1. Postingan (Threads)
- **Dataset:** Dataset apa 
- **Link:** https://www.kaggle.com/datasets/danielgrijalvas/twitter-threads

### 2. Venue (Booking Venue)
- **Dataset:** Football Stadium
- **Link:** https://www.kaggle.com/datasets/imtkaggleteam/football-stadiums

### note:
untuk fitur" seperti match akan dibuatkan data dummy berdasarkan data venue yang ada.
</details>

---

## 👤 Pengguna Aplikasi
<details>
<summary>Role & Hak Akses</summary>

### 1) **User (Pengguna Umum)**
Pengguna inti aplikasi **Hoppin** untuk berinteraksi dan ikut kegiatan olahraga.

**Hak & Fitur:**
- **Threads (Postingan):** buat, edit, hapus *post* sendiri; suka & komentar pada *post* orang lain.
- **Venue Booking:** lihat daftar & detail venue, lakukan *booking*, cek riwayat/status booking di profil.
- **Match (Open/Find Party):** buat *match* terbuka atau gabung *match* yang tersedia.
- **Live Chat:** kirim pesan real-time untuk koordinasi booking/match.
- **Profil:** ubah foto/bio/minat olahraga, lihat statistik aktivitas.

### 2) **Admin**
Penjaga kualitas platform: moderasi konten, kelola data, dan pantau aktivitas.

**Hak & Fitur:**
- **Manajemen Pengguna:** lihat semua pengguna, nonaktifkan/hapus akun pelanggar.
- **Hak User lainnya:** Admin juga memiliki hak yang sama yang dimiliki oleh User.
</details>

## 🔗 Alur Integrasi
<details>
  <summary>Lihat Alur Integrasi</summary>

Aplikasi mobile **Flutter** terhubung dengan backend **Django (Django REST Framework)**. Seluruh komunikasi data menggunakan format **JSON** melalui protokol **HTTP/HTTPS**.

### 🚀 1) Arsitektur Integrasi  
- **Flutter (Mobile App)** → Mengirim request ke API (GET, POST, PUT, DELETE) melalui package seperti `http` atau `dio`.  
- **Django REST API (Backend)** → Memproses request, menjalankan logika bisnis, dan mengakses database melalui Django ORM.  
- **Database** → Menyimpan data pengguna, venue, threads, match, dan chat.

### 🔄 2) Mekanisme Alur Data  

#### 📤 **Flutter → Django (Request)**
Flutter mengirim HTTP request ke endpoint backend:
- **GET** — mengambil data (threads, venue, match list, dll)  
- **POST** — kirim data (buat postingan, pesan venue, buat match)  
- **PUT/PATCH** — update konten (edit profil, edit postingan)  
- **DELETE** — hapus konten  

#### 💾 **Django → Database**
Django memproses request:
- Validasi data di level **serializer**  
- Logika bisnis berjalan (cek ketersediaan venue, validasi user, dsb)  
- Query database via **Django ORM**

#### 📥 **Django → Flutter (Response)**
Django mengembalikan JSON berisi:
- Data berhasil diambil  
- Status sukses/gagal  
- Error message jika request tidak valid  

Flutter kemudian menampilkan data tersebut di UI:
- Update tampilan halaman venue  
- Menampilkan threads  
- Menampilkan match yang tersedia  
- Menampilkan status booking  
- Real-time update untuk chat (jika menggunakan WebSocket)

## 🚀 Deployment & Design
<details>
  <summary>Lihat Link</summary>

- **Link Deployment:** [Klik di sini]([https://m-naufal41-sosmed.pbp.cs.ui.ac.id/](https://m-naufal41-hoppin.pbp.cs.ui.ac.id/))  
- **Link Design:** [Klik di sini](https://www.figma.com/design/Osg0CvVAYUswUTmNVduHXK/PBP08?node-id=0-1&t=FcctgViSzMdoNSsh-1)  

</details>
