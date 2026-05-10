// lib/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _data;
  bool _loading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = ''; });
    final res = await ApiService.getDashboard();
    if (!mounted) return;
    if (res['status'] == 'success') {
      setState(() { _data = res['data']; _loading = false; });
    } else {
      setState(() { _error = res['message']; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(AppTheme.accent)));
    }
    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, color: AppTheme.muted, size: 48),
            const SizedBox(height: 12),
            Text(_error, style: const TextStyle(color: AppTheme.textSec), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _load, child: const Text('Coba Lagi')),
          ],
        ),
      );
    }

    final stats = _data!['stats'] as Map<String, dynamic>;
    final hampirHabis = _data!['hampir_habis'] as List<dynamic>;
    final trxTerbaru  = _data!['trx_terbaru'] as List<dynamic>;

    return RefreshIndicator(
      onRefresh: _load,
      color: AppTheme.accent,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _StatCard('📦', 'Total Barang',
                    stats['total_barang'].toString(), AppTheme.accent),
                _StatCard('🏪', 'Total Stok',
                    stats['total_stok'].toString(), AppTheme.info),
                _StatCard('📥', 'Masuk Bulan Ini',
                    stats['total_masuk'].toString(), AppTheme.success),
                _StatCard('📤', 'Keluar Bulan Ini',
                    stats['total_keluar'].toString(), AppTheme.warning),
              ],
            ),
            const SizedBox(height: 16),

            // Nilai stok & omset
            Row(
              children: [
                Expanded(child: _BigStatCard(
                  '💰', 'Nilai Stok',
                  formatRupiah(stats['nilai_stok']),
                  AppTheme.success,
                )),
                const SizedBox(width: 12),
                Expanded(child: _BigStatCard(
                  '📈', 'Omset Bulan Ini',
                  formatRupiah(stats['omset_bulan']),
                  AppTheme.info,
                )),
              ],
            ),
            const SizedBox(height: 16),

            // Hampir Habis
            if (hampirHabis.isNotEmpty) ...[
              _SectionHeader('⚠️ Stok Hampir Habis'),
              const SizedBox(height: 8),
              ...hampirHabis.map((item) {
                final stok = (int.tryParse(item['stok_dus'].toString()) ?? 0) *
                    (int.tryParse(item['jumlah_per_dus'].toString()) ?? 1) +
                    (int.tryParse(item['stok_satuan'].toString()) ?? 0);
                Color color = stok == 0 ? AppTheme.danger
                    : stok < 5 ? AppTheme.danger
                    : AppTheme.warning;
                String label = stok == 0 ? 'Habis' : stok < 5 ? 'Kritis' : 'Menipis';

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
                            Text(item['nama_barang'] ?? '',
                                style: const TextStyle(
                                    color: AppTheme.textPrim, fontWeight: FontWeight.w600)),
                            Text(item['kode_barang'] ?? '',
                                style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('$stok ${item['satuan'] ?? 'pcs'}',
                              style: const TextStyle(color: AppTheme.textPrim, fontWeight: FontWeight.w600)),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(label,
                                style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w500)),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 8),
            ],

            // Transaksi Terbaru
            _SectionHeader('🕐 Transaksi Terbaru'),
            const SizedBox(height: 8),
            ...trxTerbaru.map((t) {
              final ismasuk = t['jenis'] == 'Masuk';
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
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: (ismasuk ? AppTheme.success : AppTheme.warning).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(child: Text(ismasuk ? '📥' : '📤')),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t['nama_barang'] ?? '',
                              style: const TextStyle(color: AppTheme.textPrim,
                                  fontWeight: FontWeight.w500, fontSize: 13),
                              overflow: TextOverflow.ellipsis),
                          Text(t['tanggal'] ?? '',
                              style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
                        ],
                      ),
                    ),
                    Text(formatRupiah(t['total']),
                        style: const TextStyle(
                            color: AppTheme.accent, fontWeight: FontWeight.w600, fontSize: 13)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon, label, value;
  final Color color;
  const _StatCard(this.icon, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 32, height: 32,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 16))),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(
                  color: AppTheme.textPrim, fontSize: 20, fontWeight: FontWeight.w700)),
              Text(label, style: const TextStyle(color: AppTheme.textSec, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _BigStatCard extends StatelessWidget {
  final String icon, label, value;
  final Color color;
  const _BigStatCard(this.icon, this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(
              color: color, fontSize: 15, fontWeight: FontWeight.w700)),
          Text(label, style: const TextStyle(color: AppTheme.textSec, fontSize: 11)),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(
        color: AppTheme.textPrim, fontSize: 15, fontWeight: FontWeight.w700));
  }
}
