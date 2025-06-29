import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentalin/app/providers/sewa_provider.dart';
import 'package:rentalin/app/ui/screens/admin/manage_motors_screen.dart';
import '../../../providers/auth_provider.dart';
import 'motor_form_screen.dart';
import 'manage_bookings_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Ambil data admin untuk ditampilkan di header
    final adminEmail =
        Provider.of<AuthProvider>(context, listen: false).user?.email ??
        'Admin';

    return Scaffold(
      backgroundColor: Colors.grey[100], // Latar belakang yang lebih soft
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        elevation: 0, // Menghilangkan bayangan default
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Dialog konfirmasi sebelum logout
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Konfirmasi Logout'),
                  content: const Text('Apakah Anda yakin ingin keluar?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Batal'),
                    ),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(ctx).pop(); // Tutup dialog
                        Future.microtask(() {
                          final authProvider = Provider.of<AuthProvider>(
                            context,
                            listen: false,
                          );
                          final sewaProvider = Provider.of<SewaProvider>(
                            context,
                            listen: false,
                          );
                          sewaProvider.clearUserSewaData();
                          authProvider.logout();
                        });
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // --- 1. Header Sambutan ---
          _buildHeader(context, adminEmail),

          // --- 2. Grid Menu ---
          Expanded(
            child: GridView.count(
              crossAxisCount: 2, // 2 kolom
              padding: const EdgeInsets.all(16.0),
              crossAxisSpacing: 16.0,
              mainAxisSpacing: 16.0,
              children: [
                DashboardCard(
                  icon: Icons.add_circle_outline,
                  title: 'Tambah Motor',
                  subtitle: 'Daftarkan motor baru',
                  color: Colors.green,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const MotorFormScreen(),
                      ),
                    );
                  },
                ),
                DashboardCard(
                  icon: Icons.edit_note,
                  title: 'Kelola Motor',
                  subtitle: 'Edit atau hapus data',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const ManageMotorsScreen(),
                      ),
                    );
                  },
                ),
                DashboardCard(
                  icon: Icons.book_online_outlined,
                  title: 'Manajemen Booking',
                  subtitle: 'Konfirmasi pesanan',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const ManageBookingsScreen(),
                      ),
                    );
                  },
                ),
                // DashboardCard(
                //   icon: Icons.bar_chart_outlined,
                //   title: 'Laporan',
                //   subtitle: 'Statistik rental',
                //   color: Colors.purple,
                //   onTap: () {
                //     // Placeholder untuk fitur selanjutnya
                //     ScaffoldMessenger.of(context).showSnackBar(
                //       const SnackBar(
                //         content: Text('Fitur Laporan segera hadir!'),
                //       ),
                //     );
                //   },
                // ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk header
  Widget _buildHeader(BuildContext context, String adminEmail) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      decoration: const BoxDecoration(
        color: Colors.blueAccent,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Selamat Datang!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          Text(
            adminEmail,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// --- 3. Widget Kustom untuk Kartu Dashboard ---
class DashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4.0,
      shadowColor: color.withOpacity(0.3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: color.withOpacity(0.15),
                child: Icon(icon, size: 28, color: color),
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
