import 'package:flutter/material.dart';

enum StatusPemesanan { menungguKonfirmasi, dikonfirmasi, ditolak, selesai }

StatusPemesanan statusPemesananFromString(String value) {
  final normalized = value.trim().toLowerCase();

  if (normalized.contains('menunggu')) {
    return StatusPemesanan.menungguKonfirmasi;
  } else if (normalized.contains('dikonfirmasi')) {
    return StatusPemesanan.dikonfirmasi;
  } else if (normalized.contains('ditolak')) {
    return StatusPemesanan.ditolak;
  } else if (normalized.contains('selesai')) {
    return StatusPemesanan.selesai;
  } else {
    return StatusPemesanan.menungguKonfirmasi;
  }
}

extension StatusPemesananExt on StatusPemesanan {
  String get value {
    switch (this) {
      case StatusPemesanan.menungguKonfirmasi:
        return 'menunggu_konfirmasi';
      case StatusPemesanan.dikonfirmasi:
        return 'dikonfirmasi';
      case StatusPemesanan.ditolak:
        return 'ditolak';
      case StatusPemesanan.selesai:
        return 'selesai';
    }
  }

  String get displayName {
    switch (this) {
      case StatusPemesanan.menungguKonfirmasi:
        return 'Menunggu Konfirmasi';
      case StatusPemesanan.dikonfirmasi:
        return 'Dikonfirmasi';
      case StatusPemesanan.ditolak:
        return 'Ditolak';
      case StatusPemesanan.selesai:
        return 'Selesai';
    }
  }

  Color get statusColor {
    switch (this) {
      case StatusPemesanan.menungguKonfirmasi:
        return Colors.orange;
      case StatusPemesanan.dikonfirmasi:
        return Colors.green;
      case StatusPemesanan.ditolak:
        return Colors.red;
      case StatusPemesanan.selesai:
        return Colors.blue;
    }
  }
}
