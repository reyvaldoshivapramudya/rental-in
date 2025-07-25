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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);

    // Listener untuk memperbarui UI saat user mengetik
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchBookings(context);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
      appBar: AppBar(title: const Text('Manajemen Penyewaan')),
      body: Column(
        children: [
          // ✨ WIDGET PENCARIAN ✨
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Nama Penyewa atau Motor',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                // Tambahkan tombol untuk clear text
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                        },
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: Consumer<SewaProvider>(
              builder: (context, sewaProvider, child) {
                if (sewaProvider.isLoading && sewaProvider.sewaList.isEmpty) {
                  return const LoadingWidget();
                }

                // ✨ LOGIKA FILTER DI SINI ✨
                final List<SewaModel> allBookings = sewaProvider.sewaList;
                final List<SewaModel> filteredBookings = allBookings.where((
                  sewa,
                ) {
                  final query = _searchQuery.toLowerCase();
                  final renterName = sewa.detailUser?.nama.toLowerCase() ?? '';
                  final motorName = sewa.detailMotor?.nama.toLowerCase() ?? '';

                  return renterName.contains(query) ||
                      motorName.contains(query);
                }).toList();

                if (filteredBookings.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isNotEmpty
                          ? 'Tidak ada hasil untuk "$_searchQuery".'
                          : 'Belum ada pesanan masuk.',
                    ),
                  );
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
                                Icon(
                                  Icons.history,
                                  size: 80,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Belum ada penyewaan masuk.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
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
                    itemCount: filteredBookings
                        .length, // Gunakan daftar yang sudah difilter
                    itemBuilder: (context, index) {
                      final sewa =
                          filteredBookings[index]; // Gunakan daftar yang sudah difilter
                      return BookingCard(sewa: sewa);
                    },
                  ),
                );
              },
            ),
          ),
        ],
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
              await sewaProvider.tolakPemesanan(sewa);
              final playerId = sewa.detailUser?.playerId;
              if (playerId != null && playerId.isNotEmpty) {
                await firestoreService.sendNotificationToUser(
                  playerId,
                  'Penyewaan Ditolak',
                  'Maaf, penyewaan Anda untuk ${sewa.detailMotor?.nama ?? 'motor'} ditolak.',
                  additionalData: {'target_screen': 'history_screen'},
                );
              }
            },
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Tolak'),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: () async {
              await sewaProvider.konfirmasiPemesanan(sewa);
              final playerId = sewa.detailUser?.playerId;
              if (playerId != null && playerId.isNotEmpty) {
                await firestoreService.sendNotificationToUser(
                  playerId,
                  'Penyewaan Dikonfirmasi',
                  'Penyewaan Anda untuk ${sewa.detailMotor?.nama ?? 'motor'} telah dikonfirmasi.',
                  additionalData: {'target_screen': 'history_screen'},
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
                builder: (ctx) {
                  final formKey = GlobalKey<FormState>();
                  final alasanController = TextEditingController();
                  DateTime tanggalKembali = DateTime.now();

                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: const Text('Selesaikan Sewa'),
                        content: Form(
                          key: formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: const Text(
                                  'Tanggal Pengembalian Aktual',
                                ),
                                subtitle: Text(
                                  DateFormat(
                                    'd MMMM yyyy',
                                  ).format(tanggalKembali),
                                ),
                                trailing: const Icon(Icons.calendar_today),
                                onTap: () async {
                                  final pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: tanggalKembali,
                                    firstDate: DateTime(2020),
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 30),
                                    ),
                                  );
                                  if (pickedDate != null) {
                                    setState(() => tanggalKembali = pickedDate);
                                  }
                                },
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: alasanController,
                                decoration: const InputDecoration(
                                  labelText: 'Alasan/Catatan Pengembalian',
                                  border: OutlineInputBorder(),
                                  hintText: 'Contoh: Kembali lebih awal, dll.',
                                ),
                                maxLines: 3,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Alasan tidak boleh kosong.';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(),
                            child: const Text('Batal'),
                          ),
                          FilledButton(
                            onPressed: () {
                              if (formKey.currentState!.validate()) {
                                Navigator.of(ctx).pop({
                                  'tanggal': tanggalKembali,
                                  'alasan': alasanController.text.trim(),
                                });
                              }
                            },
                            child: const Text('Selesaikan'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );

              if (result != null && result.isNotEmpty) {
                final tanggal = result['tanggal'] as DateTime;
                final alasan = result['alasan'] as String;

                await sewaProvider.selesaikanSewa(
                  sewa.id,
                  sewa.motorId,
                  tanggalPengembalianAktual: tanggal,
                  alasan: alasan,
                );
                final playerId = sewa.detailUser?.playerId;
                if (playerId != null && playerId.isNotEmpty) {
                  await firestoreService.sendNotificationToUser(
                    playerId,
                    'Sewa Selesai',
                    'Terima kasih, sewa Anda untuk ${sewa.detailMotor?.nama ?? 'motor'} telah selesai.',
                    additionalData: {'target_screen': 'history_screen'},
                  );
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
            Text('Alamat: ${sewa.detailUser?.alamat ?? 'Alamat Penyewa'}'),
            Text('Tanggal Pinjam: ${dateFormat.format(sewa.tanggalSewa)}'),
            Text('Tanggal Kembali: ${dateFormat.format(sewa.tanggalKembali)}'),
            const SizedBox(height: 8),

            if (sewa.statusPemesanan == StatusPemesanan.selesai)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if ((sewa.totalDenda ?? 0) > 0) ...[
                    Text('Biaya Sewa: Rp ${sewa.totalBiaya}'),
                    Text(
                      'Denda: Rp ${sewa.totalDenda}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const Divider(thickness: 1, height: 12),
                  ],
                  Text(
                    'Tanggal Kembali Aktual: ${sewa.tanggalPengembalianAktual != null ? dateFormat.format(sewa.tanggalPengembalianAktual!) : '-'}',
                  ),
                  Text(
                    'Total Akhir: Rp ${sewa.biayaAkhir}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (sewa.alasanPengembalian != null &&
                      sewa.alasanPengembalian!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Catatan: ${sewa.alasanPengembalian}',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                ],
              )
            else
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
