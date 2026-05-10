# 📱 GudangMoto — Flutter APK + API PHP Setup Guide

## 📁 Struktur File

```
xampp/htdocs/kasir/          ← Web PHP (sudah ada)
xampp/htdocs/kasir/api/      ← API PHP baru (copy ke sini)
  ├── config.php
  ├── login.php
  ├── dashboard.php
  ├── barang.php
  ├── kategori.php
  ├── masuk.php
  ├── keluar.php
  └── laporan.php

flutter_app/                  ← Project Flutter
  ├── pubspec.yaml
  ├── lib/
  │   ├── main.dart
  │   ├── utils/theme.dart
  │   ├── services/api_service.dart
  │   └── screens/
  │       ├── login_screen.dart
  │       ├── home_screen.dart
  │       ├── dashboard_screen.dart
  │       ├── barang_screen.dart
  │       ├── masuk_screen.dart
  │       ├── keluar_screen.dart
  │       └── laporan_screen.dart
  └── android/app/src/main/AndroidManifest.xml
```

---

## ⚙️ LANGKAH 1 — Setup API PHP

1. Buka folder: `C:\xampp\htdocs\kasir\`
2. Buat folder baru bernama `api`
3. Copy semua file dari folder `api/` ke `C:\xampp\htdocs\kasir\api\`
4. Pastikan XAMPP Apache + MySQL sudah berjalan
5. Test di browser: `http://localhost/kasir/api/login.php`
   - Harusnya muncul JSON error (karena belum POST)

---

## ⚙️ LANGKAH 2 — Cari IP Komputer

Untuk menghubungkan HP ke XAMPP, perlu IP lokal komputer:

**Windows:**
```
Buka CMD → ketik: ipconfig
Cari: IPv4 Address → contoh: 192.168.1.100
```

**Pastikan HP dan komputer terhubung ke WiFi yang SAMA!**

---

## ⚙️ LANGKAH 3 — Edit base URL di Flutter

Buka file: `lib/services/api_service.dart`

```dart
// Ganti baris ini sesuai IP komputer Anda:

// Untuk emulator Android (AVD):
static const String baseUrl = 'http://10.0.2.2/kasir/api';

// Untuk HP fisik (ganti X dengan IP komputer):
static const String baseUrl = 'http://192.168.1.X/kasir/api';
```

---

## ⚙️ LANGKAH 4 — Install Flutter & Build APK

### Install Flutter (jika belum):
1. Download: https://docs.flutter.dev/get-started/install/windows
2. Extract ke `C:\flutter`
3. Tambah `C:\flutter\bin` ke PATH environment variable
4. Jalankan: `flutter doctor` — pastikan ✅ Flutter & ✅ Android toolchain

### Install Android Studio (jika belum):
1. Download: https://developer.android.com/studio
2. Install Android SDK (API 33+)
3. Setup emulator ATAU aktifkan USB Debugging di HP

### Build APK:
```bash
# Masuk ke folder flutter_app
cd flutter_app

# Install dependencies
flutter pub get

# Build APK debug (untuk testing)
flutter build apk --debug

# Build APK release (untuk distribusi)
flutter build apk --release

# APK tersimpan di:
# build/app/outputs/flutter-apk/app-debug.apk
# build/app/outputs/flutter-apk/app-release.apk
```

### Install ke HP via USB:
```bash
flutter install
```

---

## ⚙️ LANGKAH 5 — Konfigurasi XAMPP untuk LAN

Agar HP fisik bisa akses XAMPP di komputer:

1. Buka `C:\xampp\apache\conf\httpd.conf`
2. Cari: `Listen 80`
3. Tambahkan di bawahnya: `Listen 0.0.0.0:80`

Atau lebih mudah — buka **Windows Firewall**:
- Allow app → tambahkan `httpd.exe` dari folder xampp

---

## 🔐 Login Default

- **Username:** admin  
- **Password:** admin123

---

## 🔧 Troubleshooting

### Error: "Tidak dapat terhubung ke server"
- Pastikan XAMPP berjalan
- Pastikan IP sudah benar di `api_service.dart`
- Pastikan HP & komputer satu jaringan WiFi
- Coba akses `http://192.168.1.X/kasir/api/login.php` dari browser HP

### Error: "Cleartext HTTP traffic not permitted"
- Sudah ditangani di `AndroidManifest.xml` dengan `android:usesCleartextTraffic="true"`

### Error: Database
- Pastikan database `gudang_motor` sudah ada
- Import ulang `database.sql` via phpMyAdmin

### APK tidak bisa diinstall
- Aktifkan "Install dari sumber tidak dikenal" di pengaturan HP
- Atau "Allow from this source" untuk file manager

---

## 📱 Fitur APK

| Fitur | Status |
|-------|--------|
| Login Admin | ✅ |
| Dashboard Stats | ✅ |
| Stok Hampir Habis | ✅ |
| Transaksi Terbaru | ✅ |
| Data Barang (CRUD) | ✅ |
| Barang Masuk | ✅ |
| Barang Keluar | ✅ |
| Laporan Stok | ✅ |
| Laporan Transaksi | ✅ |
| Filter per Bulan/Tahun | ✅ |
| Dark Mode | ✅ |
| Pull to Refresh | ✅ |

---

## 💡 Tips Production

1. Ganti `usesCleartextTraffic="true"` → gunakan HTTPS
2. Ganti token sederhana → gunakan JWT
3. Deploy PHP ke hosting → ganti `baseUrl` ke domain
4. Tambahkan validasi lebih ketat di API PHP
