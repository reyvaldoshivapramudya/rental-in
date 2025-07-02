import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rentalin/app/data/models/motor_status.dart';
import 'package:rentalin/app/data/models/sewa_model.dart';
import 'package:rentalin/app/data/models/status_pemesanan.dart';
import '../models/motor_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final CloudinaryPublic cloudinary = CloudinaryPublic(
    dotenv.env['CLOUDINARY_CLOUD_NAME']!,
    dotenv.env['CLOUDINARY_UPLOAD_PRESET']!,
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

  Future<String> uploadMotorImage(File imageFile) async {
    try {
      // Membuat request ke Cloudinary menggunakan package
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      // URL yang aman (https) sudah disediakan oleh package
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      throw Exception('Gagal mengupload gambar: ${e.message}');
    } catch (e) {
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
          .where(
            'statusPemesanan',
            whereIn: [
              StatusPemesanan.menungguKonfirmasi,
              StatusPemesanan.dikonfirmasi,
            ],
          )
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

  Future<String> addMotor(MotorModel motor) async {
    try {
      DocumentReference docRef = await _db
          .collection('motors')
          .add(motor.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error adding motor: $e');
      rethrow;
    }
  }

  // Menambah data sewa baru
  Future<String> addSewa(SewaModel sewa) async {
    DocumentReference docRef = await _db
        .collection('sewa')
        .add(sewa.toFirestore());
    return docRef.id;
  }

  Future<void> updateMotor(String motorId, Map<String, dynamic> data) {
    return _db.collection('motors').doc(motorId).update(data);
  }

  Future<void> deleteMotor(String motorId) {
    // TODO: Nantinya bisa ditambahkan logika untuk menghapus gambar di Cloudinary juga.
    return _db.collection('motors').doc(motorId).delete();
  }

  Future<void> updateMotorStatus(String motorId, MotorStatus newStatus) async {
    try {
      await _db.collection('motors').doc(motorId).update({
        'status': newStatus.value,
      });
    } catch (e) {
      print('Error updating motor status: $e');
      rethrow;
    }
  }

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
