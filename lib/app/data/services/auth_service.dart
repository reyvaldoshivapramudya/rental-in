import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentalin/app/data/models/user_role.dart';
import 'package:rentalin/utils/auth_exception.dart';
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
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = userCredential.user;

      if (user != null) {
        UserModel newUser = UserModel(
          uid: user.uid,
          nama: nama,
          email: email,
          role: UserRole.user,
          nomorTelepon: nomorTelepon,
          alamat: alamat,
        );

        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(newUser.toFirestore());
        return newUser;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      print('Error registrasi: ${e.message}');
      throw AuthException(
        message: e.message ?? 'Terjadi kesalahan autentikasi',
      );
    } catch (e) {
      print('Terjadi error: $e');
      rethrow;
    }
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
