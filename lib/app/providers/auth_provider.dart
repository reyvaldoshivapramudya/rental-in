import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:rentalin/app/data/services/firestore_service.dart';
import 'package:rentalin/utils/auth_exception.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _user;
  bool _isLoading = true;

  StreamSubscription? _authStateSubscription;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _authStateSubscription = _authService.authStateChanges.listen(
      _onAuthStateChanged,
    );
  }

  Future<void> savePlayerIdToFirestore(String userId) async {
    try {
      final user = OneSignal.User;
      final playerId = user.pushSubscription.id;

      if (playerId != null) {
        await FirestoreService().updateUserPlayerId(userId, playerId);
        print('✅ Player ID saved to Firestore for user: $userId');
      }
    } catch (e) {
      print('❌ Gagal menyimpan playerId: $e');
    }
  }

  Future<void> _onAuthStateChanged(firebase.User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      if (_isLoading) _isLoading = false;
      notifyListeners();
      return;
    }
    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (doc.exists) {
        _user = UserModel.fromFirestore(doc);
        await savePlayerIdToFirestore(
          firebaseUser.uid,
        ); // 🔔 Simpan playerId saat login otomatis
      } else {
        _user = null;
        await _authService.signOut();
      }
    } catch (e) {
      _user = null;
    } finally {
      if (_isLoading) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final loggedInUser = await _authService.signInWithEmailAndPassword(
        email,
        password,
      );

      if (loggedInUser == null) {
        throw AuthException(
          message: "Email atau password yang Anda masukkan salah.",
        );
      }

      // TAMBAHAN: Periksa status blokir di Firestore setelah login berhasil
      final userDoc = await _firestore
          .collection('users')
          .doc(loggedInUser.uid)
          .get();
      if (userDoc.exists && (userDoc.data()?['isBlocked'] == true)) {
        // Jika user diblokir, langsung logout lagi dari Firebase Auth
        await _authService.signOut();
        // Lempar error khusus yang akan ditangkap oleh UI
        throw AuthException(
          message:
              'Maaf, Akun ${loggedInUser.nama} telah diblokir. Karena telah melanggar kebijakan dari perusahaan kami.',
        );
      } else {
        // Jika tidak diblokir, lanjutkan simpan playerId
        await savePlayerIdToFirestore(loggedInUser.uid);
      }
    } catch (e) {
      // Rethrow akan meneruskan error (baik dari login gagal atau akun diblokir) ke UI
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(
    String nama,
    String email,
    String password,
    String nomorTelepon,
    String alamat,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final registeredUser = await _authService.registerWithEmailAndPassword(
        nama,
        email,
        password,
        nomorTelepon,
        alamat,
      );
      if (registeredUser == null) {
        throw AuthException(
          message: "Registrasi gagal. Email mungkin sudah terdaftar.",
        );
      } else {
        await savePlayerIdToFirestore(
          registeredUser.uid,
        ); // 🔔 Simpan playerId saat register
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Memperbarui nama dari user yang sedang login.
  Future<bool> updateUserName(String newName) async {
    // Pastikan ada user yang sedang login
    if (_user == null) return false;

    try {
      // 1. Update nama di dokumen Firestore
      await _firestore.collection('users').doc(_user!.uid).update({
        'nama': newName,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 2. Buat object user baru dengan nama yang sudah diupdate
      //    Penting agar data lokal di aplikasi ikut berubah
      _user = _user!.copyWith(nama: newName);

      // 3. Beri tahu semua widget yang mendengarkan bahwa ada perubahan
      notifyListeners();

      return true;
    } catch (e) {
      // Handle error jika diperlukan
      print('Error updating user name: $e');
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    await _authService.signOut();

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}
