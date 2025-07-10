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
}
