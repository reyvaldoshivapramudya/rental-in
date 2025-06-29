import 'package:cloud_firestore/cloud_firestore.dart';

class MotorModel {
  final String id;
  final String nama;
  final String merek;
  final int tahun;
  final String nomorPolisi;
  final int hargaSewa; // Harga sewa per hari
  final String status; // e.g., "Tersedia", "Disewa"
  final String gambarUrl;

  MotorModel({
    required this.id,
    required this.nama,
    required this.merek,
    required this.tahun,
    required this.nomorPolisi,
    required this.hargaSewa,
    required this.status,
    required this.gambarUrl,
  });

  // Factory constructor untuk membuat MotorModel dari dokumen Firestore
  factory MotorModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return MotorModel(
      id: doc.id,
      nama: data['nama'] ?? '',
      merek: data['merek'] ?? '',
      tahun: data['tahun'] ?? 0,
      nomorPolisi: data['nomorPolisi'] ?? '',
      hargaSewa: data['hargaSewa'] ?? 0,
      status: data['status'] ?? 'Tersedia',
      gambarUrl: data['gambarUrl'] ?? '',
    );
  }

  // Method untuk mengubah instance MotorModel menjadi map untuk Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nama': nama,
      'merek': merek,
      'tahun': tahun,
      'nomorPolisi': nomorPolisi,
      'hargaSewa': hargaSewa,
      'status': status,
      'gambarUrl': gambarUrl,
    };
  }
}
