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
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Melakukan proses login. Akan `throw Exception` jika gagal.
  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final loggedInUser = await _authService.signInWithEmailAndPassword(email, password);

    if (loggedInUser == null) {
      _isLoading = false;
      notifyListeners();
      throw Exception("Login gagal. Periksa kembali email dan password Anda.");
    }
    // Jika sukses, listener _onAuthStateChanged akan mengatur state loading dan user.
  }

  /// Melakukan proses registrasi. Akan `throw Exception` jika gagal.
  Future<void> register(String nama, String email, String password, String nomorTelepon, String alamat) async {
    _isLoading = true;
    notifyListeners();

    final registeredUser = await _authService.registerWithEmailAndPassword(nama, email, password, nomorTelepon, alamat);

    if (registeredUser == null) {
      _isLoading = false;
      notifyListeners();
      throw Exception("Registrasi gagal. Email mungkin sudah terdaftar.");
    }
    // Jika sukses, listener _onAuthStateChanged akan mengatur state loading dan user.
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