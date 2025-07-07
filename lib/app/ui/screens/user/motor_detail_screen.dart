import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentalin/app/config/theme.dart';
import 'package:rentalin/app/data/models/motor_model.dart';
import 'package:rentalin/app/data/models/motor_status.dart';
import 'package:rentalin/app/data/models/sewa_model.dart';
import 'package:rentalin/app/data/models/status_pemesanan.dart';
import 'package:rentalin/app/providers/motor_provider.dart';
import 'package:rentalin/app/providers/sewa_provider.dart';
import 'package:rentalin/app/ui/screens/user/booking_form_screen.dart';

class MotorDetailScreen extends StatelessWidget {
  final String motorId;

  const MotorDetailScreen({super.key, required this.motorId});

  @override
  Widget build(BuildContext context) {
    // Dapatkan instance provider di awal untuk memanggil stream
    final motorProvider = context.read<MotorProvider>();
    final sewaProvider = context.read<SewaProvider>();

    // ⭐️ STREAMBUILDER LUAR: Mendengarkan status motor global (tersedia/disewa)
    return StreamBuilder<MotorModel>(
      stream: motorProvider.getMotorStream(motorId),
      builder: (context, motorSnapshot) {
        // Handle loading dan error untuk data motor utama
        if (motorSnapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (motorSnapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${motorSnapshot.error}')),
          );
        }
        if (!motorSnapshot.hasData) {
          return const Scaffold(
            body: Center(child: Text('Motor tidak ditemukan.')),
          );
        }

        // Jika data motor ada, kita dapatkan object-nya
        final motor = motorSnapshot.data!;

        // ⭐️ STREAMBUILDER DALAM: Mendengarkan status booking personal user
        return StreamBuilder<SewaModel?>(
          stream: sewaProvider.getPendingBookingStream(motorId),
          builder: (context, bookingSnapshot) {
            // Kita tidak perlu state loading di sini, karena tampilan utama sudah di-handle oleh stream luar.
            // Kita bisa langsung menggunakan datanya, meskipun masih dalam proses koneksi awal.
            final SewaModel? userPendingBooking = bookingSnapshot.data;
            final bool isUserWaitingForConfirmation =
                userPendingBooking != null;

            // --- LOGIKA TAMPILAN (KINI REAL-TIME) ---

            final bool isMotorGloballyAvailable =
                motor.status == MotorStatus.tersedia;
            final bool isSewaEnabled =
                isMotorGloballyAvailable && !isUserWaitingForConfirmation;

            final String statusText;
            final Color statusColor;

            // Prioritas 1: Jika user ini sedang menunggu konfirmasi, tampilkan itu.
            if (isUserWaitingForConfirmation) {
              statusText = StatusPemesanan.menungguKonfirmasi.displayName;
              statusColor = StatusPemesanan.menungguKonfirmasi.statusColor;
            } else {
              // Jika tidak, tampilkan status global dari motor.
              statusText = motor.status.displayName;
              statusColor = motor
                  .status
                  .statusColor; // Asumsi ada extension `statusColor`
            }

            final String buttonText;
            if (isUserWaitingForConfirmation) {
              buttonText = 'Menunggu Konfirmasi';
            } else if (!isMotorGloballyAvailable) {
              buttonText =
                  motor.status.displayName; // Akan menampilkan "Disewa"
            } else {
              buttonText = 'Sewa Sekarang';
            }

            // --- TAMPILAN UI (SCAFFOLD) ---

            return Scaffold(
              appBar: AppBar(title: Text(motor.nama)),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Image.network(
                      motor.gambarUrl.isNotEmpty
                          ? motor.gambarUrl
                          : 'https://via.placeholder.com/400x250?text=Gambar+Motor',
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
                      ? () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => BookingFormScreen(motor: motor),
                          ),
                        )
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
                    buttonText,
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
