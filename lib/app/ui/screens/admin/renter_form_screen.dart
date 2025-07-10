import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentalin/app/data/models/user_model.dart';
import 'package:rentalin/app/providers/user_provider.dart';

class RenterFormScreen extends StatefulWidget {
  final UserModel renter;
  const RenterFormScreen({super.key, required this.renter});

  @override
  State<RenterFormScreen> createState() => _RenterFormScreenState();
}

class _RenterFormScreenState extends State<RenterFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _teleponController;
  late TextEditingController _alamatController;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController(text: widget.renter.nama);
    _emailController = TextEditingController(text: widget.renter.email);
    _teleponController = TextEditingController(text: widget.renter.nomorTelepon);
    _alamatController = TextEditingController(text: widget.renter.alamat);
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _alamatController.dispose();
    super.dispose();
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      final userProvider = context.read<UserProvider>();
      final success = await userProvider.updateUserData(
        uid: widget.renter.uid,
        nama: _namaController.text,
        email: _emailController.text,
        nomorTelepon: _teleponController.text,
        alamat: _alamatController.text,
      );

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data berhasil diperbarui'), backgroundColor: Colors.green),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(userProvider.errorMessage ?? 'Gagal memperbarui data'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Data ${widget.renter.nama}')),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Lengkap', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Email tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _teleponController,
                decoration: const InputDecoration(labelText: 'Nomor Telepon', border: OutlineInputBorder()),
                keyboardType: TextInputType.phone,
                validator: (value) => value!.isEmpty ? 'Nomor Telepon tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alamatController,
                decoration: const InputDecoration(labelText: 'Alamat Lengkap', border: OutlineInputBorder()),
                maxLines: 3,
                validator: (value) => value!.isEmpty ? 'Alamat tidak boleh kosong' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return FilledButton.icon(
                      onPressed: userProvider.isLoading ? null : _saveForm,
                      icon: userProvider.isLoading ? const SizedBox.shrink() : const Icon(Icons.save),
                      label: userProvider.isLoading ? const CircularProgressIndicator() : const Text('Simpan Perubahan'),
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}