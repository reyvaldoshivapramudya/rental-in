import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
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
        title: const Text('Riwayat Pesanan'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SewaProvider>(
        builder: (context, sewaProvider, child) {
          if (sewaProvider.isLoading && sewaProvider.userSewaList.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (sewaProvider.userSewaList.isEmpty) {
            return RefreshIndicator(
              onRefresh: _fetchHistory,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: const Center(
                      child: Text('Anda belum pernah melakukan pesanan.'),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _fetchHistory,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: sewaProvider.userSewaList.length,
              itemBuilder: (context, index) {
                final sortedList = List<SewaModel>.from(
                  sewaProvider.userSewaList,
                )..sort((a, b) => b.tanggalSewa.compareTo(a.tanggalSewa));
                final sewa = sortedList[index];
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
                      Text('Total: Rp ${sewa.totalBiaya}'),
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
            Text('Disewa dari: ${dateFormat.format(sewa.tanggalSewa)}'),
            Text('Hingga: ${dateFormat.format(sewa.tanggalKembali)}'),
          ],
        ),
      ),
    );
  }
}
