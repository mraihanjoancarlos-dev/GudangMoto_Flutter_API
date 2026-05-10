// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // ⚠️ GANTI dengan IP komputer yang menjalankan XAMPP
  // Contoh: 'http://192.168.1.10/kasir/api'
  // Jangan gunakan 'localhost' di emulator Android (gunakan 10.0.2.2 untuk emulator)
  static const String baseUrl = 'http://192.168.1.14/kasir/api'; // Emulator
  // static const String baseUrl = 'http://192.168.1.X/kasir/api'; // HP fisik

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<Map<String, String>> _headers() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': token ?? '',
    };
  }

  // ─── AUTH ───
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      ).timeout(const Duration(seconds: 10));

      return jsonDecode(res.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Tidak dapat terhubung ke server: $e'};
    }
  }

  // ─── DASHBOARD ───
  static Future<Map<String, dynamic>> getDashboard() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/dashboard.php'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // ─── BARANG ───
  static Future<Map<String, dynamic>> getBarang({String search = '', int idKategori = 0}) async {
    try {
      var uri = Uri.parse('$baseUrl/barang.php');
      final params = <String, String>{};
      if (search.isNotEmpty) params['search'] = search;
      if (idKategori > 0) params['id_kategori'] = idKategori.toString();
      if (params.isNotEmpty) uri = uri.replace(queryParameters: params);

      final res = await http.get(uri, headers: await _headers())
          .timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> tambahBarang(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/barang.php'),
        headers: await _headers(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateBarang(int id, Map<String, dynamic> data) async {
    try {
      final res = await http.put(
        Uri.parse('$baseUrl/barang.php?id=$id'),
        headers: await _headers(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> hapusBarang(int id) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/barang.php?id=$id'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // ─── KATEGORI ───
  static Future<Map<String, dynamic>> getKategori() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/kategori.php'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> tambahKategori(String nama, String deskripsi) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/kategori.php'),
        headers: await _headers(),
        body: jsonEncode({'nama_kategori': nama, 'deskripsi': deskripsi}),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // ─── MASUK ───
  static Future<Map<String, dynamic>> getMasuk() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/masuk.php'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> tambahMasuk(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/masuk.php'),
        headers: await _headers(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> hapusMasuk(int id) async {
    try {
      final res = await http.delete(
        Uri.parse('$baseUrl/masuk.php?id=$id'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // ─── KELUAR ───
  static Future<Map<String, dynamic>> getKeluar() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/keluar.php'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> tambahKeluar(Map<String, dynamic> data) async {
    try {
      final res = await http.post(
        Uri.parse('$baseUrl/keluar.php'),
        headers: await _headers(),
        body: jsonEncode(data),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  // ─── LAPORAN ───
  static Future<Map<String, dynamic>> getLaporanStok() async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/laporan.php?type=stok'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }

  static Future<Map<String, dynamic>> getLaporanTransaksi(int bulan, int tahun) async {
    try {
      final res = await http.get(
        Uri.parse('$baseUrl/laporan.php?type=transaksi&bulan=$bulan&tahun=$tahun'),
        headers: await _headers(),
      ).timeout(const Duration(seconds: 10));
      return jsonDecode(res.body);
    } catch (e) {
      return {'status': 'error', 'message': 'Error: $e'};
    }
  }
}
