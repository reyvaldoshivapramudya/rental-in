import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart'; // Pastikan path import ini benar

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Fungsi untuk Registrasi User Baru
  Future<UserModel?> registerWithEmailAndPassword(
    String nama,
    String email,
    String password,
    String nomorTelepon,
    String alamat,
  ) async {
    try {
      // 1. Buat user di Firebase Authentication
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        // 2. Buat dokumen user di Firestore
        UserModel newUser = UserModel(
          uid: user.uid,
          nama: nama,
          email: email,
          role: 'user', // Default role untuk pendaftaran baru
          nomorTelepon: nomorTelepon,
          alamat: alamat,
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(newUser.toFirestore());

        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      // Menangani error spesifik dari Firebase Auth
      print('Error registrasi: ${e.message}');
      // Anda bisa menampilkan pesan error ini ke user nantinya
      return null;
    } catch (e) {
      print('Terjadi error: $e');
      return null;
    }
    return null;
  }

  // Fungsi untuk Sign In / Login
  Future<UserModel?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // 1. Lakukan sign in di Firebase Authentication
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      User? user = userCredential.user;

      if (user != null) {
        // 2. Ambil data user dari Firestore untuk mendapatkan role
        DocumentSnapshot doc = await _firestore
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          return UserModel.fromFirestore(doc);
        }
      }
    } on FirebaseAuthException catch (e) {
      print('Error login: ${e.message}');
      return null;
    } catch (e) {
      print('Terjadi error: $e');
      return null;
    }
    return null;
  }

  // Fungsi untuk Sign Out / Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Stream untuk memantau status autentikasi user
  // Berguna untuk splash screen nanti
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
