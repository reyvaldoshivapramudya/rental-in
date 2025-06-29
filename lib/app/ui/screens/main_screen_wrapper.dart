// main_screen_wrapper.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentalin/app/ui/screens/user/home_screen.dart';
import '../../providers/auth_provider.dart';
import 'admin/dashboard_screen.dart';
import 'auth/login_screen.dart';

class MainScreenWrapper extends StatelessWidget {
  const MainScreenWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // --- PERUBAHAN DI SINI ---
    // 1. Saat provider sedang memeriksa status auth, tampilkan loading screen
    if (authProvider.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 2. Setelah loading selesai, logika yang ada sebelumnya akan bekerja dengan benar
    if (authProvider.user == null) {
      // Jika belum login, tampilkan halaman login
      return const LoginScreen();
    } else {
      // Jika sudah login, cek perannya
      if (authProvider.user!.role == 'admin') { // [cite: 4]
        // Jika admin, tampilkan dashboard admin
        return const DashboardScreen();
      } else {
        // Jika bukan admin, tampilkan beranda user
        return const HomeScreen();
      }
    }
  }
}