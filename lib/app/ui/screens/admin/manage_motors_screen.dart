import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/motor_model.dart';
import '../../../providers/motor_provider.dart';
import 'motor_form_screen.dart';

class ManageMotorsScreen extends StatelessWidget {
  const ManageMotorsScreen({super.key});

  void _showDeleteConfirmation(BuildContext context, MotorModel motor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Hapus'),
        content: Text(
          'Anda yakin ingin menghapus motor "${motor.nama}"? Aksi ini tidak dapat dibatalkan.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            child: const Text('Batal'),
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          FilledButton(
            child: const Text('Hapus'),
            onPressed: () {
              Provider.of<MotorProvider>(
                context,
                listen: false,
              ).deleteMotor(motor.id);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Motor "${motor.nama}" berhasil dihapus.'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Motor'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: Consumer<MotorProvider>(
        builder: (context, motorProvider, child) {
          if (motorProvider.isLoading && motorProvider.motors.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (motorProvider.motors.isEmpty) {
            return const _EmptyState(); // Tampilan empty state yang lebih baik
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: motorProvider.motors.length,
            itemBuilder: (context, index) {
              final motor = motorProvider.motors[index];
              return MotorManagementCard(
                motor: motor,
                onEdit: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MotorFormScreen(motor: motor),
                    ),
                  );
                },
                onDelete: () => _showDeleteConfirmation(context, motor),
              );
            },
          );
        },
      ),
      // Tombol FAB untuk tambah motor
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const MotorFormScreen()));
        },
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
        tooltip: 'Tambah Motor Baru',
      ),
    );
  }
}

// Widget Kartu Kustom untuk setiap motor
class MotorManagementCard extends StatelessWidget {
  final MotorModel motor;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MotorManagementCard({
    super.key,
    required this.motor,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.1),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Gambar Motor
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    motor.gambarUrl,
                    width: 100,
                    height: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 100,
                        height: 100,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.two_wheeler,
                          color: Colors.grey,
                          size: 40,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                // Detail Motor
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        motor.nama,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${motor.merek} • ${motor.tahun}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Rp ${motor.hargaSewa} / hari',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.blueAccent,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'No. Pol: ${motor.nomorPolisi}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            // Aksi dan Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status Chip
                _StatusChip(status: motor.status),
                // Tombol Aksi
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Colors.blueAccent,
                      ),
                      onPressed: onEdit,
                      tooltip: 'Edit',
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      onPressed: onDelete,
                      tooltip: 'Hapus',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Widget untuk menampilkan status dengan chip berwarna
class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    Color chipColor;
    String chipLabel;
    IconData chipIcon;

    switch (status) {
      case 'Disewa':
        chipColor = Colors.redAccent;
        chipLabel = 'Disewa';
        chipIcon = Icons.lock_clock;
        break;
      case 'Menunggu Konfirmasi':
        chipColor = Colors.orangeAccent;
        chipLabel = 'Menunggu';
        chipIcon = Icons.hourglass_top;
        break;
      default: // Tersedia
        chipColor = Colors.green;
        chipLabel = 'Tersedia';
        chipIcon = Icons.check_circle;
    }

    return Chip(
      avatar: Icon(chipIcon, color: Colors.white, size: 16),
      label: Text(chipLabel),
      labelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
      ),
      backgroundColor: chipColor,
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    );
  }
}

// Widget untuk tampilan saat daftar motor kosong
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.no_transfer_rounded, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Belum Ada Motor',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tekan tombol + untuk menambahkan motor pertama Anda.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
