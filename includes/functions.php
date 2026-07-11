<?php
session_start();

function isLoggedIn() {
    return isset($_SESSION['user_id']);
}

function redirect($url) {
    header("Location: $url");
    exit();
}

function requireLogin() {
    if (!isLoggedIn()) {
        redirect('/sikha-new/login.php');
    }
}

function hasRole($role) {
    return isset($_SESSION['role']) && $_SESSION['role'] === $role;
}

function requireRole($role) {
    requireLogin();
    if (!hasRole($role)) {
        if (hasRole('ADMIN')) redirect('/sikha-new/admin/dashboard.php');
        if (hasRole('GURU')) redirect('/sikha-new/guru/dashboard.php');
        redirect('/sikha-new/login.php');
    }
}

function logAudit($pdo, $aksi, $deskripsi = null, $detail = null) {
    $userId = $_SESSION['user_id'] ?? null;
    $ip = $_SERVER['REMOTE_ADDR'] ?? null;
    $userAgent = $_SERVER['HTTP_USER_AGENT'] ?? null;
    $detailJson = $detail ? json_encode($detail) : null;
    
    $stmt = $pdo->prepare("INSERT INTO audit_log (id, user_id, aksi, deskripsi, detail, ip, user_agent) VALUES (UUID(), ?, ?, ?, ?, ?, ?)");
    $stmt->execute([$userId, $aksi, $deskripsi, $detailJson, $ip, $userAgent]);
}

function jsonResponse($data, $status = 200) {
    http_response_code($status);
    header('Content-Type: application/json');
    echo json_encode($data);
    exit();
}

function escape($string) {
    return htmlspecialchars($string, ENT_QUOTES, 'UTF-8');
}
?>
