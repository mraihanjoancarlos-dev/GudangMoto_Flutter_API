<?php
// htdocs/kasir/api/keluar.php
require_once 'config.php';
checkAuth();

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $stmt = $pdo->query("
        SELECT tk.*, b.nama_barang, b.kode_barang
        FROM transaksi_keluar tk
        LEFT JOIN barang b ON tk.id_barang = b.id
        ORDER BY tk.tanggal DESC
    ");
    response('success', 'OK', $stmt->fetchAll());
}

if ($method === 'POST') {
    $body = json_decode(file_get_contents('php://input'), true);

    $id_barang     = (int) ($body['id_barang'] ?? 0);
    $jumlah_dus    = (int) ($body['jumlah_dus'] ?? 0);
    $jumlah_satuan = (int) ($body['jumlah_satuan'] ?? 0);
    $jenis_harga   = $body['jenis_harga'] ?? 'eceran';
    $pelanggan     = sanitize($body['pelanggan'] ?? '');
    $tanggal       = $body['tanggal'] ?? date('Y-m-d');
    $keterangan    = sanitize($body['keterangan'] ?? '');

    if (!$id_barang) response('error', 'Barang wajib dipilih');

    $barangStmt = $pdo->prepare("SELECT * FROM barang WHERE id = ?");
    $barangStmt->execute([$id_barang]);
    $b = $barangStmt->fetch();

    if (!$b) response('error', 'Barang tidak ditemukan');

    $harga_jual = ($jenis_harga === 'operan') ? $b['harga_operan'] : $b['harga_eceran'];
    $qty_total  = ($jumlah_dus * $b['jumlah_per_dus']) + $jumlah_satuan;
    $stok_total = ($b['stok_dus'] * $b['jumlah_per_dus']) + $b['stok_satuan'];

    if ($qty_total > $stok_total) {
        response('error', "Stok tidak cukup. Stok tersedia: $stok_total");
    }

    $total = $qty_total * $harga_jual;
    $no_transaksi = generateNoTransaksi('KLR');

    try {
        $pdo->beginTransaction();

        $pdo->prepare("
            INSERT INTO transaksi_keluar
            (no_transaksi, id_barang, jumlah_dus, jumlah_satuan, jenis_harga, harga_jual, total, pelanggan, keterangan, tanggal)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ")->execute([$no_transaksi, $id_barang, $jumlah_dus, $jumlah_satuan, $jenis_harga, $harga_jual, $total, $pelanggan, $keterangan, $tanggal]);

        $stok_dus_baru    = max(0, $b['stok_dus'] - $jumlah_dus);
        $stok_satuan_baru = max(0, $b['stok_satuan'] - $jumlah_satuan);

        $pdo->prepare("
            UPDATE barang SET stok_dus = ?, stok_satuan = ? WHERE id = ?
        ")->execute([$stok_dus_baru, $stok_satuan_baru, $id_barang]);

        $pdo->commit();
        response('success', 'Transaksi keluar berhasil disimpan', [
            'no_transaksi' => $no_transaksi,
            'harga_jual'   => $harga_jual,
            'total'        => $total,
        ]);
    } catch (Exception $e) {
        $pdo->rollBack();
        response('error', 'Gagal menyimpan: ' . $e->getMessage());
    }
}
