import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:rentalin/app/data/models/motor_status.dart';
import '../../../data/models/motor_model.dart';
import '../../../providers/motor_provider.dart';

class MotorFormScreen extends StatefulWidget {
  final MotorModel? motor;
  const MotorFormScreen({super.key, this.motor});

  @override
  _MotorFormScreenState createState() => _MotorFormScreenState();
}

class _MotorFormScreenState extends State<MotorFormScreen> {
  final _formKey = GlobalKey<FormState>();
  File? _imageFile;
  final _picker = ImagePicker();

  final _namaController = TextEditingController();
  final _merekController = TextEditingController();
  final _tahunController = TextEditingController();
  final _nopolController = TextEditingController();
  final _hargaController = TextEditingController();
  bool _isLoading = false;

  bool get isEditMode => widget.motor != null;

  @override
  void initState() {
    super.initState();
    if (isEditMode) {
      _namaController.text = widget.motor!.nama;
      _merekController.text = widget.motor!.merek;
      _tahunController.text = widget.motor!.tahun.toString();
      _nopolController.text = widget.motor!.nomorPolisi;
      _hargaController.text = widget.motor!.hargaSewa.toString();
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _merekController.dispose();
    _tahunController.dispose();
    _nopolController.dispose();
    _hargaController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _simpanMotor() async {
    if (!_formKey.currentState!.validate()) return;

    if (!isEditMode && _imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap pilih gambar motor.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final motorProvider = Provider.of<MotorProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    try {
      String successMessage;

      if (isEditMode) {
        final updatedMotorData = MotorModel(
          id: widget.motor!.id,
          nama: _namaController.text,
          merek: _merekController.text,
          tahun: int.parse(_tahunController.text),
          nomorPolisi: _nopolController.text.toUpperCase(),
          hargaSewa: int.parse(_hargaController.text),
          status: widget.motor!.status,
          gambarUrl: widget.motor!.gambarUrl,
        );
        await motorProvider.updateMotor(updatedMotorData, _imageFile);
        successMessage = 'Data motor berhasil diperbarui!';
      } else {
        final motorData = MotorModel(
          id: '',
          nama: _namaController.text,
          merek: _merekController.text,
          tahun: int.parse(_tahunController.text),
          nomorPolisi: _nopolController.text.toUpperCase(),
          hargaSewa: int.parse(_hargaController.text),
          status: MotorStatus.tersedia,
          gambarUrl: '',
        );
        await motorProvider.addMotor(motorData, _imageFile!);
        successMessage = 'Data motor berhasil ditambahkan!';
      }

      messenger.showSnackBar(
        SnackBar(content: Text(successMessage), backgroundColor: Colors.green),
      );
      navigator.pop(true);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditMode ? 'Edit Data Motor' : 'Tambah Motor Baru'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey[100],
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildImagePicker(),
            const SizedBox(height: 24),
            _buildInfoUtamaCard(),
            const SizedBox(height: 24),
            _buildHargaCard(),
            const SizedBox(height: 32),
            _buildSimpanButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildImageContent(),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _pickImage,
                splashColor: Colors.black.withOpacity(0.3),
                highlightColor: Colors.white.withOpacity(0.15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageContent() {
    if (_imageFile != null) {
      return _buildImageWithVisualOverlay(
        Image.file(
          _imageFile!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
        ),
      );
    } else if (isEditMode && widget.motor!.gambarUrl.isNotEmpty) {
      return _buildImageWithVisualOverlay(
        Image.network(
          widget.motor!.gambarUrl,
          fit: BoxFit.cover,
          width: double.infinity,
          height: 200,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[200],
              child: _buildImagePlaceholderVisuals(),
            );
          },
        ),
      );
    } else {
      return Container(
        height: 200,
        width: double.infinity,
        color: Colors.grey[200],
        child: _buildImagePlaceholderVisuals(),
      );
    }
  }

  Widget _buildImagePlaceholderVisuals() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey.shade700),
        const SizedBox(height: 8),
        Text(
          'Ketuk untuk menambah gambar',
          style: TextStyle(
            color: Colors.grey.shade700,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildImageWithVisualOverlay(Widget imageWidget) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(height: 200, width: double.infinity, child: imageWidget),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(color: Colors.black.withOpacity(0.4)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.camera_alt, color: Colors.white, size: 40),
                SizedBox(height: 8),
                Text(
                  'Ketuk untuk ganti gambar',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoUtamaCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Informasi Utama",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            CustomTextFormField(
              controller: _namaController,
              labelText: 'Nama Motor',
              hintText: 'Contoh: Beat Street, NMAX Connected',
              prefixIcon: Icons.motorcycle,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _merekController,
              labelText: 'Merek',
              hintText: 'Contoh: Honda, Yamaha',
              prefixIcon: Icons.branding_watermark,
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _tahunController,
              labelText: 'Tahun',
              hintText: 'Contoh: 2023',
              prefixIcon: Icons.calendar_today,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
            const SizedBox(height: 16),
            CustomTextFormField(
              controller: _nopolController,
              labelText: 'Nomor Polisi',
              hintText: 'Contoh: G 1234 ABC',
              prefixIcon: Icons.pin,
              textCapitalization: TextCapitalization.characters,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHargaCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Harga",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(height: 20),
            CustomTextFormField(
              controller: _hargaController,
              labelText: 'Harga Sewa / Hari',
              hintText: 'Contoh: 75000',
              prefixIcon: Icons.price_change,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpanButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        icon: _isLoading ? Container() : const Icon(Icons.save),
        label: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Text(
                isEditMode ? 'Simpan Perubahan' : 'Tambahkan Motor',
                style: const TextStyle(fontSize: 16),
              ),
        onPressed: _isLoading ? null : _simpanMotor,
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blueAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextCapitalization textCapitalization;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
    this.textCapitalization = TextCapitalization.none,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$labelText tidak boleh kosong';
        }
        return null;
      },
    );
  }
}
