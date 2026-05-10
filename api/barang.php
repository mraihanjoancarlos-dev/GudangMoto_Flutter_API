<?php
// htdocs/kasir/api/barang.php
require_once 'config.php';
checkAuth();

$method = $_SERVER['REQUEST_METHOD'];

// GET - list semua barang
if ($method === 'GET') {
    $search = sanitize($_GET['search'] ?? '');
    $id_kategori = (int) ($_GET['id_kategori'] ?? 0);

    $where = [];
    $params = [];

    if ($search) {
        $where[] = "(b.nama_barang LIKE ? OR b.kode_barang LIKE ?)";
        $params[] = "%$search%";
        $params[] = "%$search%";
    }
    if ($id_kategori) {
        $where[] = "b.id_kategori = ?";
        $params[] = $id_kategori;
    }

    $sql = "
        SELECT b.*, k.nama_kategori
        FROM barang b
        LEFT JOIN kategori k ON b.id_kategori = k.id
    ";
    if ($where) $sql .= " WHERE " . implode(" AND ", $where);
    $sql .= " ORDER BY b.nama_barang ASC";

    $stmt = $pdo->prepare($sql);
    $stmt->execute($params);
    $data = $stmt->fetchAll();

    response('success', 'OK', $data);
}

// POST - tambah barang
if ($method === 'POST') {
    $body = json_decode(file_get_contents('php://input'), true);

    $kode_barang   = sanitize($body['kode_barang'] ?? '');
    $nama_barang   = sanitize($body['nama_barang'] ?? '');
    $id_kategori   = (int) ($body['id_kategori'] ?? 0);
    $jumlah_per_dus= (int) ($body['jumlah_per_dus'] ?? 1);
    $harga_beli    = (float) ($body['harga_beli'] ?? 0);
    $harga_operan  = (float) ($body['harga_operan'] ?? 0);
    $harga_eceran  = (float) ($body['harga_eceran'] ?? 0);
    $stok_dus      = (int) ($body['stok_dus'] ?? 0);
    $stok_satuan   = (int) ($body['stok_satuan'] ?? 0);
    $satuan        = sanitize($body['satuan'] ?? 'pcs');
    $keterangan    = sanitize($body['keterangan'] ?? '');

    if (!$kode_barang || !$nama_barang) {
        response('error', 'Kode dan nama barang wajib diisi');
    }

    try {
        $stmt = $pdo->prepare("
            INSERT INTO barang
            (kode_barang, nama_barang, id_kategori, jumlah_per_dus, harga_beli, harga_operan, harga_eceran, stok_dus, stok_satuan, satuan, keterangan)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        $stmt->execute([$kode_barang, $nama_barang, $id_kategori ?: null, $jumlah_per_dus, $harga_beli, $harga_operan, $harga_eceran, $stok_dus, $stok_satuan, $satuan, $keterangan]);
        response('success', 'Barang berhasil ditambahkan', ['id' => $pdo->lastInsertId()]);
    } catch (PDOException $e) {
        if ($e->getCode() == 23000) {
            response('error', 'Kode barang sudah digunakan');
        }
        response('error', 'Gagal menyimpan: ' . $e->getMessage());
    }
}

// PUT - update barang
if ($method === 'PUT') {
    $id   = (int) ($_GET['id'] ?? 0);
    $body = json_decode(file_get_contents('php://input'), true);

    if (!$id) response('error', 'ID tidak valid');

    $nama_barang   = sanitize($body['nama_barang'] ?? '');
    $id_kategori   = (int) ($body['id_kategori'] ?? 0);
    $jumlah_per_dus= (int) ($body['jumlah_per_dus'] ?? 1);
    $harga_beli    = (float) ($body['harga_beli'] ?? 0);
    $harga_operan  = (float) ($body['harga_operan'] ?? 0);
    $harga_eceran  = (float) ($body['harga_eceran'] ?? 0);
    $satuan        = sanitize($body['satuan'] ?? 'pcs');
    $keterangan    = sanitize($body['keterangan'] ?? '');

    $stmt = $pdo->prepare("
        UPDATE barang SET
            nama_barang=?, id_kategori=?, jumlah_per_dus=?,
            harga_beli=?, harga_operan=?, harga_eceran=?,
            satuan=?, keterangan=?
        WHERE id=?
    ");
    $stmt->execute([$nama_barang, $id_kategori ?: null, $jumlah_per_dus, $harga_beli, $harga_operan, $harga_eceran, $satuan, $keterangan, $id]);
    response('success', 'Barang berhasil diupdate');
}

// DELETE - hapus barang
if ($method === 'DELETE') {
    $id = (int) ($_GET['id'] ?? 0);
    if (!$id) response('error', 'ID tidak valid');

    $pdo->prepare("DELETE FROM barang WHERE id = ?")->execute([$id]);
    response('success', 'Barang berhasil dihapus');
}
