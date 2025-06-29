// auth_provider.dart

import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import '../data/models/user_model.dart';
import '../data/services/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _user;
  bool _isLoading = true; // Loading awal saat app dibuka

  StreamSubscription? _authStateSubscription;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  AuthProvider() {
    _authStateSubscription = _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(firebase.User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      if (_isLoading) _isLoading = false;
      notifyListeners();
      return;
    }
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        _user = UserModel.fromFirestore(doc);
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

  /// Melakukan proses login.
  /// Akan `throw Exception` jika gagal.
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners(); // Memberi tahu UI untuk menampilkan loading spinner

    try {
      final loggedInUser = await _authService.signInWithEmailAndPassword(email, password);
      
      // Jika service mengembalikan null, artinya login gagal.
      if (loggedInUser == null) {
        throw Exception("Email atau password yang Anda masukkan salah.");
      }
      // Jika berhasil, listener _onAuthStateChanged akan menangani sisanya.
      // isLoading akan di-set false oleh listener tersebut.
    } catch (e) {
      // Jika terjadi error dari service atau dari throw di atas
      _isLoading = false;
      notifyListeners(); // Beri tahu UI untuk MENGHENTIKAN loading spinner
      rethrow; // Lempar kembali error-nya agar bisa ditangkap oleh UI (LoginScreen)
    }
  }

  /// Melakukan proses registrasi.
  /// Akan `throw Exception` jika gagal.
  Future<void> register(String nama, String email, String password, String nomorTelepon, String alamat) async {
    _isLoading = true;
    notifyListeners();

    try {
      final registeredUser = await _authService.registerWithEmailAndPassword(nama, email, password, nomorTelepon, alamat);

      if (registeredUser == null) {
        throw Exception("Registrasi gagal. Email mungkin sudah terdaftar.");
      }
      // Jika berhasil, listener akan menangani sisanya.
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    // User akan null & loading akan false via listener
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}