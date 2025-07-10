import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentalin/app/config/theme.dart';
import 'package:rentalin/app/data/models/user_model.dart';
import 'package:rentalin/app/providers/auth_provider.dart';
import 'package:rentalin/app/providers/sewa_provider.dart';
import 'package:rentalin/app/ui/screens/main_screen_wrapper.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Method untuk menampilkan dialog edit nama
  void _showEditNameDialog(BuildContext context, AuthProvider authProvider) {
    // Controller untuk text field, diisi dengan nama saat ini
    final TextEditingController nameController = TextEditingController(
      text: authProvider.user?.nama,
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Ubah Nama'),
          content: TextField(
            controller: nameController,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Nama Baru'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) return;

                // Panggil fungsi dari provider
                final success = await authProvider.updateUserName(
                  nameController.text.trim(),
                );

                // Tutup dialog jika berhasil
                if (success && ctx.mounted) {
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Gunakan Consumer di sini agar seluruh body rebuild saat ada notifikasi
    // Ini memastikan nama di header dan di tempat lain ikut terupdate
    return Scaffold(
      appBar: AppBar(title: const Text('Profil Saya')),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final UserModel? user = authProvider.user;

          return user == null
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
              : buildProfileBody(context, user, authProvider);
        },
      ),
    );
  }

  // Widget terpisah untuk membangun konten profil
  Widget buildProfileBody(
    BuildContext context,
    UserModel user,
    AuthProvider authProvider,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        // Header Profil dengan Avatar
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppTheme.primaryColor,
                child: Text(
                  user.nama.isNotEmpty ? user.nama.substring(0, 1) : 'U',
                  style: const TextStyle(fontSize: 38.0, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 45),
                  Text(
                    user.nama,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                    onPressed: () => _showEditNameDialog(context, authProvider),
                  ),
                ],
              ),
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
