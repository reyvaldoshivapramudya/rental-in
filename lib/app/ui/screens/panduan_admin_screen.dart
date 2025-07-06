import 'package:flutter/material.dart';

class PanduanAdminScreen extends StatelessWidget {
  const PanduanAdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final guides = [
      {
        'title': 'Cara Menambahkan Data Motor',
        'icon': Icons.add_circle_outline,
        'color': Colors.blueAccent,
        'steps': [
          'Buka halaman daftar motor pada menu admin.',
          'Klik tombol Tambah Motor (+) di pojok kanan bawah.',
          'Isi form dengan data motor yang diperlukan seperti nama motor, merk, nomor polisi harga sewa per hari, dan upload foto motor yang jelas.',
          'Pastikan semua kolom terisi dengan benar dan gambar motor sudah terupload.',
          'Klik tombol Simpan.',
          'Motor akan ditambahkan dan muncul pada daftar motor di aplikasi user dan admin.',
        ],
      },
      {
        'title': 'Cara Mengedit Data Motor',
        'icon': Icons.edit,
        'color': Colors.orange,
        'steps': [
          'Pada halaman daftar motor admin, pilih motor yang ingin diedit.',
          'Klik ikon edit (pensil) di kartu motor tersebut.',
          'Ubah data motor sesuai kebutuhan seperti nama motor, merk, harga sewa, atau gambar motor.',
          'Klik tombol Simpan.',
          'Perubahan akan tersimpan dan data motor akan diperbarui pada aplikasi.',
        ],
      },
      {
        'title': 'Cara Menghapus Data Motor',
        'icon': Icons.delete_outline,
        'color': Colors.redAccent,
        'steps': [
          'Pada halaman daftar motor admin, pilih motor yang ingin dihapus.',
          'Klik ikon hapus (tempat sampah) di kartu motor tersebut.',
          'Akan muncul dialog konfirmasi untuk menghapus motor.',
          'Klik Hapus jika anda yakin ingin menghapus motor.',
          'Motor akan terhapus dan tidak lagi muncul di aplikasi user maupun admin.',
        ],
      },
      {
        'title': 'Manajemen Booking Motor',
        'icon': Icons.assignment_turned_in_outlined,
        'color': Colors.green,
        'steps': [
          'Buka menu Booking atau Riwayat Pesanan pada dashboard admin.',
          'Lihat daftar pemesanan motor yang masuk dengan status Menunggu Konfirmasi.',
          'Klik pesanan yang ingin anda kelola untuk melihat detailnya.',
          'Jika data pemesanan sudah sesuai, klik Konfirmasi untuk menyetujui pemesanan.',
          'Jika pemesanan tidak sesuai, klik Tolak dan user akan mendapatkan notifikasi bahwa pemesanan ditolak.',
          'Jika motor sudah dikembalikan oleh user, klik tombol Selesaikan Sewa untuk mengubah status pemesanan menjadi Selesai dan motor tersedia kembali.',
        ],
      },
      {
        'title': 'Proses Pengembalian Motor dan Denda',
        'icon': Icons.assignment_return,
        'color': Colors.purple,
        'steps': [
          'Buka menu Booking atau Riwayat Pesanan pada dashboard admin.',
          'Pilih pesanan dengan status Dikonfirmasi yang motor-nya sudah dikembalikan user.',
          'Klik tombol Selesaikan Sewa pada detail pesanan.',
          'Isi tanggal pengembalian aktual motor sesuai tanggal motor dikembalikan.',
          'Jika motor dikembalikan melebihi tanggal kembali, sistem akan otomatis menghitung denda sesuai hari keterlambatan.',
          'Setelah semua data benar, klik Konfirmasi Pengembalian.',
          'Status pesanan akan berubah menjadi Selesai dan motor tersedia kembali untuk disewa.',
          'Total denda akan tercatat pada detail pemesanan untuk laporan dan rekap admin.',
        ],
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Panduan Admin')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: guides.length,
        itemBuilder: (context, index) {
          final guide = guides[index];
          final String title = guide['title'] as String;
          final IconData icon = guide['icon'] as IconData;
          final Color color = guide['color'] as Color;
          final List<String> steps = (guide['steps'] as List<dynamic>)
              .cast<String>();

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
                  color: Colors.grey.withValues(alpha: 0.3),
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
              children: List.generate(steps.length, (i) {
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
            ),
          );
        },
      ),
    );
  }
}
