import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentalin/app/data/models/user_model.dart';

class UserProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<UserModel> _renters = [];
  List<UserModel> get renters => _renters;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Mengambil semua data user dengan role 'user'
  Future<void> fetchAllRenters() async {
    _isLoading = true;
    notifyListeners();
    try {
      final snapshot = await _firestore
          .collection('users')
          .where('role', isEqualTo: 'user')
          .get();
      _renters = snapshot.docs
          .map((doc) => UserModel.fromFirestore(doc))
          .toList();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Memperbarui data user di Firestore
  Future<bool> updateUserData({
    required String uid,
    required String nama,
    required String email,
    required String nomorTelepon,
    required String alamat,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _firestore.collection('users').doc(uid).update({
        'nama': nama,
        'email': email,
        'nomorTelepon': nomorTelepon,
        'alamat': alamat,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      // Perbarui juga data di list lokal agar UI langsung update
      await fetchAllRenters();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mengubah status blokir pengguna di Firestore dan Firebase Auth.
  Future<bool> toggleBlockStatus(String uid, bool isCurrentlyBlocked) async {
    _isLoading = true;
    notifyListeners();
    try {
      final bool newBlockStatus = !isCurrentlyBlocked;

      // KITA HANYA MENGUBAH FLAG DI FIRESTORE UNTUK SAAT INI
      await _firestore.collection('users').doc(uid).update({
        'isBlocked': newBlockStatus,
      });

      // Perbarui daftar lokal untuk me-refresh UI secara instan
      final index = _renters.indexWhere((user) => user.uid == uid);
      if (index != -1) {
        _renters[index] = _renters[index].copyWith(isBlocked: newBlockStatus);
      }

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint("Error toggling block status: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
