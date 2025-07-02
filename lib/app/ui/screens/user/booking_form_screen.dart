import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../data/models/motor_model.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/sewa_provider.dart';
import 'package:intl/date_symbol_data_local.dart';

class BookingFormScreen extends StatefulWidget {
  final MotorModel motor;
  const BookingFormScreen({super.key, required this.motor});

  @override
  State<BookingFormScreen> createState() => _BookingFormScreenState();
}

class _BookingFormScreenState extends State<BookingFormScreen> {
  late final SewaProvider _sewaProvider;
  DateTime? _tanggalSewa;
  DateTime? _tanggalKembali;
  int _durasi = 0;
  int _totalBiaya = 0;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id_ID', null);

    _sewaProvider = Provider.of<SewaProvider>(context, listen: false);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _sewaProvider.fetchBookedDates(widget.motor.id);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sewaProvider = Provider.of<SewaProvider>(context, listen: false);
  }

  @override
  void dispose() {
    _sewaProvider.clearBookedDates();
    super.dispose();
  }

  bool _isDateSelectable(DateTime day) {
    final sewaProvider = Provider.of<SewaProvider>(context, listen: false);
    for (final schedule in sewaProvider.bookedSchedules) {
      final startDate = DateTime(
        schedule.tanggalSewa.year,
        schedule.tanggalSewa.month,
        schedule.tanggalSewa.day,
      );
      final endDate = DateTime(
        schedule.tanggalKembali.year,
        schedule.tanggalKembali.month,
        schedule.tanggalKembali.day,
      );
      final dayToCheck = DateTime(day.year, day.month, day.day);

      if (!dayToCheck.isBefore(startDate) && !dayToCheck.isAfter(endDate)) {
        return false;
      }
    }
    return true;
  }

  void _calculateBill() {
    if (_tanggalSewa != null && _tanggalKembali != null) {
      if (!_tanggalKembali!.isBefore(_tanggalSewa!)) {
        setState(() {
          _durasi = _tanggalKembali!.difference(_tanggalSewa!).inDays + 1;
          _totalBiaya = _durasi * widget.motor.hargaSewa;
        });
      } else {
        setState(() {
          _durasi = 0;
          _totalBiaya = 0;
        });
      }
    } else {
      setState(() {
        _durasi = 0;
        _totalBiaya = 0;
      });
    }
  }

  Future<void> _pilihTanggal(BuildContext context, bool isTanggalSewa) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      selectableDayPredicate: _isDateSelectable,
    );
    if (picked != null) {
      setState(() {
        if (isTanggalSewa) {
          _tanggalSewa = picked;
        } else {
          _tanggalKembali = picked;
        }
        _calculateBill();
      });
    }
  }

  void _konfirmasiBooking() async {
    if (_tanggalSewa == null || _tanggalKembali == null || _durasi <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Harap pilih tanggal sewa dan kembali dengan benar.'),
        ),
      );
      return;
    }

    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    final sewaProvider = Provider.of<SewaProvider>(context, listen: false);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Konfirmasi Pesanan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Motor: ${widget.motor.nama}'),
            Text('Durasi: $_durasi hari'),
            const SizedBox(height: 8),
            Text(
              'Total Biaya: Rp $_totalBiaya',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Konfirmasi'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final success = await sewaProvider.createSewa(
      user: user,
      motor: widget.motor,
      tanggalSewa: _tanggalSewa!,
      tanggalKembali: _tanggalKembali!,
    );

    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    if (success) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'Booking berhasil! Silahkan datang ke rental kami dengan membawa kartu identitas diri.',
          ),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      messenger.showSnackBar(
        SnackBar(
          content: Text(sewaProvider.errorMessage ?? 'Booking Gagal'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy', 'id_ID');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Formulir Booking'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SewaProvider>(
        builder: (context, sewaProvider, child) {
          if (sewaProvider.isCheckingSchedule) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: const Icon(Icons.calendar_today),
                  title: const Text('Tanggal Sewa'),
                  subtitle: Text(
                    _tanggalSewa == null
                        ? 'Pilih tanggal'
                        : dateFormat.format(_tanggalSewa!),
                  ),
                  onTap: () => _pilihTanggal(context, true),
                ),
                ListTile(
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: const Text('Tanggal Kembali'),
                  subtitle: Text(
                    _tanggalKembali == null
                        ? 'Pilih tanggal'
                        : dateFormat.format(_tanggalKembali!),
                  ),
                  onTap: () => _pilihTanggal(context, false),
                ),
                const Divider(height: 32),
                const Text(
                  'Rincian Biaya',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Harga per hari'),
                    Text('Rp ${widget.motor.hargaSewa}'),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [const Text('Durasi'), Text('$_durasi hari')],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Biaya',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Rp $_totalBiaya',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Consumer<SewaProvider>(
          builder: (context, sewa, child) {
            final isButtonEnabled =
                _tanggalSewa != null &&
                _tanggalKembali != null &&
                _durasi > 0 &&
                !sewa.isLoading;

            return FilledButton(
              onPressed: isButtonEnabled ? _konfirmasiBooking : null,
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: isButtonEnabled
                    ? Colors.blueAccent
                    : Colors.grey,
              ),
              child: sewa.isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const Text(
                      'Konfirmasi Booking',
                      style: TextStyle(fontSize: 18),
                    ),
            );
          },
        ),
      ),
    );
  }
}
