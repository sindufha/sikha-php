# HANDOFF.md — SIKHA (Sistem Kehadiran Siswa)

## Project Overview

SIKHA adalah sistem informasi kehadiran siswa berbasis QR Code untuk **SDI Khadijah Sukorejo**. Sistem ini dibangun dengan **PHP native** (tanpa framework) menggunakan **MySQL/PDO** sebagai database, dijalankan via **XAMPP** di `localhost`.

**Base URL:** `http://localhost/sikha-new/`

---

## Tech Stack

| Komponen | Teknologi |
|----------|-----------|
| Backend | PHP 8.x native (no framework) |
| Database | MySQL (PDO), database name: `sikha_db` |
| Server | XAMPP (Apache + MySQL) |
| Frontend | Custom CSS (Tailwind-inspired utility classes) |
| QR Library | html5-qrcode v2.3.8 (scanner), qrcodejs v1.0.0 (generator) |
| Auth | Session-based (`$_SESSION`) |

---

## Database Schema

**Penting:** Kolom database tidak sesuai dengan file `database.sql` di repo. Berikut kolom yang benar (sudah di-fix):

| Table | Kolom Penting (benar) | Bukan |
|-------|----------------------|-------|
| `kelas` | `nama` | ~~nama_kelas~~ |
| `kelas` | `wali_kelas_id` | ~~wali~~ |
| `users` | `nama` | ~~nama_lengkap~~ |
| `tahun_ajaran` | `tahun` | ~~tahun_ajaran~~ |
| `jam_presensi` | `toleransi_menit` | ~~toleransi_terlambat~~ |

### Main Tables
- **users** — id, email, password, nama, role (ADMIN/GURU), is_active
- **siswa** — id, nis, nama, kelas_id, qr_code, jenis_kelamin (LAKI_LAKI/PEREMPUAN), tempat_lahir, tanggal_lahir, alamat, is_active
- **kelas** — id, nama, wali_kelas_id (FK → users.id)
- **presensi** — id, siswa_id, kelas_id, tahun_ajaran_id, tanggal, status (HADIR/TERLAMBAT/IZIN/SAKIT/ALFA), jam_datang, jam_pulang, created_at
- **tahun_ajaran** — id, tahun, is_active
- **jam_presensi** — id, jam_masuk, jam_pulang, toleransi_menit, is_active
- **audit_log** — id, user_id, action, detail, created_at

---

## User Roles

### ADMIN
Full access. Menu:
- **Dashboard** — ringkasan kehadiran hari ini
- **Data Siswa** — CRUD siswa + generate QR
- **Data Kelas** — CRUD kelas + assign wali kelas
- **Tahun Ajaran** — CRUD tahun ajaran (1 aktif)
- **Jam Presensi** — set jam masuk/pulang + toleransi terlambat
- **Scan QR** — halaman scanner dengan riwayat scan hari ini
- **Generate QR** — cetak QR Code per kelas
- **Laporan** — laporan presensi per bulan/tahun per kelas
- **Audit Log** — log semua aktivitas user

### GURU (Wali Kelas)
Akses terbatas. Menu:
- **Dashboard** — ringkasan kehadiran kelas yang diwali
- **Presensi Manual** — input presensi manual per siswa
- **Laporan** — laporan presensi kelas yang diwali

### SISWA
Akses halaman publik:
- **Cari QR Code** (`/siswa/qr.php?nis=xxx`) — tampilkan QR berdasarkan NIS

---

## File Structure

```
sikha-new/
├── config/
│   └── database.php          # Koneksi PDO ke sikha_db
├── includes/
│   ├── header.php             # HTML head + navbar + sidebar
│   ├── footer.php             # Closing HTML + scripts
│   ├── sidebar.php            # Navigasi sidebar berdasarkan role
│   └── functions.php          # Helper: requireRole(), logAudit(), redirect(), escape(), jsonResponse()
├── assets/
│   ├── css/style.css          # Custom CSS (utility-first, Tailwind-inspired)
│   ├── js/script.js           # JavaScript umum
│   └── favicon.svg            # Ikon favicon
├── admin/
│   ├── dashboard.php          # Dashboard admin
│   ├── siswa.php              # CRUD siswa + modal edit
│   ├── kelas.php              # CRUD kelas
│   ├── tahun_ajaran.php       # CRUD tahun ajaran
│   ├── jam_presensi.php       # Pengaturan jam presensi
│   ├── presensi_qr.php        # Scanner QR Code (dua kolom: scanner + riwayat)
│   ├── generate_qr.php        # Generate/cetak QR per kelas
│   ├── laporan.php            # Laporan presensi admin
│   ├── users.php              # CRUD users (admin only)
│   └── audit_log.php          # Log aktivitas
├── guru/
│   ├── dashboard.php          # Dashboard guru wali kelas
│   ├── presensi_manual.php    # Input presensi manual
│   └── laporan.php            # Laporan presensi kelas
├── api/
│   └── presensi.php           # JSON API untuk scan QR (POST {qr_code})
├── siswa/
│   └── qr.php                 # Halaman cari & tampilkan QR siswa
├── login.php                  # Halaman login
├── logout.php                 # Logout handler
├── profil.php                 # Profil user login
├── index.php                  # Root — redirect ke dashboard
└── database.sql               # Schema SQL (referensi, TIDAK 100% match DB asli)
```

---

## Key Features

### 1. QR Code Attendance
- Siswa punya QR Code unik (`qr_code` field di tabel `siswa`, generated via `bin2hex(random_bytes(10))`)
- Admin scan QR via kamera → API cek siswa → catat presensi
- Status otomatis: HADIR atau TERLAMBAT (berdasarkan `jam_presensi.toleransi_menit`)
- Duplikat scan per hari ditolak

### 2. Scanner Page (`admin/presensi_qr.php`)
- Layout dua kolom: scanner (kiri) + riwayat scan hari ini (kanan)
- Menggunakan `Html5Qrcode` (bukan `Html5QrcodeScanner`) untuk akses kamera langsung
- Tombol "Buka Kamera" dan "Stop Kamera"
- Toast notifikasi (sukses/gagal)
- Live update riwayat scan + counter badge

### 3. Modal Siswa (Scrollable)
- Modal edit siswa menggunakan flex column layout
- `max-height: 90vh` + `overflow-y: auto` di modal body
- Footer (Batal/Simpan) tetap di bawah, tidak ikut scroll

---

## Common Fixes Applied

### SQL Column Name Mismatch
Semua query PHP sudah di-fix untuk match database asli:
- `k.nama_kelas` → `k.nama as nama_kelas`
- `nama_kelas` → `nama` (di INSERT/UPDATE)
- `wali_kelas` → `wali_kelas_id`
- `toleransi_terlambat` → `toleransi_menit`
- `tahun_ajaran` → `tahun`

### Files yang sudah di-fix:
- `admin/siswa.php`
- `admin/kelas.php`
- `admin/tahun_ajaran.php`
- `admin/jam_presensi.php`
- `admin/generate_qr.php`
- `admin/laporan.php`
- `guru/dashboard.php`
- `guru/presensi_manual.php`
- `guru/laporan.php`
- `api/presensi.php`
- `siswa/qr.php`

---

## Running Locally

1. Start XAMPP (Apache + MySQL)
2. Import `sikha_db` database ke MySQL
3. Pastikan config di `config/database.php` benar (host: localhost, db: sikha_db)
4. Akses: `http://localhost/sikha-new/`
5. Login default: admin atau guru (cek tabel `users`)

---

## MCP Servers (Claude Code Config)

Di `~/.claude/settings.json` sudah terkonfigurasi:
- **magic** — @21st-dev/magic (UI components)
- **firecrawl-mcp** — Firecrawl web scraping (API key sudah di-update)
- **playwright** — Browser automation
- **figma** — Figma design integration

---

## Notes

- Semua primary key menggunakan UUID
- Role-based access control via `requireRole('ADMIN')` / `requireRole('GURU')`
- Audit logging via `logAudit()` untuk semua operasi CRUD
- CSS menggunakan custom utility classes (bukan Tailwind CDN)
- Frontend vanilla JavaScript, no React/Vue/etc.
