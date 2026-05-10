// lib/screens/laporan_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';

class LaporanScreen extends StatefulWidget {
  const LaporanScreen({super.key});

  @override
  State<LaporanScreen> createState() => _LaporanScreenState();
}

class _LaporanScreenState extends State<LaporanScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tab;
  bool _loadingStok = true, _loadingTrx = true;
  Map<String, dynamic>? _stokData;
  Map<String, dynamic>? _trxData;

  int _bulan = DateTime.now().month;
  int _tahun = DateTime.now().year;

  static const _bulanNama = [
    '', 'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 2, vsync: this);
    _loadStok();
    _loadTrx();
  }

  Future<void> _loadStok() async {
    setState(() => _loadingStok = true);
    final res = await ApiService.getLaporanStok();
    if (!mounted) return;
    setState(() {
      _loadingStok = false;
      _stokData = res['status'] == 'success' ? res['data'] : null;
    });
  }

  Future<void> _loadTrx() async {
    setState(() => _loadingTrx = true);
    final res = await ApiService.getLaporanTransaksi(_bulan, _tahun);
    if (!mounted) return;
    setState(() {
      _loadingTrx = false;
      _trxData = res['status'] == 'success' ? res['data'] : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Column(
        children: [
          Container(
            color: AppTheme.surface,
            child: TabBar(
              controller: _tab,
              indicatorColor: AppTheme.accent,
              labelColor: AppTheme.accent,
              unselectedLabelColor: AppTheme.muted,
              tabs: const [
                Tab(text: '📦 Laporan Stok'),
                Tab(text: '💹 Laporan Transaksi'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tab,
              children: [_buildStokTab(), _buildTrxTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStokTab() {
    if (_loadingStok) {
      return const Center(child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(AppTheme.accent)));
    }
    if (_stokData == null) {
      return Center(child: ElevatedButton(
          onPressed: _loadStok, child: const Text('Muat Ulang')));
    }

    final barang = _stokData!['barang'] as List;
    final totalNilai = _stokData!['total_nilai'] ?? 0;

    int aman = 0, menipis = 0, habis = 0;
    for (final b in barang) {
      final stok = int.tryParse(b['stok_total'].toString()) ?? 0;
      if (stok == 0) habis++;
      else if (stok < 10) menipis++;
      else aman++;
    }

    return RefreshIndicator(
      onRefresh: _loadStok,
      color: AppTheme.accent,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary
          Row(children: [
            _miniStat('✅ Aman', '$aman', AppTheme.success),
            const SizedBox(width: 8),
            _miniStat('⚠️ Menipis', '$menipis', AppTheme.warning),
            const SizedBox(width: 8),
            _miniStat('🚫 Habis', '$habis', AppTheme.danger),
          ]),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(
              children: [
                const Text('💰', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Nilai Stok',
                        style: TextStyle(color: AppTheme.textSec, fontSize: 12)),
                    Text(formatRupiah(totalNilai),
                        style: const TextStyle(color: AppTheme.success,
                            fontSize: 20, fontWeight: FontWeight.w700)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...barang.map((b) {
            final stok = int.tryParse(b['stok_total'].toString()) ?? 0;
            Color stokColor = stok == 0 ? AppTheme.danger
                : stok < 10 ? AppTheme.warning : AppTheme.success;
            String stokLabel = stok == 0 ? 'Habis'
                : stok < 10 ? 'Menipis' : 'Aman';

            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(b['nama_barang'] ?? '',
                            style: const TextStyle(
                                color: AppTheme.textPrim, fontWeight: FontWeight.w600, fontSize: 13)),
                        Text('${b['kode_barang']} • ${b['nama_kategori'] ?? '-'}',
                            style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
                        Text('${b['stok_dus']} dus / ${b['stok_satuan']} ${b['satuan']}',
                            style: const TextStyle(color: AppTheme.textSec, fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text('$stok ${b['satuan']}',
                          style: TextStyle(color: stokColor, fontWeight: FontWeight.w700)),
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: stokColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(stokLabel,
                            style: TextStyle(color: stokColor, fontSize: 11)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTrxTab() {
    return Column(
      children: [
        // Filter bulan
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: AppTheme.surface,
          child: Row(
            children: [
              DropdownButton<int>(
                value: _bulan,
                dropdownColor: AppTheme.surface2,
                style: const TextStyle(color: AppTheme.textPrim),
                items: List.generate(12, (i) => DropdownMenuItem(
                  value: i + 1,
                  child: Text(_bulanNama[i + 1]),
                )),
                onChanged: (v) { setState(() => _bulan = v!); _loadTrx(); },
              ),
              const SizedBox(width: 16),
              DropdownButton<int>(
                value: _tahun,
                dropdownColor: AppTheme.surface2,
                style: const TextStyle(color: AppTheme.textPrim),
                items: List.generate(5, (i) => DropdownMenuItem(
                  value: DateTime.now().year - i,
                  child: Text('${DateTime.now().year - i}'),
                )),
                onChanged: (v) { setState(() => _tahun = v!); _loadTrx(); },
              ),
              const Spacer(),
              IconButton(
                onPressed: _loadTrx,
                icon: const Icon(Icons.refresh, color: AppTheme.accent),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loadingTrx
              ? const Center(child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppTheme.accent)))
              : _trxData == null
                  ? Center(child: ElevatedButton(
                      onPressed: _loadTrx, child: const Text('Muat Ulang')))
                  : RefreshIndicator(
                      onRefresh: _loadTrx,
                      color: AppTheme.accent,
                      child: ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          Row(children: [
                            _miniStat('📥 Pembelian',
                                formatRupiah(_trxData!['total_masuk']), AppTheme.info),
                            const SizedBox(width: 8),
                            _miniStat('📤 Penjualan',
                                formatRupiah(_trxData!['total_keluar']), AppTheme.success),
                          ]),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Estimasi Laba Kotor',
                                    style: TextStyle(color: AppTheme.textSec)),
                                Text(formatRupiah(_trxData!['laba_kotor']),
                                    style: const TextStyle(
                                        color: AppTheme.accent,
                                        fontWeight: FontWeight.w700, fontSize: 16)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          const Text('📥 Transaksi Masuk',
                              style: TextStyle(color: AppTheme.textPrim,
                                  fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 8),
                          ...(_trxData!['masuk'] as List).map((t) => _trxCard(t, true)),
                          if ((_trxData!['masuk'] as List).isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text('Tidak ada transaksi masuk',
                                  style: TextStyle(color: AppTheme.muted),
                                  textAlign: TextAlign.center),
                            ),
                          const SizedBox(height: 16),
                          const Text('📤 Transaksi Keluar',
                              style: TextStyle(color: AppTheme.textPrim,
                                  fontWeight: FontWeight.w700, fontSize: 15)),
                          const SizedBox(height: 8),
                          ...(_trxData!['keluar'] as List).map((t) => _trxCard(t, false)),
                          if ((_trxData!['keluar'] as List).isEmpty)
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: Text('Tidak ada transaksi keluar',
                                  style: TextStyle(color: AppTheme.muted),
                                  textAlign: TextAlign.center),
                            ),
                        ],
                      ),
                    ),
        ),
      ],
    );
  }

  Widget _trxCard(Map<String, dynamic> t, bool isMasuk) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t['nama_barang'] ?? '',
                    style: const TextStyle(color: AppTheme.textPrim,
                        fontWeight: FontWeight.w600, fontSize: 13)),
                Text('${t['no_transaksi']} • ${formatTanggal(t['tanggal'] ?? '')}',
                    style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
              ],
            ),
          ),
          Text(formatRupiah(t['total']),
              style: const TextStyle(color: AppTheme.accent, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _miniStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: color, fontSize: 11)),
            Text(value, style: TextStyle(
                color: color, fontWeight: FontWeight.w700, fontSize: 14),
                overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}
