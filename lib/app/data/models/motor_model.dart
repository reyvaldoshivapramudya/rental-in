import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';
import 'package:rentalin/app/data/models/motor_status.dart';

class MotorModel extends Equatable {
  final String id;
  final String nama;
  final String merek;
  final int tahun;
  final String nomorPolisi;
  final int hargaSewa;
  final MotorStatus status;
  final String gambarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const MotorModel({
    required this.id,
    required this.nama,
    required this.merek,
    required this.tahun,
    required this.nomorPolisi,
    required this.hargaSewa,
    required this.status,
    required this.gambarUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory MotorModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) throw Exception('Document data is null');

      return MotorModel(
        id: doc.id,
        nama: data['nama']?.toString().trim() ?? '',
        merek: data['merek']?.toString().trim() ?? '',
        tahun: data['tahun'] as int? ?? DateTime.now().year,
        nomorPolisi: data['nomorPolisi']?.toString().trim().toUpperCase() ?? '',
        hargaSewa: data['hargaSewa'] as int? ?? 0,
        status: MotorStatus.fromString(data['status']?.toString() ?? 'tersedia'),
        gambarUrl: data['gambarUrl']?.toString().trim() ?? '',
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      );
    } catch (e) {
      throw Exception('Error parsing MotorModel from Firestore: $e');
    }
  }

  Map<String, dynamic> toFirestore() {
    final now = DateTime.now();
    return {
      'nama': nama.trim(),
      'merek': merek.trim(),
      'tahun': tahun,
      'nomorPolisi': nomorPolisi.trim().toUpperCase(),
      'hargaSewa': hargaSewa,
      'status': status.value,
      'gambarUrl': gambarUrl.trim(),
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': Timestamp.fromDate(now),
    };
  }

  MotorModel copyWith({
    String? id,
    String? nama,
    String? merek,
    int? tahun,
    String? nomorPolisi,
    int? hargaSewa,
    MotorStatus? status,
    String? gambarUrl,
    String? deskripsi,
    String? warna,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MotorModel(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      merek: merek ?? this.merek,
      tahun: tahun ?? this.tahun,
      nomorPolisi: nomorPolisi ?? this.nomorPolisi,
      hargaSewa: hargaSewa ?? this.hargaSewa,
      status: status ?? this.status,
      gambarUrl: gambarUrl ?? this.gambarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Computed properties
  bool get isAvailable => status == MotorStatus.tersedia;
  bool get isRented => status == MotorStatus.disewa;
  bool get isConfirmed => status == MotorStatus.menungguKonfirmasi;

  String get formattedPrice =>
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0)
          .format(hargaSewa);

  String get spesifikasiLengkap => '$merek $nama ($jenisMotor)';

  String get jenisMotor => 'Matic';
  String get bahanBakar => 'Bensin';

  @override
  List<Object?> get props => [
        id,
        nama,
        merek,
        tahun,
        nomorPolisi,
        hargaSewa,
        status,
        gambarUrl,
        createdAt,
        updatedAt,
      ];
}
