enum MotorStatus {
  tersedia('tersedia'),
  tidakTersedia('tidak tersedia'),
  disewa('disewa'),
  maintenance('maintenance');

  const MotorStatus(this.value);
  final String value;

  static MotorStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'disewa':
        return MotorStatus.disewa;
      case 'maintenance':
        return MotorStatus.maintenance;
      case 'tidak tersedia':
        return MotorStatus.tidakTersedia;
      case 'tersedia':
      default:
        return MotorStatus.tersedia;
    }
  }

  String get displayName {
    switch (this) {
      case MotorStatus.tersedia:
        return 'Tersedia';
      case MotorStatus.tidakTersedia:
        return 'Tidak Tersedia';
      case MotorStatus.disewa:
        return 'Disewa';
      case MotorStatus.maintenance:
        return 'Maintenance';
    }
  }
}