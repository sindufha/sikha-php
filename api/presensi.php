<?php
require_once '../config/database.php';
require_once '../includes/functions.php';

header('Content-Type: application/json');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    jsonResponse(['success' => false, 'message' => 'Method not allowed'], 405);
}

$input = json_decode(file_get_contents('php://input'), true);
$qr_code = $input['qr_code'] ?? '';

if (empty($qr_code)) {
    jsonResponse(['success' => false, 'message' => 'QR Code tidak valid'], 400);
}

// Cari siswa berdasarkan QR
$stmt = $pdo->prepare("
    SELECT s.id, s.nama, s.nis, s.jenis_kelamin, s.kelas_id, k.nama as nama_kelas
    FROM siswa s
    JOIN kelas k ON s.kelas_id = k.id
    WHERE s.qr_code = ? AND s.is_active = 1
    LIMIT 1
");
$stmt->execute([$qr_code]);
$siswa = $stmt->fetch();

if (!$siswa) {
    jsonResponse(['success' => false, 'message' => 'Siswa tidak ditemukan atau tidak aktif'], 404);
}

// Cari tahun ajaran aktif
$stmt = $pdo->query("SELECT id FROM tahun_ajaran WHERE is_active = 1 LIMIT 1");
$tahun_ajaran = $stmt->fetch();
$tahun_ajaran_id = $tahun_ajaran ? $tahun_ajaran['id'] : null;

$today = date('Y-m-d');
$nowTime = date('Y-m-d H:i:s');

// Cek apakah sudah presensi hari ini
$stmt = $pdo->prepare("SELECT id FROM presensi WHERE siswa_id = ? AND tanggal = ? LIMIT 1");
$stmt->execute([$siswa['id'], $today]);
$presensi = $stmt->fetch();

if ($presensi) {
    jsonResponse(['success' => false, 'message' => $siswa['nama'] . ' sudah melakukan presensi hari ini.'], 400);
} else {
    // Presensi datang
    // Tentukan status berdasarkan jam_presensi
    $stmt = $pdo->query("SELECT jam_masuk, toleransi_menit FROM jam_presensi WHERE is_active = 1 LIMIT 1");
    $jamSetting = $stmt->fetch();

    $status = 'HADIR';
    if ($jamSetting) {
        $batasWaktu = strtotime($today . ' ' . $jamSetting['jam_masuk']);
        $batasToleransi = $batasWaktu + ($jamSetting['toleransi_menit'] * 60);
        $waktuHadir = strtotime($nowTime);

        if ($waktuHadir > $batasToleransi) {
            $status = 'TERLAMBAT';
        }
    }

    $stmt = $pdo->prepare("INSERT INTO presensi (id, siswa_id, kelas_id, tahun_ajaran_id, tanggal, status, metode, jam_datang) VALUES (UUID(), ?, ?, ?, ?, ?, 'QR', ?)");
    $stmt->execute([$siswa['id'], $siswa['kelas_id'], $tahun_ajaran_id, $today, $status, $nowTime]);
    
    jsonResponse([
        'success' => true,
        'message' => 'Presensi datang berhasil dicatat untuk ' . $siswa['nama'],
        'data' => [
            'nama' => $siswa['nama'],
            'nis' => $siswa['nis'],
            'nama_kelas' => $siswa['nama_kelas'],
            'jenis_kelamin' => $siswa['jenis_kelamin'],
            'type' => 'DATANG',
            'status' => $status
        ]
    ]);
}
