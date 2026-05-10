<?php
// htdocs/kasir/api/kategori.php
require_once 'config.php';
checkAuth();

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $data = $pdo->query("SELECT * FROM kategori ORDER BY nama_kategori ASC")->fetchAll();
    response('success', 'OK', $data);
}

if ($method === 'POST') {
    $body = json_decode(file_get_contents('php://input'), true);
    $nama = sanitize($body['nama_kategori'] ?? '');
    $deskripsi = sanitize($body['deskripsi'] ?? '');

    if (!$nama) response('error', 'Nama kategori wajib diisi');

    $stmt = $pdo->prepare("INSERT INTO kategori (nama_kategori, deskripsi) VALUES (?, ?)");
    $stmt->execute([$nama, $deskripsi]);
    response('success', 'Kategori berhasil ditambahkan', ['id' => $pdo->lastInsertId()]);
}

if ($method === 'DELETE') {
    $id = (int) ($_GET['id'] ?? 0);
    if (!$id) response('error', 'ID tidak valid');
    $pdo->prepare("DELETE FROM kategori WHERE id = ?")->execute([$id]);
    response('success', 'Kategori berhasil dihapus');
}
