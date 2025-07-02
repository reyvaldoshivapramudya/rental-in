import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentalin/utils/auth_exception.dart';
import '../../../providers/auth_provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible =
      false; // 🔶 d. Granular toggle confirm password

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      await authProvider.register(
        _namaController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _teleponController.text.trim(),
        _alamatController.text.trim(),
      );

      messenger.showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil!'),
          backgroundColor: Colors.green,
        ),
      );
      navigator.pop();
    } catch (e) {
      // 🔶 c. Error Message Clarity with AuthException
      final message = e is AuthException
          ? e.message
          : 'Terjadi kesalahan. Coba lagi.';
      messenger.showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Akun Baru'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, auth, child) {
          return Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Buat Akun Anda',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Satu langkah lagi untuk mulai menyewa.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: _namaController,
                      textInputAction:
                          TextInputAction.next, // 🔶 f. Focus Management
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).nextFocus(),
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap',
                      ),
                      validator: (v) =>
                          v!.isEmpty ? 'Nama tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _teleponController,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next, // 🔶 f
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).nextFocus(),
                      decoration: const InputDecoration(
                        labelText: 'Nomor Telepon (WA)',
                      ),
                      validator: (v) => v!.isEmpty
                          ? 'Nomor telepon tidak boleh kosong'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _alamatController,
                      keyboardType: TextInputType.streetAddress,
                      textInputAction: TextInputAction.next, // 🔶 f
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).nextFocus(),
                      decoration: const InputDecoration(
                        labelText: 'Alamat Lengkap',
                        hintText: 'Contoh: Jl. Pahlawan No. 123...',
                      ),
                      maxLines: 3,
                      validator: (v) =>
                          v!.isEmpty ? 'Alamat tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next, // 🔶 f
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).nextFocus(),
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (v) {
                        if (v!.isEmpty) return 'Email tidak boleh kosong';
                        if (!v.contains('@')) return 'Email tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      keyboardType:
                          TextInputType.visiblePassword, // 🔶 e. Accessibility
                      textInputAction: TextInputAction.next, // 🔶 f
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).nextFocus(),
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible,
                          ),
                        ),
                      ),
                      validator: (v) {
                        if (v!.isEmpty) return 'Password tidak boleh kosong';
                        if (v.length < 6) return 'Password minimal 6 karakter';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText:
                          !_isConfirmPasswordVisible, // 🔶 d. Separate visibility
                      keyboardType: TextInputType.visiblePassword, // 🔶 e
                      textInputAction: TextInputAction.done, // 🔶 f
                      decoration: InputDecoration(
                        labelText: 'Konfirmasi Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setState(
                            () => _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible,
                          ),
                        ),
                      ),
                      // 🔶 b. Validator Password Confirmation Implementation
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Konfirmasi password tidak boleh kosong';
                        if (v != _passwordController.text)
                          return 'Password tidak cocok';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: auth.isLoading ? null : _register,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                          : const Text(
                              'Daftar',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
