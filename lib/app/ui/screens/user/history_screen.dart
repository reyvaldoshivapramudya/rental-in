import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:rentalin/app/data/models/sewa_model.dart';
import 'package:rentalin/app/providers/auth_provider.dart';
import 'package:rentalin/app/providers/sewa_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // --- PERBAIKAN 1: Buat variabel untuk menyimpan referensi provider ---
  late SewaProvider _sewaProvider;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);

    // --- PERBAIKAN 2: Ambil referensi di sini, saat context masih aman ---
    _sewaProvider = Provider.of<SewaProvider>(context, listen: false);

    // Panggil data riwayat saat halaman pertama kali dibuat.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHistory();
    });
  }

  // Fungsi terpisah untuk mengambil data, bisa untuk init dan refresh
  Future<void> _fetchHistory() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      // Gunakan referensi yang sudah disimpan
      _sewaProvider.fetchSewaForCurrentUser(user.uid);
    }
  }

  // --- PERBAIKAN 3: Panggil fungsi cancel dari referensi, bukan dari context ---
  @override
  void dispose() {
    // Beri tahu provider untuk berhenti mendengarkan data riwayat
    // saat halaman ini tidak lagi ditampilkan (dihancurkan).
    _sewaProvider.cancelUserSewaStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pesanan'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Future.microtask(() {
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
              });
            },
          ),
        ],
      ),
      body: Consumer<SewaProvider>(
        builder: (context, sewaProvider, child) {
          if (sewaProvider.isLoading && sewaProvider.userSewaList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (sewaProvider.userSewaList.isEmpty) {
            return RefreshIndicator(
              onRefresh: () => _fetchHistory(),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    alignment: Alignment.center,
                    child: const Text('Anda belum pernah melakukan pesanan.'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () => _fetchHistory(),
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: sewaProvider.userSewaList.length,
              itemBuilder: (context, index) {
                final sewa = sewaProvider.userSewaList[index];
                return HistoryCard(sewa: sewa);
              },
            ),
          );
        },
      ),
    );
  }
}

class HistoryCard extends StatelessWidget {
  final SewaModel sewa;
  const HistoryCard({super.key, required this.sewa});

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Menunggu Konfirmasi':
        return Colors.orange;
      case 'Dikonfirmasi':
        return Colors.green;
      case 'Ditolak':
        return Colors.red;
      case 'Selesai':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yy', 'id_ID');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    sewa.detailMotor['gambarUrl'] ?? '',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.motorcycle, size: 50),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sewa.detailMotor['nama'] ?? 'Nama Motor',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text('Total: Rp ${sewa.totalBiaya}'),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    sewa.statusPemesanan,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: _getStatusColor(sewa.statusPemesanan),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              'Disewa dari: ${dateFormat.format(sewa.tanggalSewa.toDate())}',
            ),
            Text('Hingga: ${dateFormat.format(sewa.tanggalKembali.toDate())}'),
          ],
        ),
      ),
    );
  }
}
