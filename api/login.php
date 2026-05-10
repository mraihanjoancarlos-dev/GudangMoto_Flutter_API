<?php
// htdocs/kasir/api/login.php
require_once 'config.php';

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    response('error', 'Method not allowed');
}

$body = json_decode(file_get_contents('php://input'), true);

$username = sanitize($body['username'] ?? '');
$password = $body['password'] ?? '';

if (empty($username) || empty($password)) {
    response('error', 'Username dan password wajib diisi');
}

$stmt = $pdo->prepare("SELECT * FROM admin WHERE username = ?");
$stmt->execute([$username]);
$admin = $stmt->fetch();

// Cek password (plain text sesuai sistem web lama, atau bcrypt)
$valid = false;
if ($admin) {
    // Coba bcrypt dulu
    if (password_verify($password, $admin['password'])) {
        $valid = true;
    }
    // Fallback plain text (untuk password admin123 yang disimpan plain)
    elseif ($password === $admin['password']) {
        $valid = true;
    }
}

if (!$valid) {
    response('error', 'Username atau password salah');
}

// Buat token sederhana
$token = base64_encode($admin['id'] . ':' . $admin['username'] . ':' . time());

response('success', 'Login berhasil', [
    'token'    => $token,
    'admin_id' => $admin['id'],
    'username' => $admin['username'],
    'nama'     => $admin['nama_lengkap'],
    'email'    => $admin['email'],
]);
