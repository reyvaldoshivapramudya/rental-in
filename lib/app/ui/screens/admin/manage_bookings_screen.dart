import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:rentalin/app/data/models/status_pemesanan.dart';
import 'package:rentalin/app/data/services/firestore_service.dart';
import 'package:rentalin/app/ui/widgets/loading_widget.dart';
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
      _fetchBookings(context);
    });
  }

  void _fetchBookings(BuildContext context) {
    context.read<SewaProvider>().fetchAllSewaForAdmin();
  }

  Future<void> _onRefresh() async {
    _fetchBookings(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manajemen Booking')),
      body: Consumer<SewaProvider>(
        builder: (context, sewaProvider, child) {
          if (sewaProvider.isLoading && sewaProvider.sewaList.isEmpty) {
            return const LoadingWidget();
          }

          if (sewaProvider.sewaList.isEmpty) {
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 80, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Belum ada pesanan masuk.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: sewaProvider.sewaList.length,
              itemBuilder: (context, index) {
                final sewa = sewaProvider.sewaList[index];
                return BookingCard(sewa: sewa);
              },
            ),
          );
        },
      ),
    );
  }
}

class BookingCard extends StatelessWidget {
  final SewaModel sewa;
  const BookingCard({super.key, required this.sewa});

  Color getStatusColor(StatusPemesanan status) {
    return status.statusColor;
  }

  Widget _buildActionButtons(BuildContext context) {
    final sewaProvider = context.read<SewaProvider>();
    final firestoreService = FirestoreService();

    if (sewa.statusPemesanan == StatusPemesanan.menungguKonfirmasi) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () async {
              await sewaProvider.konfirmasiTolakPemesanan(
                sewa.id,
                sewa.motorId,
                false,
              );

              // ✅ Kirim notifikasi penolakan booking ke user
              final playerId = sewa.detailUser?.playerId;
              if (playerId != null && playerId.isNotEmpty) {
                await firestoreService.sendNotificationToUser(
                  playerId,
                  'Booking Ditolak',
                  'Maaf, booking Anda untuk ${sewa.detailMotor?.nama ?? 'motor'} ditolak, karena tidak sesuai dengan kebijakan perusahaan🙏',
                );
              }
            },
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Tolak'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () async {
              await sewaProvider.konfirmasiTolakPemesanan(
                sewa.id,
                sewa.motorId,
                true,
              );

              // ✅ Kirim notifikasi konfirmasi booking ke user
              final playerId = sewa.detailUser?.playerId;
              if (playerId != null && playerId.isNotEmpty) {
                await firestoreService.sendNotificationToUser(
                  playerId,
                  'Booking Dikonfirmasi',
                  'Booking Anda untuk ${sewa.detailMotor?.nama ?? 'motor'} telah dikonfirmasi. Silakan lakukan pembayaran dan ambil motor sesuai jadwal🛵',
                );
              }
            },
            child: const Text('Konfirmasi'),
          ),
        ],
      );
    } else if (sewa.statusPemesanan == StatusPemesanan.dikonfirmasi) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FilledButton.icon(
            onPressed: () async {
              final result = await showDialog<Map<String, dynamic>>(
                context: context,
                builder: (context) {
                  final dendaController = TextEditingController();
                  final tanggalController = TextEditingController(
                    text: DateFormat('yyyy-MM-dd').format(DateTime.now()),
                  );

                  return AlertDialog(
                    title: const Text('Selesaikan Sewa'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Masukkan tanggal pengembalian aktual dan denda jika ada.',
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: tanggalController,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Pengembalian Aktual',
                            border: OutlineInputBorder(),
                          ),
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );
                            if (picked != null) {
                              tanggalController.text = DateFormat(
                                'yyyy-MM-dd',
                              ).format(picked);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: dendaController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Total Denda (Rp)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Batal'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, {
                            'tanggalPengembalianAktual': tanggalController.text,
                            'totalDenda': dendaController.text,
                          });
                        },
                        child: const Text('Selesai'),
                      ),
                    ],
                  );
                },
              );

              if (result != null) {
                final tanggalStr = result['tanggalPengembalianAktual'];
                final totalDendaStr = result['totalDenda'];
                final tanggal = DateTime.tryParse(tanggalStr);
                final totalDenda = int.tryParse(totalDendaStr) ?? 0;

                if (tanggal != null) {
                  await sewaProvider.selesaikanSewa(
                    sewa.id,
                    sewa.motorId,
                    tanggalPengembalianAktual: tanggal,
                    totalDenda: totalDenda > 0 ? totalDenda : null,
                  );

                  // ✅ Kirim notifikasi penyelesaian sewa ke user
                  final playerId = sewa.detailUser?.playerId;
                  if (playerId != null && playerId.isNotEmpty) {
                    await firestoreService.sendNotificationToUser(
                      playerId,
                      'Sewa Selesai',
                      'Terima kasih, sewa Anda untuk ${sewa.detailMotor?.nama ?? 'motor'} telah selesai. Jangan lupa nanti sewa lagi ya!👋',
                    );
                  }
                }
              }
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Selesaikan Sewa'),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );
    } else {
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
            _buildHeader(context),
            const Divider(),
            Text('Penyewa: ${sewa.detailUser?.nama ?? 'Nama Penyewa'}'),
            Text('Telepon: ${sewa.detailUser?.nomorTelepon ?? 'No. Telp'}'),
            const SizedBox(height: 8),
            Text('Sewa: ${dateFormat.format(sewa.tanggalSewa)}'),
            Text('Kembali: ${dateFormat.format(sewa.tanggalKembali)}'),
            const SizedBox(height: 8),
            Text(
              'Total Biaya: Rp ${sewa.totalBiaya}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: _buildActionButtons(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            sewa.detailMotor?.nama ?? 'Nama Motor',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Chip(
          label: Text(
            sewa.statusPemesanan.displayName,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          backgroundColor: getStatusColor(sewa.statusPemesanan),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}
