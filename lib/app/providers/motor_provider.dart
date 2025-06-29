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

  // --- PERUBAHAN 1: Tambahkan state untuk pesan error ---
  String? _errorMessage;

  List<MotorModel> get motors => _motors;
  bool get isLoading => _isLoading;

  // --- PERUBAHAN 2: Tambahkan getter untuk pesan error ---
  String? get errorMessage => _errorMessage;

  MotorProvider() {
    fetchMotors();
  }

  void fetchMotors() {
    _isLoading = true;
    // --- PERUBAHAN 3: Reset pesan error setiap kali fetching dimulai ---
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

  Future<void> fetchMotorsManual() async {
    fetchMotors();
  }

  Future<void> addMotor(MotorModel motorData, File imageFile) async {
    try {
      String imageUrl = await _firestoreService.uploadMotorImage(imageFile);
      MotorModel motorComplete = MotorModel(
        id: motorData.id,
        nama: motorData.nama,
        merek: motorData.merek,
        tahun: motorData.tahun,
        nomorPolisi: motorData.nomorPolisi,
        hargaSewa: motorData.hargaSewa,
        status: motorData.status,
        gambarUrl: imageUrl,
      );
      await _firestoreService.addMotor(motorComplete);
      fetchMotors();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMotor(MotorModel motor, File? newImageFile) async {
    String imageUrl = motor.gambarUrl;
    if (newImageFile != null) {
      imageUrl = await _firestoreService.uploadMotorImage(newImageFile);
    }

    MotorModel updatedMotor = MotorModel(
      id: motor.id,
      nama: motor.nama,
      merek: motor.merek,
      tahun: motor.tahun,
      nomorPolisi: motor.nomorPolisi,
      hargaSewa: motor.hargaSewa,
      status: motor.status,
      gambarUrl: imageUrl,
    );
    await _firestoreService.updateMotor(motor.id, updatedMotor.toFirestore());
  }

  Future<void> deleteMotor(String motorId) async {
    await _firestoreService.deleteMotor(motorId);
  }

  @override
  void dispose() {
    _motorsSubscription?.cancel();
    super.dispose();
  }
}
