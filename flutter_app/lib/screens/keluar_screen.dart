// lib/screens/keluar_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';

class KeluarScreen extends StatefulWidget {
  const KeluarScreen({super.key});

  @override
  State<KeluarScreen> createState() => _KeluarScreenState();
}

class _KeluarScreenState extends State<KeluarScreen> {
  List<dynamic> _transaksi = [];
  List<dynamic> _barang = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await ApiService.getKeluar();
    final bar = await ApiService.getBarang();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _transaksi = res['status'] == 'success' ? res['data'] as List : [];
      _barang = bar['status'] == 'success' ? bar['data'] as List : [];
    });
  }

  void _showForm() {
    int? selectedBarang;
    String jenisHarga = 'eceran';
    final dusCtrl      = TextEditingController(text: '0');
    final satuanCtrl   = TextEditingController(text: '0');
    final pelangganCtrl= TextEditingController();
    final tglCtrl      = TextEditingController(
        text: DateTime.now().toIso8601String().substring(0, 10));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('📤 Tambah Barang Keluar',
                        style: TextStyle(color: AppTheme.textPrim,
                            fontSize: 17, fontWeight: FontWeight.w700)),
                    IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, color: AppTheme.muted)),
                  ],
                ),
                const SizedBox(height: 16),
                const Text('BARANG', style: TextStyle(
                    color: AppTheme.textSec, fontSize: 11,
                    fontWeight: FontWeight.w600, letterSpacing: 0.8)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int?>(
                      value: selectedBarang,
                      isExpanded: true,
                      dropdownColor: AppTheme.surface2,
                      hint: const Text('Pilih Barang',
                          style: TextStyle(color: AppTheme.muted)),
                      items: [
                        const DropdownMenuItem(value: null,
                            child: Text('-- Pilih Barang --',
                                style: TextStyle(color: AppTheme.muted))),
                        ..._barang.map((b) => DropdownMenuItem(
                          value: b['id'] as int,
                          child: Text(
                            '${b['nama_barang']} (Stok: ${(int.tryParse(b['stok_dus'].toString()) ?? 0) * (int.tryParse(b['jumlah_per_dus'].toString()) ?? 1) + (int.tryParse(b['stok_satuan'].toString()) ?? 0)})',
                            style: const TextStyle(color: AppTheme.textPrim),
                          ),
                        )),
                      ],
                      onChanged: (v) => setModal(() => selectedBarang = v),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _field('Jumlah Dus', dusCtrl, isNum: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _field('Jumlah Satuan', satuanCtrl, isNum: true)),
                ]),
                // Jenis Harga
                const Text('JENIS HARGA', style: TextStyle(
                    color: AppTheme.textSec, fontSize: 11,
                    fontWeight: FontWeight.w600, letterSpacing: 0.8)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: AppTheme.surface2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: jenisHarga,
                      isExpanded: true,
                      dropdownColor: AppTheme.surface2,
                      items: const [
                        DropdownMenuItem(value: 'eceran',
                            child: Text('Eceran (Retail)',
                                style: TextStyle(color: AppTheme.textPrim))),
                        DropdownMenuItem(value: 'operan',
                            child: Text('Operan (Grosir)',
                                style: TextStyle(color: AppTheme.textPrim))),
                      ],
                      onChanged: (v) => setModal(() => jenisHarga = v!),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                _field('Pelanggan', pelangganCtrl),
                _field('Tanggal', tglCtrl),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (selectedBarang == null) {
                        ScaffoldMessenger.of(ctx).showSnackBar(
                            const SnackBar(content: Text('Pilih barang terlebih dahulu'),
                                backgroundColor: AppTheme.danger));
                        return;
                      }
                      final res = await ApiService.tambahKeluar({
                        'id_barang': selectedBarang,
                        'jumlah_dus': int.tryParse(dusCtrl.text) ?? 0,
                        'jumlah_satuan': int.tryParse(satuanCtrl.text) ?? 0,
                        'jenis_harga': jenisHarga,
                        'pelanggan': pelangganCtrl.text,
                        'tanggal': tglCtrl.text,
                      });
                      if (!ctx.mounted) return;
                      Navigator.pop(ctx);
                      _showSnack(res['message'], res['status'] == 'success');
                      if (res['status'] == 'success') _load();
                    },
                    child: const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController ctrl, {bool isNum = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(
            color: AppTheme.textSec, fontSize: 11,
            fontWeight: FontWeight.w600, letterSpacing: 0.8)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          style: const TextStyle(color: AppTheme.textPrim),
          keyboardType: isNum ? TextInputType.number : TextInputType.text,
          decoration: const InputDecoration(filled: true, fillColor: AppTheme.surface2),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  void _showSnack(String msg, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: success ? AppTheme.success : AppTheme.danger,
    ));
  }

  double get _totalPenjualan => _transaksi.fold(0.0,
      (sum, t) => sum + (double.tryParse(t['total'].toString()) ?? 0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: _loading
          ? const Center(child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppTheme.accent)))
          : RefreshIndicator(
              onRefresh: _load,
              color: AppTheme.accent,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          _statBox('${_transaksi.length}', 'Total Transaksi', AppTheme.warning),
                          const SizedBox(width: 12),
                          _statBox(formatRupiah(_totalPenjualan), 'Total Penjualan', AppTheme.success),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: _transaksi.isEmpty
                        ? const SliverToBoxAdapter(
                            child: Center(child: Padding(
                              padding: EdgeInsets.all(40),
                              child: Text('Belum ada transaksi keluar',
                                  style: TextStyle(color: AppTheme.muted)),
                            )))
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (_, i) {
                                final t = _transaksi[i];
                                final isEceran = t['jenis_harga'] == 'eceran';
                                return Container(
                                  margin: const EdgeInsets.only(bottom: 10),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: AppTheme.surface,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: AppTheme.border),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: AppTheme.surface2,
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(color: AppTheme.border),
                                            ),
                                            child: Text(t['no_transaksi'] ?? '',
                                                style: const TextStyle(
                                                    color: AppTheme.accent, fontSize: 11)),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: (isEceran ? AppTheme.success : AppTheme.info).withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              isEceran ? 'Eceran' : 'Operan',
                                              style: TextStyle(
                                                  color: isEceran ? AppTheme.success : AppTheme.info,
                                                  fontSize: 11, fontWeight: FontWeight.w500),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 10),
                                      Text(t['nama_barang'] ?? '',
                                          style: const TextStyle(
                                              color: AppTheme.textPrim, fontWeight: FontWeight.w600)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text('${t['jumlah_dus']} dus / ${t['jumlah_satuan']} pcs',
                                              style: const TextStyle(color: AppTheme.textSec, fontSize: 13)),
                                          const Spacer(),
                                          Text(formatRupiah(t['total']),
                                              style: const TextStyle(
                                                  color: AppTheme.accent, fontWeight: FontWeight.w700)),
                                        ],
                                      ),
                                      if (t['pelanggan']?.isNotEmpty == true)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4),
                                          child: Text('👤 ${t['pelanggan']}',
                                              style: const TextStyle(
                                                  color: AppTheme.muted, fontSize: 12)),
                                        ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(formatTanggal(t['tanggal'] ?? ''),
                                            style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              childCount: _transaksi.length,
                            ),
                          ),
                  ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.warning,
        onPressed: _showForm,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _statBox(String value, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(
                color: color, fontSize: 18, fontWeight: FontWeight.w700),
                overflow: TextOverflow.ellipsis),
            Text(label, style: const TextStyle(color: AppTheme.textSec, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
