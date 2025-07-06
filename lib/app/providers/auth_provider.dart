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
      } else {
        await savePlayerIdToFirestore(
          loggedInUser.uid,
        ); // 🔔 Simpan playerId saat login
      }
    } catch (e) {
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
