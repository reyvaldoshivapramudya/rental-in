import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rentalin/app/data/models/motor_status.dart';
import 'package:rentalin/app/data/models/status_pemesanan.dart';
import '../data/models/motor_model.dart';
import '../data/models/sewa_model.dart';
import '../data/models/user_model.dart';
import '../data/services/firestore_service.dart';

class SewaProvider with ChangeNotifier {
  final FirestoreService _firestoreService = FirestoreService();

  // State untuk Admin
  StreamSubscription? _adminSewaSubscription;
  List<SewaModel> _adminSewaList = [];
  List<SewaModel> get sewaList => _adminSewaList; // Ini untuk admin

  // --- STATE UNTUK USER ---
  StreamSubscription? _userSewaSubscription;
  List<SewaModel> _userSewaList = [];
  List<SewaModel> get userSewaList => _userSewaList; // Ini untuk user

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // --- STATE BARU UNTUK VALIDASI JADWAL ---
  List<SewaModel> _bookedSchedules = [];
  List<SewaModel> get bookedSchedules => _bookedSchedules;

  bool _isCheckingSchedule = false;
  bool get isCheckingSchedule => _isCheckingSchedule;

  SewaProvider();

  // Mengambil semua data sewa untuk Admin
  void fetchAllSewaForAdmin() {
    _isLoading = true;
    notifyListeners();
    _adminSewaSubscription?.cancel();
    _adminSewaSubscription = _firestoreService.getAllSewa().listen(
      (sewa) {
        _adminSewaList = sewa;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _errorMessage = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Mengambil data sewa untuk user yang sedang login
  void fetchSewaForCurrentUser(String userId) {
    _isLoading = true;
    notifyListeners();
    _userSewaSubscription?.cancel();
    _userSewaSubscription = _firestoreService
        .getSewaByUserId(userId)
        .listen(
          (sewa) {
            _userSewaList = sewa;
            _isLoading = false;
            notifyListeners();
          },
          onError: (e) {
            _errorMessage = e.toString();
            _isLoading = false;
            notifyListeners();
          },
        );
  }

  // --- FUNGSI BARU UNTUK MENGAMBIL JADWAL YANG SUDAH DIPESAN ---
  Future<void> fetchBookedDates(String motorId) async {
    _isCheckingSchedule = true;
    notifyListeners();

    _bookedSchedules = await _firestoreService.getBookingsForMotor(motorId);

    _isCheckingSchedule = false;
    notifyListeners();
  }

  // --- FUNGSI BARU UNTUK MEMBERSIHKAN STATE ---
  // Penting untuk dipanggil saat keluar dari halaman booking
  void clearBookedDates() {
    _bookedSchedules = [];
  }

  // --- FUNGSI BARU UNTUK MEMBERSIHKAN DATA USER ---
  void clearUserSewaData() {
    _userSewaSubscription?.cancel();
    _userSewaList = [];
    // Kita tidak perlu notifyListeners() agar tidak menyebabkan error state
    // saat proses logout.
  }

  // --- FUNGSI BARU YANG DITAMBAHKAN ---
  // Fungsi ini akan dipanggil dari dispose() di HistoryScreen
  void cancelUserSewaStream() {
    _userSewaSubscription?.cancel();
  }

  Future<bool> createSewa({
    required UserModel user,
    required MotorModel motor,
    required DateTime tanggalSewa,
    required DateTime tanggalKembali,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final int durasiHari = tanggalKembali.difference(tanggalSewa).inDays + 1;
      final int totalBiaya = durasiHari * motor.hargaSewa;

      final sewaBaru = SewaModel(
        id: '',
        userId: user.uid,
        motorId: motor.id,
        tanggalSewa: tanggalSewa,
        tanggalKembali: tanggalKembali,
        totalBiaya: totalBiaya,
        statusPemesanan: StatusPemesanan.menungguKonfirmasi,
        detailMotor: motor,
        detailUser: user,
      );

      await _firestoreService.addSewa(sewaBaru);
      await _firestoreService.updateMotorStatus(motor.id, MotorStatus.disewa);

      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> konfirmasiTolakPemesanan(
    String sewaId,
    String motorId,
    bool isKonfirmasi,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (isKonfirmasi) {
        await _firestoreService.updateSewaStatus(sewaId, 'Dikonfirmasi');
        await _firestoreService.updateMotorStatus(motorId, MotorStatus.disewa);
      } else {
        await _firestoreService.updateSewaStatus(sewaId, 'Ditolak');
        await _firestoreService.updateMotorStatus(
          motorId,
          MotorStatus.tersedia,
        );
      }
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selesaikanSewa(String sewaId, String motorId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _firestoreService.updateSewaStatus(sewaId, 'Selesai');
      await _firestoreService.updateMotorStatus(motorId, MotorStatus.tersedia);
    } catch (e) {
      _errorMessage = e.toString();
      print('Error menyelesaikan sewa: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _adminSewaSubscription?.cancel();
    _userSewaSubscription?.cancel();
    super.dispose();
  }
}
