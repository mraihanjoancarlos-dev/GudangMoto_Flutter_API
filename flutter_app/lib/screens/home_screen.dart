// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/theme.dart';
import 'dashboard_screen.dart';
import 'barang_screen.dart';
import 'masuk_screen.dart';
import 'keluar_screen.dart';
import 'laporan_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _adminNama = '';

  final _screens = const [
    DashboardScreen(),
    BarangScreen(),
    MasukScreen(),
    KeluarScreen(),
    LaporanScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _loadAdmin();
  }

  Future<void> _loadAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() => _adminNama = prefs.getString('admin_nama') ?? 'Admin');
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Konfirmasi Logout',
            style: TextStyle(color: AppTheme.textPrim)),
        content: const Text('Yakin ingin keluar?',
            style: TextStyle(color: AppTheme.textSec)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      if (!mounted) return;
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  // ✅ FIXED: Return type eksplisit List<PopupMenuEntry<String>>
  List<PopupMenuEntry<String>> _buildPopupMenu() {
    return [
      PopupMenuItem<String>(
        value: 'profil',
        child: Row(
          children: const [
            Icon(Icons.person, color: AppTheme.textSec, size: 20),
            SizedBox(width: 10),
            Text('Profil', style: TextStyle(color: AppTheme.textPrim)),
          ],
        ),
      ),
      const PopupMenuDivider(),
      PopupMenuItem<String>(
        value: 'logout',
        child: Row(
          children: const [
            Icon(Icons.logout, color: AppTheme.danger, size: 20),
            SizedBox(width: 10),
            Text('Logout', style: TextStyle(color: AppTheme.danger)),
          ],
        ),
      ),
    ];
  }

  void _onPopupSelected(String value) {
    if (value == 'logout') {
      _logout();
    }
    // tambah handler lain di sini jika perlu
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppTheme.surface,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [AppTheme.accent, AppTheme.accent2]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                  child: Text('🔧', style: TextStyle(fontSize: 16))),
            ),
            const SizedBox(width: 10),
            const Text('GudangMoto'),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PopupMenuButton<String>(
              onSelected: _onPopupSelected,
              icon: CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.accent.withOpacity(0.2),
                child: Text(
                  _adminNama.isNotEmpty ? _adminNama[0].toUpperCase() : 'A',
                  style: const TextStyle(
                      color: AppTheme.accent, fontWeight: FontWeight.w700),
                ),
              ),
              color: AppTheme.surface,
              // ✅ FIXED: Pakai method terpisah dengan return type yang benar
              itemBuilder: (_) => _buildPopupMenu(),
            ),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        backgroundColor: AppTheme.surface,
        indicatorColor: AppTheme.accent.withOpacity(0.2),
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppTheme.accent),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2, color: AppTheme.accent),
            label: 'Barang',
          ),
          NavigationDestination(
            icon: Icon(Icons.download_outlined),
            selectedIcon: Icon(Icons.download, color: AppTheme.accent),
            label: 'Masuk',
          ),
          NavigationDestination(
            icon: Icon(Icons.upload_outlined),
            selectedIcon: Icon(Icons.upload, color: AppTheme.accent),
            label: 'Keluar',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart, color: AppTheme.accent),
            label: 'Laporan',
          ),
        ],
      ),
    );
  }
}