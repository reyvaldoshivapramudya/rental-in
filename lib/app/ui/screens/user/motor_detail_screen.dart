import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentalin/app/config/theme.dart';
import 'package:rentalin/app/data/models/motor_status.dart';
import 'package:rentalin/app/data/models/sewa_model.dart';
import 'package:rentalin/app/data/models/status_pemesanan.dart';
import '../../../data/models/motor_model.dart';
import '../../../providers/motor_provider.dart';
import '../../../providers/sewa_provider.dart';
import 'booking_form_screen.dart';

class MotorDetailScreen extends StatelessWidget {
  final String motorId;

  const MotorDetailScreen({super.key, required this.motorId});

  @override
  Widget build(BuildContext context) {
    final sewaProvider = Provider.of<SewaProvider>(context, listen: false);

    return Consumer<MotorProvider>(
      builder: (context, motorProvider, child) {
        if (motorProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        MotorModel? motor = motorProvider.motors.firstWhere(
          (m) => m.id == motorId,
          orElse: () => MotorModel(
            id: '',
            nama: 'Motor tidak ditemukan',
            merek: '',
            tahun: 0,
            nomorPolisi: '',
            hargaSewa: 0,
            status: MotorStatus.tidakTersedia,
            gambarUrl: '',
          ),
        );

        // Jika motor tidak ditemukan
        if (motor.id.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text('Motor tidak ditemukan')),
            body: const Center(
              child: Text(
                'Motor yang kamu cari tidak tersedia.',
                style: TextStyle(fontSize: 16),
              ),
            ),
          );
        }

        // Replace http with https if needed
        String imageUrl = motor.gambarUrl;
        if (imageUrl.startsWith('http://')) {
          imageUrl = imageUrl.replaceFirst('http://', 'https://');
        }

        return FutureBuilder<SewaModel?>(
          future: sewaProvider.checkUserPendingBooking(motorId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // MODIFIKASI: Tentukan status UI berdasarkan hasil snapshot
            final SewaModel? userPendingBooking = snapshot.data;
            final bool isUserWaitingForConfirmation =
                userPendingBooking != null;

            // Logika baru untuk mengaktifkan/menonaktifkan tombol sewa
            final bool isSewaEnabled =
                motor.status == MotorStatus.tersedia &&
                !isUserWaitingForConfirmation;

            // Logika baru untuk teks dan warna status
            final String statusText = isUserWaitingForConfirmation
                ? StatusPemesanan.menungguKonfirmasi.displayName
                : motor.status.displayName;

            final Color statusColor = isUserWaitingForConfirmation
                ? StatusPemesanan.menungguKonfirmasi.statusColor
                : (motor.status == MotorStatus.tersedia
                      ? Colors.green
                      : Colors.orange);

            return Scaffold(
              appBar: AppBar(title: Text(motor.nama)),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            height: 250,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              height: 250,
                              color: Colors.grey[200],
                              child: const Icon(
                                Icons.two_wheeler,
                                size: 80,
                                color: Colors.grey,
                              ),
                            ),
                            loadingBuilder: (context, child, progress) {
                              if (progress == null) return child;
                              return Container(
                                height: 250,
                                color: Colors.grey[200],
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: progress.expectedTotalBytes != null
                                        ? progress.cumulativeBytesLoaded /
                                              progress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          )
                        : Container(
                            height: 250,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.two_wheeler,
                              size: 80,
                              color: Colors.grey,
                            ),
                          ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            motor.nama,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${motor.merek} - ${motor.nomorPolisi}',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Chip(
                                label: Text(
                                  statusText,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: statusColor,
                              ),
                              const SizedBox(width: 10),
                              Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Tahun ${motor.tahun}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const Divider(height: 32),
                          const Text(
                            'Harga Sewa',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${motor.formattedPrice} / hari',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: isSewaEnabled
                      ? () async {
                          final bookingResult = await Navigator.of(context)
                              .push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      BookingFormScreen(motor: motor),
                                ),
                              );

                          if (bookingResult == true && context.mounted) {
                            Provider.of<MotorProvider>(
                              context,
                              listen: false,
                            ).refreshMotors();
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSewaEnabled
                        ? AppTheme.primaryColor
                        : Colors.grey,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    // isSewaEnabled ? 'Sewa Sekarang' : 'Sudah Dibooking',
                    isUserWaitingForConfirmation
                        ? 'Menunggu Konfirmasi'
                        : (motor.status == MotorStatus.tersedia
                              ? 'Sewa Sekarang'
                              : motor.status.displayName),
                    style: TextStyle(
                      fontSize: 18,
                      color: isSewaEnabled ? Colors.black : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
