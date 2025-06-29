import 'package:cloud_firestore/cloud_firestore.dart';

class SewaModel {
  final String id;
  final String userId;
  final String motorId;
  final Timestamp tanggalSewa;
  final Timestamp tanggalKembali;
  final int totalBiaya;
  final String
  statusPemesanan; // e.g., "Menunggu Konfirmasi", "Dikonfirmasi", "Selesai", "Ditolak"
  // Anda bisa tambahkan field lain seperti data motor dan user untuk kemudahan display
  final Map<String, dynamic> detailMotor;
  final Map<String, dynamic> detailUser;

  SewaModel({
    required this.id,
    required this.userId,
    required this.motorId,
    required this.tanggalSewa,
    required this.tanggalKembali,
    required this.totalBiaya,
    required this.statusPemesanan,
    required this.detailMotor,
    required this.detailUser,
  });

  // Factory constructor to create a SewaModel from a Firestore document
  factory SewaModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return SewaModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      motorId: data['motorId'] ?? '',
      tanggalSewa: data['tanggalSewa'] ?? Timestamp.now(),
      tanggalKembali: data['tanggalKembali'] ?? Timestamp.now(),
      totalBiaya: data['totalBiaya'] ?? 0,
      statusPemesanan: data['statusPemesanan'] ?? 'Menunggu Konfirmasi',
      detailMotor: data['detailMotor'] ?? {},
      detailUser: data['detailUser'] ?? {},
    );
  }

  // Method to convert SewaModel instance to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'motorId': motorId,
      'tanggalSewa': tanggalSewa,
      'tanggalKembali': tanggalKembali,
      'totalBiaya': totalBiaya,
      'statusPemesanan': statusPemesanan,
      'detailMotor': detailMotor,
      'detailUser': detailUser,
    };
  }
}
