import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rentalin/app/data/models/motor_status.dart';
import 'package:rentalin/app/data/models/sewa_model.dart';
import 'package:rentalin/app/data/models/status_pemesanan.dart';
import 'package:rentalin/app/data/models/user_model.dart';
import 'package:rentalin/app/data/services/onesignal_service.dart';
import '../models/motor_model.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final CloudinaryPublic cloudinary = CloudinaryPublic(
    dotenv.env['CLOUDINARY_CLOUD_NAME']!,
    dotenv.env['CLOUDINARY_UPLOAD_PRESET']!,
    cache: false,
  );

  /// 🔷 Mendapatkan stream semua motor
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

  /// 🔷 Upload gambar motor ke Cloudinary
  Future<String> uploadMotorImage(File imageFile) async {
    try {
      CloudinaryResponse response = await cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imageFile.path,
          resourceType: CloudinaryResourceType.Image,
        ),
      );
      return response.secureUrl;
    } on CloudinaryException catch (e) {
      throw Exception('Gagal mengupload gambar: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  /// 🔷 Validasi jadwal sewa motor tertentu
  Future<List<SewaModel>> getBookingsForMotor(String motorId) async {
    try {
      final snapshot = await _db
          .collection('sewa')
          .where('motorId', isEqualTo: motorId)
          .where(
            'statusPemesanan',
            whereIn: [
              StatusPemesanan.menungguKonfirmasi.value,
              StatusPemesanan.dikonfirmasi.value,
            ],
          )
          .get();

      return snapshot.docs.map((doc) => SewaModel.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting bookings for motor: $e');
      return [];
    }
  }

  /// 🔷 Stream semua data sewa
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

  /// 🔷 Tambah motor
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

  /// 🔷 Tambah sewa baru + kirim notifikasi ke admin
  Future<String> addSewa(SewaModel sewa) async {
    DocumentReference docRef = await _db
        .collection('sewa')
        .add(sewa.toFirestore());

    // 🔔 Kirim notifikasi ke admin setelah booking berhasil
    await _notifyAdminOnNewBooking(sewa);

    return docRef.id;
  }

  /// 🔷 Kirim notifikasi ke admin saat ada booking baru
  Future<void> _notifyAdminOnNewBooking(SewaModel sewa) async {
    try {
      final adminPlayerId = await getAdminPlayerId();

      if (adminPlayerId != null) {
        await OneSignalService.sendNotification(
          playerId: adminPlayerId,
          title: "Booking Baru",
          message:
              "Ada booking baru nih! dari ${sewa.detailUser?.nama ?? 'user'} yang harus dikonfirmasi🛒",
        );
        print('✅ Notifikasi booking baru berhasil dikirim ke admin');
      } else {
        print('⚠️ Admin playerId tidak ditemukan. Notifikasi tidak dikirim.');
      }
    } catch (e) {
      print('❌ Error notifyAdminOnNewBooking: $e');
    }
  }

  /// 🔷 Update motor (umum)
  Future<void> updateMotor(String motorId, Map<String, dynamic> data) {
    return _db.collection('motors').doc(motorId).update(data);
  }

  /// 🔷 Delete motor
  Future<void> deleteMotor(String motorId) {
    return _db.collection('motors').doc(motorId).delete();
  }

  /// 🔷 Update status motor
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

  /// 🔷 Update status pemesanan
  Future<void> updateSewaStatus(String sewaId, String newStatus) {
    return _db.collection('sewa').doc(sewaId).update({
      'statusPemesanan': newStatus.toLowerCase(),
    });
  }

  /// 🔷 Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    final doc = await _db.collection('users').doc(userId).get();
    if (doc.exists) {
      return UserModel.fromFirestore(doc);
    }
    return null;
  }

  /// 🔷 Update status sewa dan motor sekaligus (konfirmasi/tolak)
  Future<void> updateSewaStatusAndMotor(
    String sewaId,
    String motorId,
    String newStatusSewa,
    String newStatusMotor,
    String userPlayerId, // ⬅️ tambahkan playerId user di parameter
  ) async {
    WriteBatch batch = _db.batch();

    DocumentReference sewaRef = _db.collection('sewa').doc(sewaId);
    DocumentReference motorRef = _db.collection('motors').doc(motorId);

    batch.update(sewaRef, {'statusPemesanan': newStatusSewa.toLowerCase()});
    batch.update(motorRef, {'status': newStatusMotor.toLowerCase()});

    // Commit batch
    await batch.commit();
  }

  /// 🔷 Update sewa saat selesai
  Future<void> updateSewaOnComplete({
    required String sewaId,
    required String motorId,
    required DateTime tanggalPengembalianAktual,
    required String status,
    required int totalDenda,
    required String userPlayerId, // ⬅️ tambahkan playerId user
  }) async {
    WriteBatch batch = _db.batch();

    DocumentReference sewaRef = _db.collection('sewa').doc(sewaId);
    DocumentReference motorRef = _db.collection('motors').doc(motorId);

    batch.update(sewaRef, {
      'statusPemesanan': status.toLowerCase(),
      'tanggalPengembalianAktual': Timestamp.fromDate(
        tanggalPengembalianAktual,
      ),
      'totalDenda': totalDenda,
    });

    batch.update(motorRef, {'status': 'tersedia'});

    await batch.commit();
  }

  /// 🔷 Stream data sewa berdasarkan userId
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

  /// 🔷 Get motor by ID (✅ diubah menjadi nullable + logging error)
  Future<MotorModel?> getMotorById(String motorId) async {
    try {
      final snapshot = await _db.collection('motors').doc(motorId).get();
      if (snapshot.exists) {
        return MotorModel.fromFirestore(snapshot);
      } else {
        print('Motor dengan ID $motorId tidak ditemukan.');
        return null;
      }
    } catch (e) {
      print('Error getMotorById: $e');
      return null;
    }
  }

  Future<void> updateUserPlayerId(String userId, String playerId) async {
    await _db.collection('users').doc(userId).update({'playerId': playerId});
  }

  Future<String?> getAdminPlayerId() async {
    try {
      final snapshot = await _db
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final admin = UserModel.fromFirestore(snapshot.docs.first);
        return admin.playerId;
      }
    } catch (e) {
      print('Error getAdminPlayerId: $e');
    }
    return null;
  }

  /// 🔷 Kirim notifikasi ke user tertentu
  Future<void> sendNotificationToUser(
    String playerId,
    String title,
    String message,
  ) async {
    try {
      await OneSignalService.sendNotification(
        playerId: playerId,
        title: title,
        message: message,
      );
    } catch (e) {
      print('Error sending notification: $e');
    }
  }
}
