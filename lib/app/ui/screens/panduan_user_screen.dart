import 'package:flutter/material.dart';

class PanduanUserScreen extends StatelessWidget {
  const PanduanUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final guides = [
      {
        'title': 'Cara Daftar Akun',
        'icon': Icons.person_add_alt_1,
        'color': Colors.blueAccent,
        'steps': [
          'Klik Daftar jika anda belum mempunyai akun',
          'Siapkan Nama Lengkap, Alamat Lengkap anda sesuai dengan KTP, dan Email aktif',
          'Isikan semua kolom sesuai dengan data diri Anda seperti Nama Lengkap, Alamat Lengkap, Email Aktif, buat Password yang mengandung minimal 6 karakter, dan isikan kolom konfirmasi password sama seperti password sebelumnya.',
          'Klik Daftar',
          'Akun akan berhasil dibuat dan secara otomatis anda langsung masuk ke halaman beranda',
        ],
      },
      {
        'title': 'Cara Menyewa Motor',
        'icon': Icons.motorcycle,
        'color': Colors.green,
        'steps': [
          'Login terlebih dahulu menggunakan akun anda',
          'Pilih motor yang tersedia sesuai kebutuhan anda',
          'Klik tombol Sewa Sekarang pada halaman detail motor',
          'Isi tanggal sewa dan tanggal kembali sesuai kebutuhan',
          'Klik Konfirmasi Sewa',
          'Tunggu konfirmasi dari admin melalui aplikasi',
          'Setelah dikonfirmasi, anda dapat melihat status pemesanan pada menu Riwayat berubah menjadi Dikonfirmasi',
          'Anda dapat mengambil motor pada tanggal yang telah disepakati dengan datang ke lokasi rental',
          'Pastikan membawa KTP asli dan bukti pemesanan untuk verifikasi, lalu lakukan pembayaran sesuai harga sewa yang telah disepakati',
          'Motor siap digunakan setelah pembayaran selesai',
          'Setelah selesai menggunakan motor, kembalikan ke lokasi rental sesuai waktu yang telah disepakati',
        ],
        'warningText':
            'Penyewaan akan ditolak oleh admin jika alamat anda berdomisili di Purwokerto',
      },
      {
        'title': 'Cara Melihat Riwayat Penyewaan',
        'icon': Icons.history,
        'color': Colors.orange,
        'steps': [
          'Masuk ke aplikasi menggunakan akun anda',
          'Klik menu Riwayat pada navigasi bawah',
          'Anda dapat melihat daftar penyewaan beserta statusnya',
        ],
      },
      {
        'title': 'Cara Mengembalikan Motor dan Perhitungan Denda',
        'icon': Icons.assignment_returned,
        'color': Colors.purple,
        'steps': [
          'Pastikan motor dikembalikan sesuai tanggal kembali yang tertera pada detail penyewaan.',
          'Bawa motor kembali ke lokasi rental pada tanggal yang telah disepakati.',
          'Jika motor dikembalikan melebihi tanggal kembali, anda akan dikenakan denda per hari keterlambatan sesuai kebijakan rental.',
          'Admin akan memproses pengembalian motor dan menginformasikan jumlah total denda jika ada.',
          'Lakukan pembayaran denda sesuai yang diinformasikan admin untuk menyelesaikan pemesanan.',
          'Setelah pengembalian diverifikasi dan denda dibayar (jika ada), status pemesanan anda akan berubah menjadi Selesai.',
        ],
      },
      {
        'title': 'Cara Logout',
        'icon': Icons.logout,
        'color': Colors.redAccent,
        'steps': [
          'Klik Icon Profil pada bagian AppBar',
          'Klik tombol Logout di bagian bawah halaman profil',
          'Anda akan keluar dari akun dan kembali ke halaman login',
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Panduan Penyewa')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: guides.length,
        itemBuilder: (context, index) {
          final guide = guides[index];
          final String title = guide['title'] as String;
          final IconData icon = guide['icon'] as IconData;
          final Color color = guide['color'] as Color;
          final List<String> steps = List<String>.from(guide['steps'] as List);
          final String? warningText = guide['warningText'] as String?;

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFFF9C4), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ExpansionTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              tilePadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              leading: CircleAvatar(
                backgroundColor: color,
                child: Icon(icon, color: Colors.white),
              ),
              title: Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              iconColor: color,
              collapsedIconColor: color,
              children: [
                ...List.generate(steps.length, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${i + 1}. ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: color,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            steps[i],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (warningText != null) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Icon(Icons.warning, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Penyewaan akan ditolak oleh admin jika alamat anda berdomisili di Purwokerto',
                          style: TextStyle(color: Colors.red, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
