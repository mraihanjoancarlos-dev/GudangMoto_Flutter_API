<?php
// ============================================
// API CONFIG - GudangMoto
// Letakkan file ini di htdocs/kasir/api/
// ============================================

header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type, Authorization');

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

define('DB_HOST', 'localhost');
define('DB_USER', 'root');
define('DB_PASS', '');
define('DB_NAME', 'gudang_motor');

try {
    $pdo = new PDO(
        "mysql:host=" . DB_HOST . ";dbname=" . DB_NAME . ";charset=utf8mb4",
        DB_USER,
        DB_PASS,
        [
            PDO::ATTR_ERRMODE            => PDO::ERRMODE_EXCEPTION,
            PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC,
            PDO::ATTR_EMULATE_PREPARES   => false,
        ]
    );
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'Koneksi database gagal: ' . $e->getMessage()]);
    exit();
}

function response($status, $message, $data = null) {
    $res = ['status' => $status, 'message' => $message];
    if ($data !== null) $res['data'] = $data;
    echo json_encode($res);
    exit();
}

function sanitize($input) {
    return htmlspecialchars(strip_tags(trim($input)));
}

function generateNoTransaksi($prefix) {
    return $prefix . '-' . date('Ymd') . '-' . str_pad(rand(1, 999), 3, '0', STR_PAD_LEFT);
}

// Simple token auth - cek header Authorization
function checkAuth() {
    $headers = getallheaders();
    $token   = $headers['Authorization'] ?? '';
    // Token sederhana: base64(admin_id:username)
    // Di production, gunakan JWT
    if (empty($token)) {
        http_response_code(401);
        response('error', 'Unauthorized');
    }
}
