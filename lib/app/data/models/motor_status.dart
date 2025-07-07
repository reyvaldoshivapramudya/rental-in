import 'package:flutter/material.dart'; // ✨ TAMBAHKAN IMPORT INI

enum MotorStatus {
  tersedia('tersedia'),
  tidakTersedia('tidak tersedia'),
  disewa('disewa'),
  menungguKonfirmasi('menunggu konfirmasi');

  const MotorStatus(this.value);
  final String value;

  static MotorStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'disewa':
        return MotorStatus.disewa;
      case 'menunggu konfirmasi':
        return MotorStatus.menungguKonfirmasi;
      case 'tidak tersedia':
        return MotorStatus.tidakTersedia;
      case 'tersedia':
      default:
        return MotorStatus.tersedia;
    }
  }

  static MotorStatus fromValue(String value) {
    return MotorStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MotorStatus.tersedia,
    );
  }

  String get displayName {
    switch (this) {
      case MotorStatus.tersedia:
        return 'Tersedia';
      case MotorStatus.tidakTersedia:
        return 'Tidak Tersedia';
      case MotorStatus.disewa:
        return 'Disewa';
      case MotorStatus.menungguKonfirmasi:
        return 'Menunggu Konfirmasi';
    }
  }

  // ✨ TAMBAHKAN GETTER BARU DI BAWAH INI ✨
  Color get statusColor {
    switch (this) {
      case MotorStatus.tersedia:
        return Colors.green;
      case MotorStatus.disewa:
        return Colors.orange;
      case MotorStatus.menungguKonfirmasi:
        return Colors.blue;
      case MotorStatus.tidakTersedia:
        return Colors.grey;
    }
  }
}
