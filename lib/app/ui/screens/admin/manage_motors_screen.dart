import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/motor_model.dart';
import '../../../providers/motor_provider.dart';
import 'motor_form_screen.dart';

class ManageMotorsScreen extends StatelessWidget {
  const ManageMotorsScreen({super.key});

  void _showDeleteConfirmation(BuildContext context, MotorModel motor) {
    final rootContext = context; // simpan context halaman

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
            onPressed: () async {
              Navigator.of(ctx).pop(); // tutup dialog terlebih dulu

              final motorProvider = Provider.of<MotorProvider>(
                rootContext,
                listen: false,
              );

              await motorProvider.deleteMotor(motor.id);
              await motorProvider.refreshMotors();

              // Cek jika widget masih mounted
              if (rootContext.mounted) {
                ScaffoldMessenger.of(rootContext).showSnackBar(
                  SnackBar(
                    content: Text('Motor "${motor.nama}" berhasil dihapus.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },

            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kelola Motor')),
      backgroundColor: Colors.grey[100],
      body: Consumer<MotorProvider>(
        builder: (context, motorProvider, child) {
          if (motorProvider.isLoading && motorProvider.motors.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (motorProvider.motors.isEmpty) {
            return const _EmptyState();
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: motorProvider.motors.length,
            itemBuilder: (context, index) {
              final motor = motorProvider.motors[index];
              return MotorManagementCard(
                motor: motor,
                onEdit: () async {
                  final result = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MotorFormScreen(motor: motor),
                    ),
                  );

                  if (result == true) {
                    // Jika halaman edit mengembalikan true, refresh list
                    Provider.of<MotorProvider>(
                      context,
                      listen: false,
                    ).refreshMotors();
                  }
                },
                onDelete: () => _showDeleteConfirmation(context, motor),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const MotorFormScreen()));

          if (result == true) {
            Provider.of<MotorProvider>(context, listen: false).refreshMotors();
          }
        },
        tooltip: 'Tambah Motor Baru',
        child: const Icon(Icons.add),
      ),
    );
  }
}

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
      shadowColor: Colors.black.withValues(alpha: 0.1),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          fontWeight: FontWeight.bold,
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
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
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
