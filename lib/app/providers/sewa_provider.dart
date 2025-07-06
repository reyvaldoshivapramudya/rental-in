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
      (sewaList) async {
        // 🔴 Tambahkan populate user dan motor
        final populatedList = await Future.wait(
          sewaList.map((sewa) async {
            final motor = await _firestoreService.getMotorById(sewa.motorId);
            final user = await _firestoreService.getUserById(sewa.userId);

            return sewa.copyWith(detailMotor: motor, detailUser: user);
          }),
        );

        _adminSewaList = populatedList;
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
  Future<void> fetchSewaForCurrentUser(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();
      print('Fetching sewa for user $userId');

      final sewaStream = _firestoreService.getSewaByUserId(userId);

      _userSewaSubscription?.cancel();
      _userSewaSubscription = sewaStream.listen((sewaList) async {
        print('Sewa stream returned: ${sewaList.length} items');

        if (sewaList.isEmpty) {
          _userSewaList = [];
          _isLoading = false;
          notifyListeners();
          return;
        }

        final populatedList = await Future.wait(
          sewaList.map((sewa) async {
            try {
              final motor = await _firestoreService.getMotorById(sewa.motorId);
              print('Fetched motor ${motor?.nama} for sewa ${sewa.id}');
              return sewa.copyWith(detailMotor: motor);
            } catch (e) {
              print('Error fetching motor for sewa ${sewa.id}: $e');
              return sewa;
            }
          }),
        );

        _userSewaList = populatedList;
        _isLoading = false;
        notifyListeners();
        print('Finished populating sewa list');
      });
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      print('Error fetchSewaForCurrentUser: $e');
    }
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

  int hitungKeterlambatan(DateTime dueDate, DateTime actualReturnDate) {
    final diff = actualReturnDate.difference(dueDate).inDays;
    return diff > 0 ? diff : 0;
  }

  int hitungTotalDenda(int keterlambatan, int dendaPerHari) {
    return keterlambatan * dendaPerHari;
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

      // 🛑 Jangan ubah status motor menjadi disewa langsung di sini.
      // ✅ Ubah menjadi menungguKonfirmasi.
      await _firestoreService.updateMotorStatus(
        motor.id,
        MotorStatus.menungguKonfirmasi,
      );

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
      // Cari sewa terkait dari _adminSewaList
      final sewa = _adminSewaList.firstWhere((s) => s.id == sewaId);

      // Ambil playerId dari detailUser
      final userPlayerId = sewa.detailUser?.playerId;

      if (userPlayerId == null) {
        throw Exception('Player ID user tidak ditemukan.');
      }

      await _firestoreService.updateSewaStatusAndMotor(
        sewaId,
        motorId,
        isKonfirmasi ? 'Dikonfirmasi' : 'Ditolak',
        isKonfirmasi ? 'disewa' : 'tersedia',
        userPlayerId, // ⬅️ tambahkan di sini
      );
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> selesaikanSewa(
    String sewaId,
    String motorId, {
    DateTime? tanggalPengembalianAktual,
    int? totalDenda,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final now = DateTime.now();
      final tanggalPengembalian = tanggalPengembalianAktual ?? now;

      final sewa = _adminSewaList.firstWhere((s) => s.id == sewaId);

      // Ambil playerId dari detailUser
      final userPlayerId = sewa.detailUser?.playerId;

      if (userPlayerId == null) {
        throw Exception('Player ID user tidak ditemukan.');
      }

      final keterlambatan = hitungKeterlambatan(
        sewa.tanggalKembali,
        tanggalPengembalian,
      );
      final dendaPerHari = 20000;

      final totalDendaFinal =
          totalDenda ?? hitungTotalDenda(keterlambatan, dendaPerHari);

      await _firestoreService.updateSewaOnComplete(
        sewaId: sewaId,
        motorId: motorId,
        tanggalPengembalianAktual: tanggalPengembalian,
        status: 'Selesai',
        totalDenda: totalDendaFinal,
        userPlayerId: userPlayerId, // ⬅️ tambahkan ini
      );

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
