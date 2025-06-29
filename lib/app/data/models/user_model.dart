import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String nama;
  final String email;
  final String role;
  final String nomorTelepon;
  final String alamat;

  UserModel({
    required this.uid,
    required this.nama,
    required this.email,
    required this.role,
    required this.nomorTelepon,
    required this.alamat,
  });

  // Factory constructor to create a UserModel from a Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      uid: doc.id,
      nama: data['nama'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'user', // Default role is 'user'
      nomorTelepon: data['nomorTelepon'] ?? '',
      alamat: data['alamat'] ?? '',
    );
  }

  // Method to convert UserModel instance to a map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nama': nama,
      'email': email,
      'role': role,
      'nomorTelepon': nomorTelepon,
      'alamat': alamat,
    };
  }
}
