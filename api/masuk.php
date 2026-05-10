<?php
// htdocs/kasir/api/masuk.php
require_once 'config.php';
checkAuth();

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    $stmt = $pdo->query("
        SELECT tm.*, b.nama_barang, b.kode_barang
        FROM transaksi_masuk tm
        LEFT JOIN barang b ON tm.id_barang = b.id
        ORDER BY tm.tanggal DESC
    ");
    response('success', 'OK', $stmt->fetchAll());
}

if ($method === 'POST') {
    $body = json_decode(file_get_contents('php://input'), true);

    $id_barang     = (int) ($body['id_barang'] ?? 0);
    $jumlah_dus    = (int) ($body['jumlah_dus'] ?? 0);
    $jumlah_satuan = (int) ($body['jumlah_satuan'] ?? 0);
    $harga_beli    = (float) ($body['harga_beli'] ?? 0);
    $supplier      = sanitize($body['supplier'] ?? '');
    $tanggal       = $body['tanggal'] ?? date('Y-m-d');
    $keterangan    = sanitize($body['keterangan'] ?? '');

    if (!$id_barang || !$harga_beli) {
        response('error', 'Barang dan harga beli wajib diisi');
    }

    $total = (($jumlah_dus + $jumlah_satuan) * $harga_beli);
    $no_transaksi = generateNoTransaksi('MSK');

    try {
        $pdo->beginTransaction();

        $stmt = $pdo->prepare("
            INSERT INTO transaksi_masuk
            (no_transaksi, id_barang, jumlah_dus, jumlah_satuan, harga_beli, total, supplier, keterangan, tanggal)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ");
        $stmt->execute([$no_transaksi, $id_barang, $jumlah_dus, $jumlah_satuan, $harga_beli, $total, $supplier, $keterangan, $tanggal]);

        $pdo->prepare("
            UPDATE barang SET stok_dus = stok_dus + ?, stok_satuan = stok_satuan + ? WHERE id = ?
        ")->execute([$jumlah_dus, $jumlah_satuan, $id_barang]);

        $pdo->commit();
        response('success', 'Transaksi masuk berhasil disimpan', ['no_transaksi' => $no_transaksi]);
    } catch (Exception $e) {
        $pdo->rollBack();
        response('error', 'Gagal menyimpan transaksi: ' . $e->getMessage());
    }
}

if ($method === 'DELETE') {
    $id = (int) ($_GET['id'] ?? 0);
    if (!$id) response('error', 'ID tidak valid');

    $trx = $pdo->prepare("SELECT * FROM transaksi_masuk WHERE id = ?");
    $trx->execute([$id]);
    $data = $trx->fetch();

    if (!$data) response('error', 'Transaksi tidak ditemukan');

    try {
        $pdo->beginTransaction();

        $pdo->prepare("
            UPDATE barang SET stok_dus = stok_dus - ?, stok_satuan = stok_satuan - ? WHERE id = ?
        ")->execute([$data['jumlah_dus'], $data['jumlah_satuan'], $data['id_barang']]);

        $pdo->prepare("DELETE FROM transaksi_masuk WHERE id = ?")->execute([$id]);

        $pdo->commit();
        response('success', 'Transaksi berhasil dihapus');
    } catch (Exception $e) {
        $pdo->rollBack();
        response('error', 'Gagal menghapus: ' . $e->getMessage());
    }
}
