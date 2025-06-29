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
  bool _isLoading = true;
  String? _errorMessage;

  StreamSubscription? _authStateSubscription;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  AuthProvider() {
    _authStateSubscription = _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(firebase.User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _isLoading = false;
      notifyListeners();
      return;
    }
    
    // Set loading true saat mengambil data user dari firestore
    _isLoading = true;
    notifyListeners();

    try {
      DocumentSnapshot doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      if (doc.exists) {
        _user = UserModel.fromFirestore(doc);
      } else {
        _user = null;
      }
    } catch (e) {
      _user = null;
      _errorMessage = "Gagal mengambil data user: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- FUNGSI LOGIN YANG DIPERBAIKI ---
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    // Karena auth_service menangani error-nya sendiri dan mengembalikan null
    // jika gagal, kita cukup periksa hasilnya.
    final loggedInUser = await _authService.signInWithEmailAndPassword(email, password);

    // Jika login berhasil (hasilnya tidak null)
    if (loggedInUser != null) {
      // Kita tidak perlu melakukan apa-apa di sini.
      // Listener _onAuthStateChanged akan secara otomatis mendeteksi
      // perubahan state, mengambil data user, dan mengatur _isLoading = false.
      // Ini menjaga agar sumber kebenaran (source of truth) tetap satu.
      return true;
    } else {
      // Jika login GAGAL (hasilnya null)
      _errorMessage = "Login gagal. Periksa kembali email dan password Anda.";
      _isLoading = false; // INI BAGIAN PENTING YANG MEMPERBAIKI BUG
      notifyListeners();
      return false;
    }
  }

  // Fungsi Registrasi (disesuaikan juga untuk konsistensi)
  Future<bool> register(String nama, String email, String password, String nomorTelepon, String alamat) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final registeredUser = await _authService.registerWithEmailAndPassword(nama, email, password, nomorTelepon, alamat);

    if (registeredUser != null) {
      // Sukses, biarkan listener yang bekerja
      return true;
    } else {
      // Gagal
      _errorMessage = "Registrasi gagal. Email mungkin sudah terdaftar.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    super.dispose();
  }
}