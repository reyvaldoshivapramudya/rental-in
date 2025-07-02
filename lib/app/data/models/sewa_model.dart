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
  final String? catatanAdmin;
  final DateTime? createdAt;
  final DateTime? updatedAt;

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
    this.catatanAdmin,
    this.createdAt,
    this.updatedAt,
  });

  factory SewaModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) throw Exception('Document data is null');

      return SewaModel(
        id: doc.id,
        userId: data['userId'] ?? '',
        motorId: data['motorId'] ?? '',
        tanggalSewa: (data['tanggalSewa'] as Timestamp?)?.toDate() ?? DateTime.now(),
        tanggalKembali: (data['tanggalKembali'] as Timestamp?)?.toDate() ?? DateTime.now(),
        totalBiaya: data['totalBiaya'] ?? 0,
        statusPemesanan: StatusPemesanan.fromString(data['statusPemesanan'] ?? 'menunggu_konfirmasi'),
        detailMotor: data['detailMotor'] != null ? _parseMotorFromMap(data['detailMotor']) : null,
        detailUser: data['detailUser'] != null ? _parseUserFromMap(data['detailUser']) : null,
        catatanAdmin: data['catatanAdmin']?.toString().trim(),
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      );
    } catch (e) {
      throw Exception('Error parsing SewaModel from Firestore: $e');
    }
  }

  static MotorModel? _parseMotorFromMap(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    try {
      return MotorModel(
        id: data['id'] ?? '',
        nama: data['nama'] ?? '',
        merek: data['merek'] ?? '',
        tahun: data['tahun'] ?? DateTime.now().year,
        nomorPolisi: data['nomorPolisi'] ?? '',
        hargaSewa: data['hargaSewa'] ?? 0,
        status: MotorStatus.fromString(data['status'] ?? 'tersedia'),
        gambarUrl: data['gambarUrl'] ?? '',
      );
    } catch (e) {
      return null;
    }
  }

  static UserModel? _parseUserFromMap(dynamic data) {
    if (data is! Map<String, dynamic>) return null;
    try {
      return UserModel(
        uid: data['uid'] ?? '',
        nama: data['nama'] ?? '',
        email: data['email'] ?? '',
        role: UserRole.fromString(data['role'] ?? 'user'),
        nomorTelepon: data['nomorTelepon'] ?? '',
        alamat: data['alamat'] ?? '',
      );
    } catch (e) {
      return null;
    }
  }

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
      'catatanAdmin': catatanAdmin?.trim(),
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'updatedAt': Timestamp.fromDate(now),
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
    String? catatanAdmin,
    DateTime? createdAt,
    DateTime? updatedAt,
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
      catatanAdmin: catatanAdmin ?? this.catatanAdmin,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
        catatanAdmin,
        createdAt,
        updatedAt,
      ];
}
