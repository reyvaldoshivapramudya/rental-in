import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:rentalin/app/data/models/sewa_model.dart'; 
import '../models/motor_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Inisialisasi Cloudinary di sini. Lebih efisien.
  // GANTI 'NAMA_CLOUD_ANDA' dan 'NAMA_UPLOAD_PRESET_ANDA' dengan kredensial Anda.
  final CloudinaryPublic cloudinary = CloudinaryPublic(
    'dbbh6ei1o', // <-- Ganti dengan Cloud Name Anda
    'rentalin', // <-- Ganti dengan nama Upload Preset (unsigned)
    cache: false,
  );

  Stream<List<MotorModel>> getMotors() {
    return _db
        .collection('motors')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => MotorModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// --- FUNGSI UPLOAD GAMBAR DENGAN SOLUSI FINAL ---
  /// Menggunakan package `cloudinary_public` yang lebih sesuai untuk Flutter.
  Future<String> uploadMotorImage(File imageFile) async {
    try {
      print('[CLOUDINARY_PUBLIC_DEBUG] Memulai upload gambar...');

      // Membuat request ke Cloudinary menggunakan package
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      // URL yang aman (https) sudah disediakan oleh package
      print(
        '[CLOUDINARY_PUBLIC_DEBUG] SUKSES! URL Gambar: ${response.secureUrl}',
      );
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      print('[CLOUDINARY_PUBLIC_DEBUG] GAGAL! Error: ${e.message}');
      print(e.request);
      throw Exception('Gagal mengupload gambar: ${e.message}');
    } catch (e) {
      print('[CLOUDINARY_PUBLIC_DEBUG] Terjadi error tidak terduga: $e');
      rethrow;
    }
  }

  // --- FUNGSI BARU UNTUK VALIDASI JADWAL ---
  // Mengambil semua data sewa yang relevan untuk satu motor spesifik
  Future<List<SewaModel>> getBookingsForMotor(String motorId) async {
    try {
      final snapshot = await _db
          .collection('sewa')
          .where('motorId', isEqualTo: motorId)
          // Ambil pesanan yang statusnya membuat motor tidak tersedia
          .where('statusPemesanan', whereIn: ['Menunggu Konfirmasi', 'Dikonfirmasi'])
          .get();
      
      return snapshot.docs.map((doc) => SewaModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting bookings for motor: $e');
      return []; // Kembalikan list kosong jika terjadi error
    }
  }

  // Mengambil stream semua data sewa, diurutkan dari yang terbaru
  Stream<List<SewaModel>> getAllSewa() {
    return _db
        .collection('sewa')
        .orderBy('tanggalSewa', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => SewaModel.fromFirestore(doc)).toList(),
        );
  }

  Future<void> addMotor(MotorModel motor) {
    return _db.collection('motors').add(motor.toFirestore());
  }

  // Menambah data sewa baru
  Future<void> addSewa(SewaModel sewa) {
    return _db.collection('sewa').add(sewa.toFirestore());
  }

  Future<void> updateMotor(String motorId, Map<String, dynamic> data) {
    return _db.collection('motors').doc(motorId).update(data);
  }

  Future<void> deleteMotor(String motorId) {
    // TODO: Nantinya bisa ditambahkan logika untuk menghapus gambar di Cloudinary juga.
    return _db.collection('motors').doc(motorId).delete();
  }

  // Mengubah status motor (misal: dari "Tersedia" menjadi "Disewa")
  Future<void> updateMotorStatus(String motorId, String newStatus) {
    return _db.collection('motors').doc(motorId).update({'status': newStatus});
  }

  // --- FUNGSI BARU ---
  // Mengubah status pemesanan
  Future<void> updateSewaStatus(String sewaId, String newStatus) {
    return _db.collection('sewa').doc(sewaId).update({
      'statusPemesanan': newStatus,
    });
  }

  Stream<List<SewaModel>> getSewaByUserId(String userId) {
    return _db
        .collection('sewa')
        .where('userId', isEqualTo: userId)
        .orderBy('tanggalSewa', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => SewaModel.fromFirestore(doc)).toList(),
        );
  }
}
