import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:rentalin/app/data/models/status_pemesanan.dart';
import '../../../data/models/sewa_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/sewa_provider.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late SewaProvider _sewaProvider;
  String _selectedFilter = 'Semua';

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    _sewaProvider = Provider.of<SewaProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchHistory();
    });
  }

  Future<void> _fetchHistory() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (!mounted) return;
    if (user != null) {
      _sewaProvider.fetchSewaForCurrentUser(user.uid);
    }
  }

  @override
  void dispose() {
    _sewaProvider.cancelUserSewaStream();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Penyewaan'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filter Penyewaan',
            onSelected: (value) {
              setState(() {
                _selectedFilter = value;
              });
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(value: 'Semua', child: Text('Semua')),
                const PopupMenuItem(
                  value: 'Menunggu Konfirmasi',
                  child: Text('Menunggu Konfirmasi'),
                ),
                const PopupMenuItem(
                  value: 'Dikonfirmasi',
                  child: Text('Dikonfirmasi'),
                ),
                const PopupMenuItem(value: 'Ditolak', child: Text('Ditolak')),
                const PopupMenuItem(value: 'Selesai', child: Text('Selesai')),
              ];
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
              onRefresh: _fetchHistory,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.history, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text('Anda belum pernah melakukan penyewaan.'),
                  ],
                ),
              ),
            );
          }

          // Filter list berdasarkan _selectedFilter
          final filteredList = sewaProvider.userSewaList.where((sewa) {
            if (_selectedFilter == 'Semua') return true;
            return sewa.statusPemesanan.displayName.toLowerCase() ==
                _selectedFilter.toLowerCase();
          }).toList()..sort((a, b) => b.tanggalSewa.compareTo(a.tanggalSewa));

          return RefreshIndicator(
            onRefresh: _fetchHistory,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final sewa = filteredList[index];
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
    switch (status.toLowerCase()) {
      case 'menunggu konfirmasi':
        return Colors.orange;
      case 'dikonfirmasi':
        return Colors.green;
      case 'ditolak':
        return Colors.red;
      case 'selesai':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yy', 'id_ID');
    final imageUrl = sewa.detailMotor?.gambarUrl ?? '';
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

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
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.motorcycle, size: 50),
                        )
                      : Container(
                          width: 50,
                          height: 50,
                          color: Colors.grey[200],
                          child: const Icon(
                            Icons.motorcycle,
                            size: 30,
                            color: Colors.grey,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        sewa.detailMotor?.nama ?? 'Nama Motor',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      // Teks 'Total' kita pindahkan ke bawah agar lebih detail
                      Text('ID Pesanan: ${sewa.id.substring(0, 6)}...'),
                    ],
                  ),
                ),
                Chip(
                  label: Text(
                    sewa.statusPemesanan.displayName,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: _getStatusColor(
                    sewa.statusPemesanan.displayName,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
              ],
            ),
            const Divider(height: 20),
            // BAGIAN DETAIL TANGGAL
            Text('Disewa dari: ${dateFormat.format(sewa.tanggalSewa)}'),
            Text('Hingga: ${dateFormat.format(sewa.tanggalKembali)}'),
            if (sewa.tanggalPengembalianAktual != null)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Dikembalikan pada: ${dateFormat.format(sewa.tanggalPengembalianAktual!)}',
                  style: const TextStyle(color: Colors.black87),
                ),
              ),
            const SizedBox(height: 12),

            // ✨ BAGIAN RINCIAN BIAYA (YANG DIPERBARUI) ✨
            // Jika booking sudah selesai dan ada denda, tampilkan rinciannya.
            if (sewa.statusPemesanan == StatusPemesanan.selesai &&
                (sewa.totalDenda ?? 0) > 0)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Biaya Sewa: ${currencyFormat.format(sewa.totalBiaya)}'),
                  Text(
                    'Denda: ${currencyFormat.format(sewa.totalDenda)}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const Divider(thickness: 1, height: 16),
                  Text(
                    'Total Pembayaran: ${currencyFormat.format(sewa.biayaAkhir)}', // Gunakan getter baru
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              )
            else
              // Jika tidak, tampilkan total biaya sewa seperti biasa.
              Text(
                'Total Biaya: ${currencyFormat.format(sewa.totalBiaya)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
