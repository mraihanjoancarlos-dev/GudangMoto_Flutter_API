// lib/screens/barang_screen.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';

class BarangScreen extends StatefulWidget {
  const BarangScreen({super.key});

  @override
  State<BarangScreen> createState() => _BarangScreenState();
}

class _BarangScreenState extends State<BarangScreen> {
  List<dynamic> _barang = [];
  List<dynamic> _kategori = [];
  bool _loading = true;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final res = await ApiService.getBarang(search: _search);
    final kat = await ApiService.getKategori();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _barang = res['status'] == 'success' ? res['data'] as List : [];
      _kategori = kat['status'] == 'success' ? kat['data'] as List : [];
    });
  }

  void _showForm({Map<String, dynamic>? item}) {
    final kodeCtrl = TextEditingController(text: item?['kode_barang'] ?? '');
    final namaCtrl = TextEditingController(text: item?['nama_barang'] ?? '');
    final hargaBeliCtrl = TextEditingController(text: item?['harga_beli']?.toString() ?? '');
    final hargaOperanCtrl = TextEditingController(text: item?['harga_operan']?.toString() ?? '');
    final hargaEceranCtrl = TextEditingController(text: item?['harga_eceran']?.toString() ?? '');
    final jumlahPerDusCtrl = TextEditingController(text: item?['jumlah_per_dus']?.toString() ?? '1');
    final stokDusCtrl = TextEditingController(text: item?['stok_dus']?.toString() ?? '0');
    final stokSatuanCtrl = TextEditingController(text: item?['stok_satuan']?.toString() ?? '0');
    final satuanCtrl = TextEditingController(text: item?['satuan'] ?? 'pcs');
    int? selectedKategori = item != null ? int.tryParse(item['id_kategori']?.toString() ?? '') : null;

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
                    Text(item == null ? '➕ Tambah Barang' : '✏️ Edit Barang',
                        style: const TextStyle(color: AppTheme.textPrim,
                            fontSize: 18, fontWeight: FontWeight.w700)),
                    IconButton(
                        onPressed: () => Navigator.pop(ctx),
                        icon: const Icon(Icons.close, color: AppTheme.muted)),
                  ],
                ),
                const SizedBox(height: 16),
                _field('Kode Barang', kodeCtrl, enabled: item == null),
                _field('Nama Barang', namaCtrl),
                // Kategori dropdown
                const Text('KATEGORI', style: TextStyle(
                    color: AppTheme.textSec, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
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
                      value: selectedKategori,
                      isExpanded: true,
                      dropdownColor: AppTheme.surface2,
                      hint: const Text('Pilih Kategori',
                          style: TextStyle(color: AppTheme.muted)),
                      items: [
                        const DropdownMenuItem(value: null,
                            child: Text('-- Pilih Kategori --',
                                style: TextStyle(color: AppTheme.muted))),
                        ..._kategori.map((k) => DropdownMenuItem(
                          value: k['id'] as int,
                          child: Text(k['nama_kategori'],
                              style: const TextStyle(color: AppTheme.textPrim)),
                        )),
                      ],
                      onChanged: (v) => setModal(() => selectedKategori = v),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _field('Jumlah/Dus', jumlahPerDusCtrl, isNum: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _field('Satuan', satuanCtrl)),
                ]),
                Row(children: [
                  Expanded(child: _field('Stok Dus', stokDusCtrl, isNum: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _field('Stok Satuan', stokSatuanCtrl, isNum: true)),
                ]),
                _field('Harga Beli', hargaBeliCtrl, isNum: true),
                Row(children: [
                  Expanded(child: _field('Harga Operan', hargaOperanCtrl, isNum: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _field('Harga Eceran', hargaEceranCtrl, isNum: true)),
                ]),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final data = {
                        'kode_barang': kodeCtrl.text,
                        'nama_barang': namaCtrl.text,
                        'id_kategori': selectedKategori,
                        'jumlah_per_dus': int.tryParse(jumlahPerDusCtrl.text) ?? 1,
                        'stok_dus': int.tryParse(stokDusCtrl.text) ?? 0,
                        'stok_satuan': int.tryParse(stokSatuanCtrl.text) ?? 0,
                        'harga_beli': double.tryParse(hargaBeliCtrl.text) ?? 0,
                        'harga_operan': double.tryParse(hargaOperanCtrl.text) ?? 0,
                        'harga_eceran': double.tryParse(hargaEceranCtrl.text) ?? 0,
                        'satuan': satuanCtrl.text,
                      };
                      Map<String, dynamic> res;
                      if (item == null) {
                        res = await ApiService.tambahBarang(data);
                      } else {
                        res = await ApiService.updateBarang(item['id'] as int, data);
                      }
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

  Widget _field(String label, TextEditingController ctrl,
      {bool isNum = false, bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(
            color: AppTheme.textSec, fontSize: 11,
            fontWeight: FontWeight.w600, letterSpacing: 0.8)),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          enabled: enabled,
          style: const TextStyle(color: AppTheme.textPrim),
          keyboardType: isNum ? TextInputType.number : TextInputType.text,
          decoration: InputDecoration(
            filled: true,
            fillColor: enabled ? AppTheme.surface2 : AppTheme.surface,
          ),
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

  Future<void> _hapus(Map<String, dynamic> item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Hapus Barang', style: TextStyle(color: AppTheme.textPrim)),
        content: Text('Hapus "${item['nama_barang']}"?',
            style: const TextStyle(color: AppTheme.textSec)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal')),
          TextButton(onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (confirm == true) {
      final res = await ApiService.hapusBarang(item['id'] as int);
      _showSnack(res['message'], res['status'] == 'success');
      if (res['status'] == 'success') _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              style: const TextStyle(color: AppTheme.textPrim),
              decoration: const InputDecoration(
                hintText: 'Cari barang...',
                prefixIcon: Icon(Icons.search, color: AppTheme.muted),
              ),
              onChanged: (v) {
                _search = v;
                _load();
              },
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(AppTheme.accent)))
                : _barang.isEmpty
                    ? const Center(
                        child: Text('Tidak ada barang',
                            style: TextStyle(color: AppTheme.muted)))
                    : RefreshIndicator(
                        onRefresh: _load,
                        color: AppTheme.accent,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _barang.length,
                          itemBuilder: (_, i) {
                            final b = _barang[i];
                            final stok = (int.tryParse(b['stok_dus'].toString()) ?? 0) *
                                (int.tryParse(b['jumlah_per_dus'].toString()) ?? 1) +
                                (int.tryParse(b['stok_satuan'].toString()) ?? 0);
                            Color stokColor = stok == 0 ? AppTheme.danger
                                : stok < 10 ? AppTheme.warning
                                : AppTheme.success;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: AppTheme.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 42, height: 42,
                                    decoration: BoxDecoration(
                                      color: AppTheme.accent.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Center(child: Text('📦', style: TextStyle(fontSize: 20))),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(b['nama_barang'] ?? '',
                                            style: const TextStyle(
                                                color: AppTheme.textPrim, fontWeight: FontWeight.w600)),
                                        Text(b['kode_barang'] ?? '',
                                            style: const TextStyle(color: AppTheme.accent, fontSize: 12)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text('Stok: $stok ${b['satuan'] ?? 'pcs'}',
                                                style: TextStyle(color: stokColor, fontSize: 12,
                                                    fontWeight: FontWeight.w500)),
                                            const SizedBox(width: 12),
                                            Text(formatRupiah(b['harga_eceran']),
                                                style: const TextStyle(color: AppTheme.textSec, fontSize: 12)),
                                          ],
                                        ),
                                        if (b['nama_kategori'] != null)
                                          Text(b['nama_kategori'],
                                              style: const TextStyle(color: AppTheme.muted, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      IconButton(
                                        onPressed: () => _showForm(item: b),
                                        icon: const Icon(Icons.edit_outlined,
                                            color: AppTheme.info, size: 20),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                      const SizedBox(height: 8),
                                      IconButton(
                                        onPressed: () => _hapus(b),
                                        icon: const Icon(Icons.delete_outline,
                                            color: AppTheme.danger, size: 20),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accent,
        onPressed: () => _showForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
