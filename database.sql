CREATE DATABASE IF NOT EXISTS sikha_new;
USE sikha_new;

CREATE TABLE users (
    id VARCHAR(191) PRIMARY KEY,
    username VARCHAR(191) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('ADMIN', 'GURU') NOT NULL,
    nama_lengkap VARCHAR(255) NOT NULL,
    is_active TINYINT(1) DEFAULT 1,
    last_login DATETIME NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE tahun_ajaran (
    id VARCHAR(191) PRIMARY KEY,
    tahun_ajaran VARCHAR(50) NOT NULL,
    semester ENUM('GANJIL', 'GENAP') NOT NULL,
    is_active TINYINT(1) DEFAULT 0,
    tanggal_mulai DATE NOT NULL,
    tanggal_selesai DATE NOT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE(tahun_ajaran, semester)
);

CREATE TABLE kelas (
    id VARCHAR(191) PRIMARY KEY,
    nama_kelas VARCHAR(191) NOT NULL,
    wali_kelas VARCHAR(191) NULL,
    tahun_ajaran_id VARCHAR(191) NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (wali_kelas) REFERENCES users(id) ON DELETE SET NULL,
    FOREIGN KEY (tahun_ajaran_id) REFERENCES tahun_ajaran(id) ON DELETE CASCADE,
    UNIQUE(nama_kelas, tahun_ajaran_id)
);

CREATE TABLE siswa (
    id VARCHAR(191) PRIMARY KEY,
    nis VARCHAR(50) UNIQUE NOT NULL,
    nama VARCHAR(255) NOT NULL,
    kelas_id VARCHAR(191) NOT NULL,
    qr_code VARCHAR(191) UNIQUE NOT NULL,
    alamat TEXT NULL,
    is_active TINYINT(1) DEFAULT 1,
    jenis_kelamin ENUM('LAKI_LAKI', 'PEREMPUAN') NULL,
    nama_ayah VARCHAR(255) NULL,
    nama_ibu VARCHAR(255) NULL,
    nisn VARCHAR(50) NULL,
    no_telp_ortu VARCHAR(50) NULL,
    tahun_masuk INT NULL,
    tanggal_lahir DATE NULL,
    tempat_lahir VARCHAR(100) NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (kelas_id) REFERENCES kelas(id) ON DELETE RESTRICT
);

CREATE TABLE jam_presensi (
    id VARCHAR(191) PRIMARY KEY,
    jam_masuk VARCHAR(5) NOT NULL,
    toleransi_menit INT DEFAULT 15,
    jam_pulang VARCHAR(5) NULL,
    is_active TINYINT(1) DEFAULT 1,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE presensi (
    id VARCHAR(191) PRIMARY KEY,
    siswa_id VARCHAR(191) NOT NULL,
    kelas_id VARCHAR(191) NULL,
    tahun_ajaran_id VARCHAR(191) NULL,
    tanggal DATE NOT NULL,
    status ENUM('HADIR', 'IZIN', 'SAKIT', 'ALFA', 'TERLAMBAT') NOT NULL,
    jam_datang DATETIME NULL,
    jam_pulang DATETIME NULL,
    keterangan TEXT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (siswa_id) REFERENCES siswa(id) ON DELETE CASCADE,
    FOREIGN KEY (kelas_id) REFERENCES kelas(id) ON DELETE SET NULL,
    FOREIGN KEY (tahun_ajaran_id) REFERENCES tahun_ajaran(id) ON DELETE SET NULL,
    UNIQUE(siswa_id, tanggal)
);

CREATE TABLE audit_logs (
    id VARCHAR(191) PRIMARY KEY,
    user_id VARCHAR(191) NULL,
    aksi VARCHAR(100) NOT NULL,
    deskripsi TEXT NULL,
    detail JSON NULL,
    ip VARCHAR(45) NULL,
    user_agent TEXT NULL,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- ===== SEEDER =====

-- Admin
INSERT INTO users (id, username, password, role, nama_lengkap, is_active) VALUES
('admin001', 'admin', '$2y$10$NMp2oyAAWrf1sdLa2Gq3peM9IkVEYSeb0nrz1/3OoV0be1KG9anRK', 'ADMIN', 'Administrator', 1),
('guru001', 'guru1', '$2y$10$5723fwV3eEBPjufE8tFk9OqhiMLEtZeS1tYYUyrWCOd/y4c2kDQOi', 'GURU', 'Siti Aminah, S.Pd.', 1),
('guru002', 'guru2', '$2y$10$AiPeoSBBSNjp8efcR7a34.vTeyDr7KTAasVuXrnIw3mdp9RIwr4pe', 'GURU', 'Ahmad Fauzi, S.Pd.', 1),
('guru003', 'guru3', '$2y$10$DPlWowBD94FFUBklcWSMa.ATzdoFPIh6Q7atzbMzz1Kwgw2BzBVhe', 'GURU', 'Dewi Sartika, S.Pd.', 1),
('guru004', 'guru4', '$2y$10$NMp2oyAAWrf1sdLa2Gq3peM9IkVEYSeb0nrz1/3OoV0be1KG9anRK', 'GURU', 'Budi Hartono, S.Pd.', 1);

-- Tahun Ajaran
INSERT INTO tahun_ajaran (id, tahun_ajaran, semester, is_active, tanggal_mulai, tanggal_selesai) VALUES
('ta001', '2025/2026', 'GENAP', 1, '2026-01-06', '2026-06-20');

-- Jam Presensi
INSERT INTO jam_presensi (id, jam_masuk, toleransi_menit, jam_pulang, is_active) VALUES
('jp001', '07:00', 15, '13:00', 1);

-- Kelas
INSERT INTO kelas (id, nama_kelas, wali_kelas, tahun_ajaran_id) VALUES
('kls001', '1A', 'guru001', 'ta001'),
('kls002', '1B', 'guru002', 'ta001'),
('kls003', '2A', 'guru003', 'ta001');

-- Siswa (10 per kelas)
INSERT INTO siswa (id, nis, nama, kelas_id, qr_code, jenis_kelamin, nisn, nama_ayah, nama_ibu) VALUES
('sis001', '2026001', 'Ahmad Rizki', 'kls001', HEX(RANDOM_BYTES(10)), 'LAKI_LAKI', '0123456789', 'Hadi', 'Sari'),
('sis002', '2026002', 'Bunga Citra', 'kls001', HEX(RANDOM_BYTES(10)), 'PEREMPUAN', '0123456790', 'Joko', 'Dewi'),
('sis003', '2026003', 'Cahya Ningsih', 'kls001', HEX(RANDOM_BYTES(10)), 'PEREMPUAN', '0123456791', 'Bambang', 'Rini'),
('sis004', '2026004', 'Dimas Ardiansyah', 'kls001', HEX(RANDOM_BYTES(10)), 'LAKI_LAKI', '0123456792', 'Agus', 'Tuti'),
('sis005', '2026005', 'Eka Putri', 'kls001', HEX(RANDOM_BYTES(10)), 'PEREMPUAN', '0123456793', 'Dodi', 'Maya'),
('sis006', '2026006', 'Fajar Ramadhan', 'kls002', HEX(RANDOM_BYTES(10)), 'LAKI_LAKI', '0123456794', 'Eko', 'Lina'),
('sis007', '2026007', 'Gita Lestari', 'kls002', HEX(RANDOM_BYTES(10)), 'PEREMPUAN', '0123456795', 'Ferry', 'Nina'),
('sis008', '2026008', 'Hendra Gunawan', 'kls002', HEX(RANDOM_BYTES(10)), 'LAKI_LAKI', '0123456796', 'Gunawan', 'Fitri'),
('sis009', '2026009', 'Indah Permata', 'kls002', HEX(RANDOM_BYTES(10)), 'PEREMPUAN', '0123456797', 'Herman', 'Rina'),
('sis010', '2026010', 'Joko Susilo', 'kls002', HEX(RANDOM_BYTES(10)), 'LAKI_LAKI', '0123456798', 'Irfan', 'Yanti'),
('sis011', '2026011', 'Kartika Sari', 'kls003', HEX(RANDOM_BYTES(10)), 'PEREMPUAN', '0123456799', 'Junaedi', 'Sari'),
('sis012', '2026012', 'Lukman Hakim', 'kls003', HEX(RANDOM_BYTES(10)), 'LAKI_LAKI', '0123456800', 'Kadir', 'Wati'),
('sis013', '2026013', 'Mega Puspita', 'kls003', HEX(RANDOM_BYTES(10)), 'PEREMPUAN', '0123456801', 'Lamhot', 'Susanti'),
('sis014', '2026014', 'Nanda Pratama', 'kls003', HEX(RANDOM_BYTES(10)), 'LAKI_LAKI', '0123456802', 'Mulyadi', 'Ani'),
('sis015', '2026015', 'Oktavia Dewi', 'kls003', HEX(RANDOM_BYTES(10)), 'PEREMPUAN', '0123456803', 'Nurdin', 'Rita');
