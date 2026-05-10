<?php
// htdocs/kasir/api/laporan.php
require_once 'config.php';
checkAuth();

$type = $_GET['type'] ?? 'stok';

if ($type === 'stok') {
    $data = $pdo->query("
        SELECT b.*, k.nama_kategori,
               (b.stok_dus * b.jumlah_per_dus + b.stok_satuan) as stok_total,
               ((b.stok_dus * b.jumlah_per_dus + b.stok_satuan) * b.harga_beli) as nilai_stok
        FROM barang b
        LEFT JOIN kategori k ON b.id_kategori = k.id
        ORDER BY b.nama_barang ASC
    ")->fetchAll();

    $total_nilai = array_sum(array_column($data, 'nilai_stok'));

    response('success', 'OK', [
        'barang'      => $data,
        'total_nilai' => $total_nilai,
    ]);
}

if ($type === 'transaksi') {
    $bulan = (int) ($_GET['bulan'] ?? date('n'));
    $tahun = (int) ($_GET['tahun'] ?? date('Y'));

    $masuk = $pdo->prepare("
        SELECT tm.*, b.nama_barang, b.kode_barang
        FROM transaksi_masuk tm
        LEFT JOIN barang b ON tm.id_barang = b.id
        WHERE MONTH(tm.tanggal) = ? AND YEAR(tm.tanggal) = ?
        ORDER BY tm.tanggal DESC
    ");
    $masuk->execute([$bulan, $tahun]);
    $data_masuk = $masuk->fetchAll();

    $keluar = $pdo->prepare("
        SELECT tk.*, b.nama_barang, b.kode_barang
        FROM transaksi_keluar tk
        LEFT JOIN barang b ON tk.id_barang = b.id
        WHERE MONTH(tk.tanggal) = ? AND YEAR(tk.tanggal) = ?
        ORDER BY tk.tanggal DESC
    ");
    $keluar->execute([$bulan, $tahun]);
    $data_keluar = $keluar->fetchAll();

    $total_masuk  = array_sum(array_column($data_masuk, 'total'));
    $total_keluar = array_sum(array_column($data_keluar, 'total'));

    response('success', 'OK', [
        'masuk'         => $data_masuk,
        'keluar'        => $data_keluar,
        'total_masuk'   => $total_masuk,
        'total_keluar'  => $total_keluar,
        'laba_kotor'    => $total_keluar - $total_masuk,
    ]);
}
