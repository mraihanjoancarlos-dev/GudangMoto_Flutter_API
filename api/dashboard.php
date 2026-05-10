<?php
// htdocs/kasir/api/dashboard.php
require_once 'config.php';
checkAuth();

$total_barang = $pdo->query("SELECT COUNT(*) FROM barang")->fetchColumn();
$total_stok   = $pdo->query("SELECT SUM(stok_dus * jumlah_per_dus + stok_satuan) FROM barang")->fetchColumn() ?? 0;
$nilai_stok   = $pdo->query("SELECT SUM((stok_dus * jumlah_per_dus + stok_satuan) * harga_beli) FROM barang")->fetchColumn() ?? 0;

$total_masuk  = $pdo->query("SELECT COUNT(*) FROM transaksi_masuk WHERE MONTH(tanggal)=MONTH(NOW()) AND YEAR(tanggal)=YEAR(NOW())")->fetchColumn();
$total_keluar = $pdo->query("SELECT COUNT(*) FROM transaksi_keluar WHERE MONTH(tanggal)=MONTH(NOW()) AND YEAR(tanggal)=YEAR(NOW())")->fetchColumn();
$omset_bulan  = $pdo->query("SELECT SUM(total) FROM transaksi_keluar WHERE MONTH(tanggal)=MONTH(NOW()) AND YEAR(tanggal)=YEAR(NOW())")->fetchColumn() ?? 0;

$hampir_habis = $pdo->query("
    SELECT b.kode_barang, b.nama_barang, b.stok_dus, b.stok_satuan, b.jumlah_per_dus, b.satuan, k.nama_kategori
    FROM barang b
    LEFT JOIN kategori k ON b.id_kategori = k.id
    WHERE (b.stok_dus * b.jumlah_per_dus + b.stok_satuan) < 10
    ORDER BY stok_dus ASC LIMIT 8
")->fetchAll();

$trx_terbaru = $pdo->query("
    (SELECT 'Masuk' as jenis, tm.no_transaksi, b.nama_barang, tm.jumlah_dus, tm.jumlah_satuan, tm.total, tm.tanggal
     FROM transaksi_masuk tm JOIN barang b ON tm.id_barang=b.id ORDER BY tm.created_at DESC LIMIT 5)
    UNION ALL
    (SELECT 'Keluar' as jenis, tk.no_transaksi, b.nama_barang, tk.jumlah_dus, tk.jumlah_satuan, tk.total, tk.tanggal
     FROM transaksi_keluar tk JOIN barang b ON tk.id_barang=b.id ORDER BY tk.created_at DESC LIMIT 5)
    ORDER BY tanggal DESC LIMIT 8
")->fetchAll();

response('success', 'OK', [
    'stats' => [
        'total_barang'  => (int) $total_barang,
        'total_stok'    => (int) $total_stok,
        'nilai_stok'    => (float) $nilai_stok,
        'omset_bulan'   => (float) $omset_bulan,
        'total_masuk'   => (int) $total_masuk,
        'total_keluar'  => (int) $total_keluar,
    ],
    'hampir_habis' => $hampir_habis,
    'trx_terbaru'  => $trx_terbaru,
]);
