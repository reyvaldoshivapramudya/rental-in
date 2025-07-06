import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentalin/app/config/theme.dart';
import 'package:rentalin/app/data/models/user_model.dart';
import 'package:rentalin/app/providers/auth_provider.dart';
import 'package:rentalin/app/providers/sewa_provider.dart';
import 'package:rentalin/app/ui/screens/main_screen_wrapper.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Akses AuthProvider untuk mendapatkan data pengguna
    final authProvider = Provider.of<AuthProvider>(context);
    final UserModel? user = authProvider.user;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: user == null
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Memuat data pengguna...'),
                ],
              ),
            )
          : buildProfileBody(context, user),
    );
  }

  // Widget terpisah untuk membangun konten profil
  Widget buildProfileBody(BuildContext context, UserModel user) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Header Profil dengan Avatar
        Center(
          child: Column(
            children: [
              const CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primaryColor,
                child: Icon(Icons.person, size: 60),
              ),
              const SizedBox(height: 16),
              Text(
                // 3. Tampilkan Nama Lengkap sebagai judul utama
                user.nama,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                // 4. Tampilkan Email di bawah nama
                user.email,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Divider(),
        const SizedBox(height: 16),

        // Detail Informasi Pengguna dalam bentuk daftar
        const Text(
          'Informasi Akun',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              // 5. Tampilkan Nomor Telepon
              ProfileInfoTile(
                icon: Icons.phone_android,
                title: 'Nomor Telepon',
                value: user.nomorTelepon,
              ),
              const Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: Colors.grey,
              ),
              // 6. Tampilkan Alamat Lengkap
              ProfileInfoTile(
                icon: Icons.location_on,
                title: 'Alamat Lengkap',
                value: user.alamat,
                isMultiLine:
                    true, // Beri flag untuk alamat yang mungkin panjang
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 🔥 OutlinedButton Logout
        OutlinedButton.icon(
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Konfirmasi Logout'),
                content: const Text('Apakah Anda yakin ingin keluar?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(
                      'Batal',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  FilledButton(
                    onPressed: () async {
                      Navigator.of(ctx).pop(); // Tutup dialog terlebih dahulu

                      final authProvider = Provider.of<AuthProvider>(
                        context,
                        listen: false,
                      );
                      final sewaProvider = Provider.of<SewaProvider>(
                        context,
                        listen: false,
                      );

                      sewaProvider.clearUserSewaData();
                      await authProvider.logout();

                      // Navigasi ke LoginScreen dan hapus semua route sebelumnya
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const MainScreenWrapper(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'Logout',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
              ),
            );
          },
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text('Keluar', style: TextStyle(color: Colors.red)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Colors.red),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }
}

// Widget kustom untuk menampilkan setiap baris informasi agar rapi
class ProfileInfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isMultiLine;

  const ProfileInfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.isMultiLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(
        value.isNotEmpty ? value : 'Belum diisi',
        style: TextStyle(
          fontSize: 15,
          color: value.isNotEmpty ? Colors.black87 : Colors.grey,
          height: isMultiLine ? 1.4 : 1.0,
        ),
      ),
      dense: isMultiLine,
    );
  }
}
