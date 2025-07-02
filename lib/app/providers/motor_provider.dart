import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../data/models/motor_model.dart';
import '../data/services/firestore_service.dart';

class MotorProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();
  List<MotorModel> _motors = [];
  StreamSubscription? _motorsSubscription;
  bool _isLoading = false;
  String? _errorMessage;

  List<MotorModel> get motors => _motors;
  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  MotorProvider() {
    fetchMotors();
  }

  void fetchMotors() {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    _motorsSubscription?.cancel();
    _motorsSubscription = _firestoreService.getMotors().listen(
      (motors) {
        _motors = motors;
        _isLoading = false;
        // Pastikan error message kosong jika sukses
        _errorMessage = null;
        notifyListeners();
      },
      onError: (error) {
        // --- PERUBAHAN 4: Simpan pesan error ke dalam state ---
        _errorMessage = "Gagal memuat data motor: $error";
        print(_errorMessage); // Print tetap berguna untuk debugging
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> refreshMotors() async {
    fetchMotors();
    notifyListeners();
  }

  Future<String> addMotor(MotorModel motorData, File imageFile) async {
    try {
      String imageUrl = await _firestoreService.uploadMotorImage(imageFile);
      MotorModel motorComplete = motorData.copyWith(gambarUrl: imageUrl);
      String newMotorId = await _firestoreService.addMotor(motorComplete);
      fetchMotors();
      return newMotorId;
    } catch (e) {
      _errorMessage = 'Gagal menambahkan motor: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateMotor(MotorModel motor, File? newImageFile) async {
    try {
      String imageUrl = motor.gambarUrl;
      if (newImageFile != null) {
        imageUrl = await _firestoreService.uploadMotorImage(newImageFile);
      }

      MotorModel updatedMotor = motor.copyWith(gambarUrl: imageUrl);
      await _firestoreService.updateMotor(motor.id, updatedMotor.toFirestore());
      fetchMotors();
    } catch (e) {
      _errorMessage = 'Gagal mengupdate motor: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteMotor(String motorId) async {
    try {
      await _firestoreService.deleteMotor(motorId);
      fetchMotors();
    } catch (e) {
      _errorMessage = 'Gagal menghapus motor: $e';
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _motorsSubscription?.cancel();
    super.dispose();
  }
}
