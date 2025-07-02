enum StatusPemesanan {
  menungguKonfirmasi('menunggu_konfirmasi'),
  dikonfirmasi('dikonfirmasi'),
  selesai('selesai'),
  ditolak('ditolak'),
  dibatalkan('dibatalkan');

  const StatusPemesanan(this.value);
  final String value;

  static StatusPemesanan fromString(String value) {
    switch (value.toLowerCase()) {
      case 'dikonfirmasi':
        return StatusPemesanan.dikonfirmasi;
      case 'selesai':
        return StatusPemesanan.selesai;
      case 'ditolak':
        return StatusPemesanan.ditolak;
      case 'dibatalkan':
        return StatusPemesanan.dibatalkan;
      case 'menunggu_konfirmasi':
      default:
        return StatusPemesanan.menungguKonfirmasi;
    }
  }

  String get displayName {
    switch (this) {
      case StatusPemesanan.menungguKonfirmasi:
        return 'Menunggu Konfirmasi';
      case StatusPemesanan.dikonfirmasi:
        return 'Dikonfirmasi';
      case StatusPemesanan.selesai:
        return 'Selesai';
      case StatusPemesanan.ditolak:
        return 'Ditolak';
      case StatusPemesanan.dibatalkan:
        return 'Dibatalkan';
    }
  }
}