import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import '../../../data/models/sewa_model.dart';
import '../../../providers/sewa_provider.dart';

class ManageBookingsScreen extends StatefulWidget {
  const ManageBookingsScreen({super.key});

  @override
  State<ManageBookingsScreen> createState() => _ManageBookingsScreenState();
}

class _ManageBookingsScreenState extends State<ManageBookingsScreen> {
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SewaProvider>(context, listen: false).fetchAllSewaForAdmin();
    });
  }

  Future<void> _refreshBookings(BuildContext context) async {
    Provider.of<SewaProvider>(context, listen: false).fetchAllSewaForAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manajemen Booking'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshBookings(context),
        child: Consumer<SewaProvider>(
          builder: (context, sewaProvider, child) {
            if (sewaProvider.isLoading && sewaProvider.sewaList.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (sewaProvider.sewaList.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    alignment: Alignment.center,
                    child: const Text('Belum ada pesanan masuk.'),
                  ),
                ],
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: sewaProvider.sewaList.length,
              itemBuilder: (context, index) {
                final sewa = sewaProvider.sewaList[index];
                return BookingCard(sewa: sewa);
              },
            );
          },
        ),
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final SewaModel sewa;
  const BookingCard({super.key, required this.sewa});

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

  // --- WIDGET BARU UNTUK MENAMPILKAN TOMBOL AKSI SECARA DINAMIS ---
  Widget _buildActionButtons(BuildContext context) {
    final sewaProvider = Provider.of<SewaProvider>(context, listen: false);

    switch (sewa.statusPemesanan) {
      case 'Menunggu Konfirmasi':
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            OutlinedButton(
              onPressed: () => sewaProvider.konfirmasiTolakPemesanan(
                sewa.id,
                sewa.motorId,
                false,
              ),
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Tolak'),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: () => sewaProvider.konfirmasiTolakPemesanan(
                sewa.id,
                sewa.motorId,
                true,
              ),
              child: const Text('Konfirmasi'),
            ),
          ],
        );
      case 'Dikonfirmasi':
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FilledButton.icon(
              onPressed: () =>
                  sewaProvider.selesaikanSewa(sewa.id, sewa.motorId),
              icon: const Icon(Icons.check_circle_outline),
              label: const Text('Selesaikan Sewa'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      default:
        // Untuk status 'Ditolak' atau 'Selesai', tidak ada tombol aksi
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMM yy', 'id_ID');
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (Kode untuk info pesanan tidak berubah)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    sewa.detailMotor['nama'] ?? 'Nama Motor',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(
                    sewa.statusPemesanan,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  backgroundColor: _getStatusColor(sewa.statusPemesanan),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 0,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),
            const Divider(),
            Text('Penyewa: ${sewa.detailUser['nama'] ?? 'Nama Penyewa'}'),
            Text('Telepon: ${sewa.detailUser['nomorTelepon'] ?? 'No. Telp'}'),
            const SizedBox(height: 8),
            Text('Sewa: ${dateFormat.format(sewa.tanggalSewa.toDate())}'),
            Text('Kembali: ${dateFormat.format(sewa.tanggalKembali.toDate())}'),
            const SizedBox(height: 8),
            Text(
              'Total Biaya: Rp ${sewa.totalBiaya}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

            // --- PERBAIKAN DI SINI ---
            // Tampilkan tombol aksi secara dinamis
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: _buildActionButtons(context),
            ),
          ],
        ),
      ),
    );
  }
}
