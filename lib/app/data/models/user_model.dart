import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:rentalin/app/data/models/user_role.dart';

class UserModel extends Equatable {
  final String uid;
  final String nama;
  final String email;
  final UserRole role;
  final String nomorTelepon;
  final String alamat;
  final String? playerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isBlocked;

  const UserModel({
    required this.uid,
    required this.nama,
    required this.email,
    required this.role,
    required this.nomorTelepon,
    required this.alamat,
    this.playerId,
    this.createdAt,
    this.updatedAt,
    this.isBlocked = false, 
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>?;
      if (data == null) throw Exception('Document data is null');

      return UserModel(
        uid: doc.id,
        nama: data['nama']?.toString().trim() ?? '',
        email: data['email']?.toString().toLowerCase().trim() ?? '',
        role: UserRole.fromString(data['role']?.toString() ?? 'user'),
        nomorTelepon: data['nomorTelepon']?.toString().trim() ?? '',
        alamat: data['alamat']?.toString().trim() ?? '',
        playerId: data['playerId']?.toString(), // ⬅️ mapping Firestore
        createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
        updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
        isBlocked: data['isBlocked'] ?? false,
      );
    } catch (e) {
      throw Exception('Error parsing UserModel from Firestore: $e');
    }
  }

  Map<String, dynamic> toFirestore() {
    final now = DateTime.now();
    return {
      'nama': nama.trim(),
      'email': email.toLowerCase().trim(),
      'role': role.value,
      'nomorTelepon': nomorTelepon.trim(),
      'alamat': alamat.trim(),
      'playerId': playerId, // ⬅️ mapping Firestore
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
      'updatedAt': Timestamp.fromDate(now),
      'isBlocked': isBlocked,
    };
  }

  UserModel copyWith({
    String? uid,
    String? nama,
    String? email,
    UserRole? role,
    String? nomorTelepon,
    String? alamat,
    String? playerId, // ⬅️ tambah di copyWith
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isBlocked,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      nama: nama ?? this.nama,
      email: email ?? this.email,
      role: role ?? this.role,
      nomorTelepon: nomorTelepon ?? this.nomorTelepon,
      alamat: alamat ?? this.alamat,
      playerId: playerId ?? this.playerId, // ⬅️ assign copyWith
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isBlocked: isBlocked ?? this.isBlocked,
    );
  }

  bool get isValidEmail =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  bool get isValidPhone =>
      RegExp(r'^\+?[\d\s\-\(\)]{10,}$').hasMatch(nomorTelepon);
  bool get isAdmin => role == UserRole.admin;
  bool get isUser => role == UserRole.user;

  @override
  List<Object?> get props => [
    uid,
    nama,
    email,
    role,
    nomorTelepon,
    alamat,
    playerId, // ⬅️ tambahkan di props Equatable
    createdAt,
    updatedAt,
  ];
}
