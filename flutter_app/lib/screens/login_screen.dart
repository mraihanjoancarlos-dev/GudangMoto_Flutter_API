// lib/screens/login_screen.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../utils/theme.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usernameCtrl = TextEditingController(text: 'admin');
  final _passwordCtrl = TextEditingController(text: 'admin123');
  bool _loading = false;
  bool _obscure = true;
  String _error = '';

  Future<void> _login() async {
    setState(() { _loading = true; _error = ''; });

    final res = await ApiService.login(
      _usernameCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (res['status'] == 'success') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', res['data']['token']);
      await prefs.setString('admin_nama', res['data']['nama']);
      await prefs.setString('admin_username', res['data']['username']);
      if (!mounted) return;
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const HomeScreen()));
    } else {
      setState(() => _error = res['message'] ?? 'Login gagal');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),
              // Logo
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.accent, AppTheme.accent2],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Center(
                        child: Text('🔧', style: TextStyle(fontSize: 32)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'GudangMoto',
                      style: TextStyle(
                        color: AppTheme.textPrim,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Sistem Informasi Gudang Motor',
                      style: TextStyle(color: AppTheme.textSec, fontSize: 13),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 48),
              // Card form
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selamat Datang 👋',
                      style: TextStyle(
                        color: AppTheme.textPrim,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Masuk ke akun administrator',
                      style: TextStyle(color: AppTheme.textSec, fontSize: 13),
                    ),
                    const SizedBox(height: 24),

                    if (_error.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.danger.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
                        ),
                        child: Row(
                          children: [
                            const Text('⚠️ '),
                            Expanded(child: Text(_error,
                                style: const TextStyle(color: Color(0xFFFCA5A5), fontSize: 13))),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    const Text('USERNAME', style: TextStyle(
                      color: AppTheme.textSec, fontSize: 11,
                      fontWeight: FontWeight.w600, letterSpacing: 0.8,
                    )),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _usernameCtrl,
                      style: const TextStyle(color: AppTheme.textPrim),
                      decoration: const InputDecoration(
                        hintText: 'Masukkan username',
                        prefixIcon: Icon(Icons.person_outline, color: AppTheme.muted),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Text('PASSWORD', style: TextStyle(
                      color: AppTheme.textSec, fontSize: 11,
                      fontWeight: FontWeight.w600, letterSpacing: 0.8,
                    )),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _passwordCtrl,
                      obscureText: _obscure,
                      style: const TextStyle(color: AppTheme.textPrim),
                      decoration: InputDecoration(
                        hintText: 'Masukkan password',
                        prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.muted),
                        suffixIcon: IconButton(
                          icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: AppTheme.muted),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                      onSubmitted: (_) => _login(),
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _loading ? null : _login,
                        child: _loading
                            ? const SizedBox(
                                height: 20, width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                            : const Text('Masuk ke Dashboard →'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        'Default: admin / admin123',
                        style: TextStyle(color: AppTheme.muted, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
