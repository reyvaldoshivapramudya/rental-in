import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:rentalin/app/data/models/motor_model.dart';
import 'package:rentalin/app/data/models/motor_status.dart';
import 'package:rentalin/app/data/models/status_pemesanan.dart';
import 'package:rentalin/app/data/models/user_model.dart';
import 'package:rentalin/app/data/models/user_role.dart';

class SewaModel extends Equatable {
  final String id;
  final String userId;
  final String motorId;
  final DateTime tanggalSewa;
  final DateTime tanggalKembali;
  final int totalBiaya;
  final StatusPemesanan statusPemesanan;
  final MotorModel? detailMotor;
  final UserModel? detailUser;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final DateTime? tanggalPengembalianAktual;
  final int? totalDenda;

  const SewaModel({
    required this.id,
    required this.userId,
    required this.motorId,
    required this.tanggalSewa,
    required this.tanggalKembali,
    required this.totalBiaya,
    required this.statusPemesanan,
    this.detailMotor,
    this.detailUser,
    this.createdAt,
    this.updatedAt,
    this.tanggalPengembalianAktual,
    this.totalDenda,
  });

  static UserModel _parseUserFromMap(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] ?? '',
      nama: data['nama'] ?? '',
      email: data['email'] ?? '',
      role: UserRole.fromString(data['role'] ?? 'user'),
      nomorTelepon: data['nomorTelepon'] ?? '',
      alamat: data['alamat'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] is Timestamp
                ? (data['createdAt'] as Timestamp).toDate()
                : DateTime.tryParse(data['createdAt'].toString()))
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] is Timestamp
                ? (data['updatedAt'] as Timestamp).toDate()
                : DateTime.tryParse(data['updatedAt'].toString()))
          : null,
    );
  }

  static MotorModel _parseMotorFromMap(Map<String, dynamic> data) {
    return MotorModel(
      id: data['id'] ?? '',
      nama: data['nama'] ?? '',
      merek: data['merek'] ?? '',
      tahun: data['tahun'] is int
          ? data['tahun']
          : int.tryParse(
                  data['tahun']?.toString() ?? '${DateTime.now().year}',
                ) ??
                DateTime.now().year,
      nomorPolisi: data['nomorPolisi'] ?? '',
      hargaSewa: data['hargaSewa'] is int
          ? data['hargaSewa']
          : int.tryParse(data['hargaSewa']?.toString() ?? '0') ?? 0,
      status: MotorStatus.fromString(data['status'] ?? 'tersedia'),
      gambarUrl: data['gambarUrl'] ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] is Timestamp
                ? (data['createdAt'] as Timestamp).toDate()
                : DateTime.tryParse(data['createdAt'].toString()))
          : null,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] is Timestamp
                ? (data['updatedAt'] as Timestamp).toDate()
                : DateTime.tryParse(data['updatedAt'].toString()))
          : null,
    );
  }

  factory SewaModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) throw Exception('Document data is null');

      return SewaModel(
        id: doc.id,
        userId: data['userId'] ?? '',
        motorId: data['motorId'] ?? '',
        tanggalSewa:
            (data['tanggalSewa'] as Timestamp?)?.toDate() ?? DateTime.now(),
        tanggalKembali:
            (data['tanggalKembali'] as Timestamp?)?.toDate() ?? DateTime.now(),
        totalBiaya: data['totalBiaya'] ?? 0,
        statusPemesanan: statusPemesananFromString(
          data['statusPemesanan'] ?? 'menunggu_konfirmasi',
        ),
        detailMotor: data['detailMotor'] != null
            ? _parseMotorFromMap(data['detailMotor'])
            : null,
        detailUser: data['detailUser'] != null
            ? _parseUserFromMap(data['detailUser'])
            : null,
        createdAt: data['createdAt'] != null
            ? (data['createdAt'] is Timestamp
                  ? (data['createdAt'] as Timestamp).toDate()
                  : DateTime.tryParse(data['createdAt'].toString()))
            : null,
        updatedAt: data['updatedAt'] != null
            ? (data['updatedAt'] is Timestamp
                  ? (data['updatedAt'] as Timestamp).toDate()
                  : DateTime.tryParse(data['updatedAt'].toString()))
            : null,
        tanggalPengembalianAktual:
            (data['tanggalPengembalianAktual'] as Timestamp?)?.toDate(),
        totalDenda: data['totalDenda'] != null
            ? (data['totalDenda'] as num).toInt()
            : null,
      );
    } catch (e) {
      throw Exception('Error parsing SewaModel from Firestore: $e');
    }
  }

  /// Menghitung biaya akhir dengan menjumlahkan total biaya sewa dan denda (jika ada).
  int get biayaAkhir => totalBiaya + (totalDenda ?? 0);

  Map<String, dynamic> toFirestore() {
    final now = DateTime.now();
    return {
      'userId': userId,
      'motorId': motorId,
      'tanggalSewa': Timestamp.fromDate(tanggalSewa),
      'tanggalKembali': Timestamp.fromDate(tanggalKembali),
      'totalBiaya': totalBiaya,
      'statusPemesanan': statusPemesanan.value,
      'detailMotor': detailMotor?.toFirestore(),
      'detailUser': detailUser?.toFirestore(),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': Timestamp.fromDate(now),
      if (tanggalPengembalianAktual != null)
        'tanggalPengembalianAktual': Timestamp.fromDate(
          tanggalPengembalianAktual!,
        ),
      if (totalDenda != null) 'totalDenda': totalDenda,
    };
  }

  SewaModel copyWith({
    String? id,
    String? userId,
    String? motorId,
    DateTime? tanggalSewa,
    DateTime? tanggalKembali,
    int? totalBiaya,
    StatusPemesanan? statusPemesanan,
    MotorModel? detailMotor,
    UserModel? detailUser,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? tanggalPengembalianAktual,
    int? totalDenda,
  }) {
    return SewaModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      motorId: motorId ?? this.motorId,
      tanggalSewa: tanggalSewa ?? this.tanggalSewa,
      tanggalKembali: tanggalKembali ?? this.tanggalKembali,
      totalBiaya: totalBiaya ?? this.totalBiaya,
      statusPemesanan: statusPemesanan ?? this.statusPemesanan,
      detailMotor: detailMotor ?? this.detailMotor,
      detailUser: detailUser ?? this.detailUser,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      tanggalPengembalianAktual:
          tanggalPengembalianAktual ?? this.tanggalPengembalianAktual,
      totalDenda: totalDenda ?? this.totalDenda,
    );
  }

  // Computed properties
  int get durasiSewa => tanggalKembali.difference(tanggalSewa).inDays + 1;
  bool get isActive => statusPemesanan == StatusPemesanan.dikonfirmasi;
  bool get isPending => statusPemesanan == StatusPemesanan.menungguKonfirmasi;
  bool get isCompleted => statusPemesanan == StatusPemesanan.selesai;
  bool get isRejected => statusPemesanan == StatusPemesanan.ditolak;

  @override
  List<Object?> get props => [
    id,
    userId,
    motorId,
    tanggalSewa,
    tanggalKembali,
    totalBiaya,
    statusPemesanan,
    detailMotor,
    detailUser,
    createdAt,
    updatedAt,
    tanggalPengembalianAktual,
    totalDenda,
  ];
}
