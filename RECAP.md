# RECAP — SIKHA: Sistem Kehadiran Siswa

> Dokumentasi lengkap project SIKHA untuk keperluan laporan, pemahaman sistem, dan referensi pengembangan.

---

## 1. Ikhtisar Aplikasi

| Aspek | Detail |
|-------|--------|
| **Nama Aplikasi** | **SIKHA** — Sistem Kehadiran Siswa |
| **Institusi** | SDI Khadijah Sukorejo |
| **Fungsi** | Mencatat, memantau, dan melaporkan kehadiran siswa harian secara digital |
| **Platform** | Web Application (responsive, dapat diakses dari HP/laptop) |
| **URL Lokal** | `http://localhost/sikha-new/` |
| **URL Produksi** | `http://sindufha.my.id/` (versi React SPA) |
| **Tahun Pengembangan** | 2025 |

### Tujuan Aplikasi
1. **Menggantikan absensi manual** (buku absen fisik) dengan sistem digital
2. **Mempercepat proses presensi** — siswa cukup scan QR code atau guru isi manual
3. **Memudahkan pelaporan** — data kehadiran bisa diekspor ke Excel kapan saja
4. **Transparansi data** — guru wali kelas hanya melihat data kelasnya sendiri
5. **Audit trail** — setiap aktivitas login dan perubahan dicatat di audit log

---

## 2. Tech Stack

### Backend
| Teknologi | Versi | Kegunaan |
|-----------|-------|----------|
| **PHP** | 7.4+ / 8.x | Bahasa pemrograman utama (native, tanpa framework) |
| **MySQL** | 5.7+ / 8.x | Database relasional |
| **PDO** | built-in | Koneksi dan query database (prepared statements) |
| **PHP Session** | built-in | Manajemen sesi login pengguna |

### Frontend
| Teknologi | Kegunaan |
|-----------|----------|
| **HTML5** | Struktur halaman |
| **CSS3** | Custom design system (inspirasi Tailwind CSS v4) |
| **Vanilla JavaScript** | Interaktivitas (sidebar, dropdown, scanner, live clock) |
| **Google Fonts** | Inter (body) + Plus Jakarta Sans (heading) |
| **Bootstrap Icons** | Ikon-ikon di seluruh aplikasi |
| **html5-qrcode v2.3.8** | Pemindai QR code via kamera (scanner presensi) |
| **QRCode.js v1.0.0** | Generate QR code untuk kartu siswa |

### Server & Tools
| Teknologi | Kegunaan |
|-----------|----------|
| **XAMPP** | Local development server (Apache + MySQL) |
| **Apache** | Web server |
| **phpMyAdmin** | Database admin (via XAMPP) |

---

## 3. Struktur Project

```
sikha-new/
├── admin/                          ← Halaman khusus role ADMIN
│   ├── dashboard.php               ← Dashboard admin (statistik + chart)
│   ├── siswa.php                   ← CRUD Data Siswa
│   ├── kelas.php                   ← CRUD Data Kelas
│   ├── users.php                   ← CRUD Data Pengguna (guru/admin)
│   ├── tahun_ajaran.php            ← CRUD Tahun Ajaran
│   ├── jam_presensi.php            ← Pengaturan jam masuk & toleransi
│   ├── generate_qr.php             ← Generate & cetak QR Code per siswa
│   ├── presensi_qr.php             ← Scan QR presensi (admin)
│   ├── laporan.php                 ← Laporan + export Excel
│   └── audit_log.php               ← Log aktivitas pengguna
│
├── guru/                           ← Halaman khusus role GURU
│   ├── dashboard.php               ← Dashboard guru (stats kelas sendiri)
│   ├── presensi_qr.php             ← Scan QR presensi (guru)
│   ├── presensi_manual.php         ← Presensi manual (pilih status per siswa)
│   └── laporan.php                 ← Laporan presensi kelas sendiri
│
├── siswa/                          ← Halaman untuk siswa
│   └── qr.php                      ← Halaman QR code siswa (untuk di-scan)
│
├── api/
│   └── presensi.php                ← REST API endpoint (JSON POST) untuk scan QR
│
├── config/
│   └── database.php                ← Konfigurasi koneksi PDO ke MySQL
│
├── includes/
│   ├── header.php                  ← Topbar + layout wrapper + live clock
│   ├── sidebar.php                 ← Sidebar navigasi (admin/guru)
│   ├── footer.php                  ← Penutup HTML + load script.js
│   └── functions.php               ← Helper functions (auth, escape, audit, dll)
│
├── assets/
│   ├── css/style.css               ← Design system & semua styling
│   ├── js/script.js                ← JavaScript (sidebar, dropdown, clock, dll)
│   ├── logo.png                    ← Logo aplikasi
│   └── favicon.svg                 ← Icon tab browser
│
├── login.php                       ← Halaman login
├── logout.php                      ← Proses logout
├── profil.php                      ← Halaman profil pengguna
├── index.php                       ← Redirect ke login
└── RECAP.md                        ← Dokumentasi ini
```

---

## 4. Database

### Konfigurasi
| Parameter | Nilai |
|-----------|-------|
| **Host** | `127.0.0.1` (localhost) |
| **Database** | `sikha_db` |
| **Username** | `root` |
| **Password** | *(kosong — default XAMPP)* |
| **Charset** | `utf8mb4` |

### Struktur Tabel

#### `users` — Data Pengguna
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| id | VARCHAR(36) PK | UUID |
| username | VARCHAR(50) UNIQUE | Username login |
| password | VARCHAR(255) | Hash bcrypt (`password_hash()`) |
| nama | VARCHAR(100) | Nama lengkap |
| role | ENUM('ADMIN','GURU') | Peran pengguna |
| is_active | TINYINT(1) | Status aktif (1/0) |
| last_login | DATETIME | Waktu login terakhir |
| created_at | DATETIME | Waktu pembuatan |

#### `kelas` — Data Kelas
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| id | VARCHAR(36) PK | UUID |
| nama | VARCHAR(50) | Nama kelas (contoh: "Kelas 3B") |
| wali_kelas_id | VARCHAR(36) FK | ID guru wali kelas (ke users.id) |

#### `siswa` — Data Siswa
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| id | VARCHAR(36) PK | UUID |
| nama | VARCHAR(100) | Nama siswa |
| nis | VARCHAR(20) UNIQUE | Nomor Induk Siswa |
| jenis_kelamin | ENUM('LAKI_LAKI','PEREMPUAN') | Jenis kelamin |
| kelas_id | VARCHAR(36) FK | ID kelas (ke kelas.id) |
| qr_code | VARCHAR(255) UNIQUE | Kode QR unik untuk presensi |
| is_active | TINYINT(1) | Status aktif |

#### `presensi` — Data Presensi
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| id | VARCHAR(36) PK | UUID |
| siswa_id | VARCHAR(36) FK | ID siswa |
| kelas_id | VARCHAR(36) FK | ID kelas |
| tahun_ajaran_id | VARCHAR(36) FK | ID tahun ajaran |
| tanggal | DATE | Tanggal presensi |
| status | ENUM | HADIR, TERLAMBAT, IZIN, SAKIT, ALFA |
| keterangan | VARCHAR(255) NULL | Keterangan (untuk IZIN/SAKIT) |
| metode | VARCHAR(50) NULL | Metode: 'scan' atau 'manual' |
| jam_datang | TIME | Waktu scan/masuk |
| jam_pulang | TIME NULL | Waktu pulang |
| created_at | DATETIME | Waktu record dibuat |

#### `tahun_ajaran` — Tahun Ajaran
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| id | VARCHAR(36) PK | UUID |
| nama | VARCHAR(20) | Contoh: "2025/2026" |
| is_active | TINYINT(1) | Status aktif |

#### `jam_presensi` — Pengaturan Jam
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| id | INT PK | Auto increment |
| jam_masuk | TIME | Batas jam masuk |
| toleransi_menit | INT | Toleransi keterlambatan (menit) |
| is_active | TINYINT(1) | Status aktif |

#### `audit_log` — Log Aktivitas
| Kolom | Tipe | Keterangan |
|-------|------|------------|
| id | VARCHAR(36) PK | UUID |
| user_id | VARCHAR(36) FK | ID pengguna yang melakukan aksi |
| aksi | VARCHAR(100) | Jenis aksi (LOGIN, CRUD, dll) |
| deskripsi | TEXT | Deskripsi singkat |
| detail | JSON | Detail perubahan data |
| ip | VARCHAR(45) | Alamat IP |
| user_agent | TEXT | Browser/device info |
| created_at | DATETIME | Waktu kejadian |

---

## 5. Sistem Login & Autentikasi

### Alur Login

```
User buka /login.php
    ↓
Input username + password
    ↓
PHP cek ke database (prepared statement PDO)
    ↓
password_verify() cocokkan hash bcrypt
    ↓
Cek is_active = 1
    ↓
Simpan session: user_id, username, role, nama
    ↓
Update last_login timestamp
    ↓
Log aktivitas ke audit_log
    ↓
Redirect berdasarkan role:
  ├── ADMIN → /admin/dashboard.php
  └── GURU  → /guru/dashboard.php
```

### Role-Based Access Control

| Role | Akses | Halaman |
|------|-------|---------|
| **ADMIN** | Full access | Dashboard, Siswa, Kelas, Users, Tahun Ajaran, Jam Presensi, Generate QR, Scan QR, Laporan, Audit Log |
| **GURU** | Terbatas (kelas sendiri) | Dashboard, Scan QR, Presensi Manual, Laporan |

### Fungsi Otentikasi (functions.php)

| Fungsi | Kegunaan |
|--------|----------|
| `isLoggedIn()` | Cek apakah user sudah login (session ada) |
| `requireLogin()` | Redirect ke login jika belum login |
| `hasRole($role)` | Cek apakah user memiliki role tertentu |
| `requireRole($role)` | Gabungan requireLogin + hasRole, redirect jika gagal |
| `logAudit($pdo, $aksi, $deskripsi, $detail)` | Catat aktivitas ke audit_log |
| `escape($string)` | XSS protection (htmlspecialchars) |
| `jsonResponse($data, $status)` | Kirim response JSON untuk API |
| `redirect($url)` | Redirect halaman |

---

## 6. Fitur & Alur Kerja

### 6.1 Dashboard

#### Admin Dashboard (`admin/dashboard.php`)
- **4 Stat Cards**: Total Siswa, Total Kelas, Hadir Hari Ini, Total Guru
- **Line Chart**: Tren Kehadiran Mingguan (6 pekan terakhir, SVG inline)
- **Progress Bars**: Metode & Distribusi (Scan vs Manual, Laki-laki vs Perempuan)

#### Guru Dashboard (`guru/dashboard.php`)
- **2 Stat Cards**: Siswa Wali Kelas, Presensi Hari Ini
- **Akses Cepat**: Tombol ke Presensi Manual dan Scan QR
- **Tabel**: 10 Presensi Terakhir Hari Ini

---

### 6.2 Data Siswa (`admin/siswa.php`)

**Alur:**
1. Tabel menampilkan semua siswa (NIS, Nama, Kelas, Jenis Kelamin, Status)
2. Klik "Tambah Siswa" → Modal form (nama, NIS, jenis kelamin, kelas, password)
3. QR Code otomatis di-generate saat siswa dibuat (`uniqid()`)
4. Edit/Delete via dropdown menu di setiap baris
5. Data siswa otomatis aktif (`is_active = 1`)

---

### 6.3 Data Kelas (`admin/kelas.php`)

**Alur:**
1. Tabel menampilkan semua kelas (nama, jumlah siswa, wali kelas)
2. Klik "Tambah Kelas" → Modal form (nama kelas, pilih wali kelas)
3. Edit/Delete via dropdown menu
4. Wali kelas = guru yang role GURU di table users

---

### 6.4 Generate QR Code (`admin/generate_qr.php`)

**Alur:**
1. Pilih kelas dari dropdown
2. Klik "Tampilkan Siswa" → Daftar siswa muncul dalam card grid
3. Setiap card menampilkan QR Code unik (menggunakan QRCode.js)
4. Klik "Cetak QR" → Print dialog (hanya area QR yang dicetak)
5. QR Code berisi string unik yang merupakan `qr_code` siswa di database

---

### 6.5 Scan QR Presensi

#### Admin Scan (`admin/presensi_qr.php`) & Guru Scan (`guru/presensi_qr.php`)

**Alur:**
```
Klik "Buka Kamera"
    ↓
html5-qrcode inisialisasi kamera (facingMode: environment)
    ↓
User arahkan kamera ke QR Code siswa
    ↓
QR terdeteksi → onScanSuccess(decodedText)
    ↓
Kirim POST ke /api/presensi.php { qr_code: "..." }
    ↓
API cek siswa berdasarkan qr_code
    ↓
Cek apakah sudah presensi hari ini
    ↓
Jika belum:
  ├── Cek jam_presensi setting
  ├── Hitung batas toleransi (jam_masuk + toleransi_menit)
  ├── Jika scan sebelum batas → status = HADIR
  └── Jika scan sesudah batas → status = TERLAMBAT
    ↓
INSERT ke tabel presensi (metode = 'scan')
    ↓
Return JSON response → Toast notifikasi muncul
    ↓
Scan item ditambahkan ke daftar scan hari ini
```

**Perbedaan Admin vs Guru Scan:**
| Aspek | Admin | Guru |
|-------|-------|------|
| Role check | `requireRole('ADMIN')` | `requireRole('GURU')` |
| Data presensi | Semua siswa | Hanya siswa kelas sendiri |
| Filter | Tidak ada filter | Filter by `kelas_id` wali kelas |

---

### 6.6 Presensi Manual (`guru/presensi_manual.php`)

**Alur:**
```
Guru membuka halaman
    ↓
Tabel siswa kelas sendiri ditampilkan
  ├── Semua siswa default = HADIR (jika belum ada presensi hari ini)
  ├── Status sudah ada ditampilkan badge
    ↓
Guru pilih status per siswa (tombol pill):
  ├── Hadir → langsung siap simpan
  ├── Telat → langsung siap simpan
  ├── Izin → muncul kolom keterangan
  ├── Sakit → muncul kolom keterangan
  └── Alfa → langsung siap simpan
    ↓
Klik "Simpan Presensi" (tombol di atas)
    ↓
Semua data terkumpul dalam array JSON
    ↓
POST ke halaman yang sama (form submit)
    ↓
PHP loop insert/update per siswa:
  ├── Jika sudah ada presensi → UPDATE status + keterangan
  └── Jika belum ada → INSERT baru (metode = 'manual')
    ↓
Juga INSERT default HADIR untuk siswa yang belum ada presensi
    ↓
Redirect ke halaman yang sama (refresh)
```

---

### 6.7 Laporan (`admin/laporan.php` & `guru/laporan.php`)

**Alur:**
1. Filter: Kelas, Bulan, Tahun, Status
2. Tabel menampilkan data presensi (Tanggal, NIS, Nama, Kelas, Status, Jam Datang, Jam Pulang)
3. Klik "Export Excel" → Download file `.xls` (HTML table format)

---

### 6.8 Pengaturan Jam Presensi (`admin/jam_presensi.php`)

**Fungsi:**
- Atur jam masuk sekolah (contoh: 07:00)
- Atur toleransi keterlambatan (contoh: 15 menit)
- Hanya 1 setting yang aktif (`is_active = 1`)
- Digunakan oleh API scan QR untuk menentukan HADIR vs TERLAMBAT

---

### 6.9 Audit Log (`admin/audit_log.php`)

**Data yang dicatat:**
- Login berhasil/gagal
- CRUD operasi (siswa, kelas, users, dll)
- IP address dan user agent browser
- Waktu kejadian

---

### 6.10 Profil (`profil.php`)

- Lihat data profil pengguna
- Ganti password (input password lama → password baru → konfirmasi)
- Password di-hash dengan `password_hash()` (bcrypt)

---

## 7. UI/UX Design System

### 7.1 Color Palette

#### Primary Colors
| Nama | Hex | Kegunaan |
|------|-----|----------|
| Primary | `#2563EB` | Tombol utama, link, active states, chart line |
| Primary Light | `#4C98FD` | Hover states, progress bar gender |
| Primary Dark | `#1E3A8A` | Sidebar background, heading accents |
| Primary Pressed | `#1A3270` | Tombol primary saat ditekan |
| Primary 50 | `#EFF6FF` | Background stat cards, clock widget |
| Primary 100 | `#DBEAFE` | Chart grid lines, secondary-light |

#### Semantic Colors
| Nama | Hex | Kegunaan |
|------|-----|----------|
| Success | `#22C55E` | Status hadir, badge success, tombol cetak |
| Success BG | `#DCFCE7` | Background badge hadir, status hadir |
| Success Text | `#166534` | Teks di dalam badge hadir |
| Warning | `#F97316` | Status sakit/telat, badge warning |
| Warning BG | `#FFEDD5` | Background badge sakit |
| Warning Text | `#9A3412` | Teks di dalam badge warning |
| Error | `#EF4444` | Status alfa, badge error, tombol hapus |
| Error BG | `#FEE2E2` | Background badge alfa |
| Error Text | `#991B1B` | Teks di dalam badge error |
| Info | `#2563EB` | Status izin, badge info |
| Info BG | `#EFF6FF` | Background badge izin |
| Info Text | `#1E3A8A` | Teks di dalam badge info |

#### Neutral Colors
| Nama | Hex | Kegunaan |
|------|-----|----------|
| Text | `#1E293B` | Teks utama (heading, nama, label) |
| Text Secondary | `#64748B` | Teks sekunder (deskripsi, placeholder) |
| Text Muted | `#64748B` | Teks redup (tanggal, keterangan) |
| Border | `#E2E8F0` | Border card, table, input, tombol |
| Background | `#F1F5F9` | Background body utama |

#### Sidebar Colors
| Nama | Hex | Kegunaan |
|------|-----|----------|
| Sidebar BG | `#1E293B` | Background sidebar gelap |
| Sidebar Text | `#CBD5E1` | Teks menu sidebar |
| Sidebar Hover | `#334155` | Background saat hover menu |
| Sidebar Active | `#475569` | Background menu aktif |

### 7.2 Presensi Manual Colors (Pill Buttons)
| Status | Border | Text (inactive) | Background (active) | Shadow |
|--------|--------|-----------------|---------------------|--------|
| Hadir | `#22C55E` | `#16A34A` | `#22C55E` + white text | `rgba(34,197,94,0.3)` |
| Izin | `#3B82F6` | `#2563EB` | `#3B82F6` + white text | `rgba(59,130,246,0.3)` |
| Sakit | `#F97316` | `#EA580C` | `#F97316` + white text | `rgba(249,115,22,0.3)` |
| Telat | `#EAB308` | `#CA8A04` | `#EAB308` + white text | `rgba(234,179,8,0.3)` |
| Alfa | `#EF4444` | `#DC2626` | `#EF4444` + white text | `rgba(239,68,68,0.3)` |

### 7.3 Typography

| Elemen | Font | Size | Weight |
|--------|------|------|--------|
| Heading (h1) | Plus Jakarta Sans | 1.5rem (24px) | 700 |
| Heading (h2) | Plus Jakarta Sans | 1.25rem (20px) | 600 |
| Body text | Inter | 1rem (16px) | 400 |
| Card title | Inter | 0.875rem (14px) | 700 |
| Stat label | Inter | 0.75rem (12px) | 500 |
| Stat value | Plus Jakarta Sans | 1.5rem (24px) | 800 |
| Badge | Inter | 0.75rem (12px) | 600 |
| Button | Inter | 0.875rem (14px) | 600 |
| Table header | Inter | 0.75rem (12px) | 700, uppercase |
| Table body | Inter | 0.875rem (14px) | 400-600 |
| Clock time | JetBrains Mono | 0.8125rem (13px) | 700 |

### 7.4 Layout Structure

```
┌──────────────────────────────────────────────────┐
│                    BODY                           │
│  ┌────────────┬────────────────────────────────┐  │
│  │            │         TOPBAR (56px)           │  │
│  │            │  [≡] [Page Title]  [🕐 Clock] [Avatar ▾] │
│  │            ├────────────────────────────────┤  │
│  │  SIDEBAR   │                                │  │
│  │  (260px)   │       CONTENT AREA             │  │
│  │            │       (scrollable)             │  │
│  │  ┌──────┐  │                                │  │
│  │  │Logo  │  │  ┌──────────────────────────┐  │  │
│  │  │SIKHA │  │  │  Page Header             │  │  │
│  │  └──────┘  │  │  Title + Description      │  │  │
│  │            │  └──────────────────────────┘  │  │
│  │  Menu:     │                                │  │
│  │  • Dash    │  ┌──────────────────────────┐  │  │
│  │  • Siswa   │  │  Cards / Tables / Forms  │  │  │
│  │  • Kelas   │  │  ...                     │  │  │
│  │  • ...     │  │                          │  │  │
│  │            │  └──────────────────────────┘  │  │
│  │            │                                │  │
│  │  ┌──────┐  │                                │  │
│  │  │User  │  │                                │  │
│  │  │Profile│  │                                │  │
│  │  └──────┘  │                                │  │
│  └────────────┴────────────────────────────────┘  │
└──────────────────────────────────────────────────┘
```

| Komponen | Lebar/Tinggi | Posisi |
|----------|-------------|--------|
| Sidebar | 260px × 100dvh | Fixed kiri |
| Topbar | 100% × 56px | Fixed atas (di sebelah sidebar) |
| Content Area | Sisa ruang | Scrollable |
| Sidebar (mobile) | 260px | Overlay, toggle via hamburger |
| Sidebar (collapsed) | 64px | Mode icon-only |

### 7.5 Komponen UI

#### Card
| Property | Nilai |
|----------|-------|
| Background | `#FFFFFF` |
| Border radius | `0.75rem` (12px) |
| Border | `1px solid #E2E8F0` |
| Shadow | `0 1px 3px rgba(0,0,0,0.05)` |
| Padding | `1rem` (card-body) |

#### Tombol (Button)
| Variasi | Background | Teks | Border Radius |
|---------|-----------|------|---------------|
| Primary | `#2563EB` | White | `0.625rem` (10px) |
| Success | `#22C55E` | White | `0.625rem` (10px) |
| Danger | `#EF4444` | White | `0.625rem` (10px) |
| Ghost | Transparent | `#64748B` | `0.625rem` (10px) |
| Height | `2.5rem` (40px) | — | — |
| Padding-x | `1rem` (16px) | — | — |
| Font size | `0.875rem` (14px) | — | — |

#### Input
| Property | Nilai |
|----------|-------|
| Height | `2.5rem` (40px) |
| Border | `1.5px solid #E2E8F0` |
| Border radius | `0.5rem` (8px) |
| Padding | `0 0.75rem` |
| Focus border | `#2563EB` |
| Focus shadow | `0 0 0 3px rgba(37,99,235,0.1)` |

#### Badge
| Variasi | Background | Teks |
|---------|-----------|------|
| Success | `#DCFCE7` | `#166534` |
| Warning | `#FFEDD5` | `#9A3412` |
| Error | `#FEE2E2` | `#991B1B` |
| Info | `#EFF6FF` | `#1E3A8A` |
| Secondary | `#F1F5F9` | `#64748B` |
| Border radius | `9999px` (pill) | — |
| Padding | `0.25rem 0.75rem` | — |

#### Table
| Property | Nilai |
|----------|-------|
| Header bg | `#F8FAFC` |
| Header text | `#64748B`, uppercase, 0.75rem, weight 700 |
| Cell padding | `0.875rem 1rem` |
| Border bottom | `1px solid #E2E8F0` |
| Row hover | `#F8FAFC` |

#### Topbar
| Property | Nilai |
|----------|-------|
| Background | White |
| Height | 56px |
| Border bottom | `1px solid #E2E8F0` |
| Position | Sticky top |

#### Live Clock Widget
| Property | Nilai |
|----------|-------|
| Background | `#EFF6FF` (primary-50) |
| Text color | `#2563EB` (primary) |
| Border radius | `0.625rem` (10px) |
| Time font | JetBrains Mono, 0.8125rem, 700 |
| Date font | Inter, 0.625rem, 500 |
| Update interval | 1000ms (setiap detik) |

---

## 8. Animasi

| Nama | Efek | Kegunaan |
|------|------|----------|
| `animate-in` | `fadeIn` (opacity 0→1 + translateY 10px→0) | Entry animasi card, table rows |
| `animate-in-delay-1` | Delay 100ms | Stat cards |
| `animate-in-delay-2` | Delay 200ms | Chart cards |
| `animate-in-delay-3` | Delay 300ms | Section berikutnya |
| Row stagger | Delay per baris (30ms, max 300ms) | Tabel siswa, presensi |
| Button active | `scale(0.95)` | Tombol pill saat diklik |
| Toast | `fadeSlideUp` + `slideRight` | Notifikasi sukses/error |
| Fade highlight | Background primary-100 → transparent | Scan item baru |

---

## 9. Responsive Breakpoints

| Breakpoint | Lebar | Perilaku |
|------------|-------|----------|
| Mobile | < 639px | Sidebar overlay, clock teks tersembunyi, grid 1 kolom |
| Tablet | 640-991px | Sidebar overlay, grid 2 kolom |
| Desktop | ≥ 992px | Sidebar tetap (260px), grid multi kolom |
| XL Desktop | ≥ 1200px | Full layout |

---

## 10. Keamanan

| Aspek | Implementasi |
|-------|-------------|
| **Password Storage** | Bcrypt via `password_hash()` / `password_verify()` |
| **SQL Injection** | PDO prepared statements (tanpa string concatenation) |
| **XSS Protection** | `htmlspecialchars()` via fungsi `escape()` |
| **CSRF** | Session-based auth check di setiap halaman |
| **Role Enforcement** | `requireRole()` function di setiap halaman |
| **Access Control** | Guru hanya lihat data kelas sendiri (filter by `wali_kelas_id`) |
| **Audit Trail** | Semua aktivitas login + CRUD dicatat di `audit_log` |

---

## 11. API Endpoint

### POST `/api/presensi.php`

**Request Body (JSON):**
```json
{
    "qr_code": "string — kode QR siswa"
}
```

**Response Success (200):**
```json
{
    "success": true,
    "message": "Presensi datang berhasil dicatat untuk Nama Siswa",
    "data": {
        "nama": "Nama Siswa",
        "type": "DATANG",
        "status": "HADIR" | "TERLAMBAT"
    }
}
```

**Response Error:**
```json
{
    "success": false,
    "message": "pesan error"
}
```

**Status Codes:**
| Code | Kondisi |
|------|---------|
| 200 | Presensi berhasil |
| 400 | QR tidak valid / sudah presensi hari ini |
| 404 | Siswa tidak ditemukan |
| 405 | Method bukan POST |

---

## 12. Statistik Default

Jika belum ada data presensi, dashboard menggunakan fallback:

| Chart | Data Default |
|-------|-------------|
| Tren Kehadiran | Pekan 1: 86%, Pekan 2: 82%, Pekan 3: 90%, Pekan 4: 87%, Pekan 5: 93%, Pekan 6: 91% |
| Metode | Scan: 0%, Manual: 100% (default) |
| Gender | Laki-laki + Perempuan (dihitung dari database) |

---

## 13. Dependency Eksternal

| Library | Versi | CDN URL | Kegunaan |
|---------|-------|---------|----------|
| html5-qrcode | 2.3.8 | `unpkg.com/html5-qrcode@2.3.8/html5-qrcode.min.js` | Scanner QR via kamera |
| QRCode.js | 1.0.0 | `cdnjs.cloudflare.com/ajax/libs/qrcodejs/1.0.0/qrcode.min.js` | Generate QR code untuk cetak |
| Bootstrap Icons | 1.11.1 | `cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css` | Ikon-ikon UI |
| Inter | — | Google Fonts | Font body |
| Plus Jakarta Sans | — | Google Fonts | Font heading |
| JetBrains Mono | — | Google Fonts (via style.css) | Clock time font |

---

## 14. Cheat Sheet untuk Laporan

### Judul yang Cocok
- "Pengembangan Sistem Kehadiran Siswa Berbasis Web (SIKHA) di SDI Khadijah Sukorejo"
- "Implementasi Sistem Presensi Digital Menggunakan QR Code pada Sekolah Dasar"
- "Rancang Bangun Aplikasi Sistem Kehadiran Siswa dengan Metode Waterfall"

### Poin Penting untuk Laporan
1. **Masalah**: Absensi manual (buku) lambat, rawan manipulasi, sulit dilaporkan
2. **Solusi**: Sistem digital dengan 2 metode presensi (QR scan + manual)
3. **Teknologi**: PHP native + MySQL + HTML5 + CSS3 + JavaScript vanilla
4. **Fitur Utama**: Login RBAC, CRUD data, QR scan, presensi manual, laporan, audit log
5. **Hasil**: Proses presensi lebih cepat, data real-time, laporan otomatis

### Model Perancangan
- **Metodologi**: Waterfall / SDLC
- **Model Database**: ERD (Entity Relationship Diagram)
- **Model Antarmuka**: Mockup UI / Wireframe
- **Bahasa Pemrograman**: PHP 7.4+ (backend), JavaScript ES6+ (frontend)

---

*Terakhir diperbarui: 10 Juli 2026*
*Dokumentasi untuk project SIKHA — SDI Khadijah Sukorejo*
