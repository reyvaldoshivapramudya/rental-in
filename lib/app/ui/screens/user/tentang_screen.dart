import 'package:flutter/material.dart';

class TentangScreen extends StatelessWidget {
  const TentangScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tentang Perusahaan')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/tentang-1.jpg'),
              ),
              const SizedBox(height: 10),
              const Text(
                'Boss Sewa Motor Purwokerto adalah perusahaan jasa penyewaan motor yang berfokus pada pelayanan wisatawan asing yang berkunjung ke kota Purwokerto dan sekitarnya. Berdiri sejak tahun 2015, usaha ini awalnya merupakan layanan cuci motor kecil yang kemudian berkembang seiring meningkatnya kebutuhan transportasi wisata di wilayah Banyumas. Melihat tingginya minat wisatawan asing yang ingin menjelajahi keindahan alam dan budaya lokal secara mandiri, Boss Sewa Motor melakukan transformasi layanan menjadi penyedia sewa motor profesional dengan sistem yang lebih modern dan terstruktur.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset('assets/tentang-2.jpg'),
              ),
              const SizedBox(height: 10),
              const Text(
                'Dengan berbagai pilihan motor matic yang terawat dengan baik. Boss Sewa Motor menawarkan pengalaman berkendara yang aman, nyaman, dan fleksibel. Lokasinya yang strategis di pusat kota Purwokerto membuatnya mudah dijangkau dari stasiun dan terminal. Selain itu, tim yang ramah dan berpengalaman juga siap memberikan panduan rute serta informasi destinasi terbaik di sekitar Purwokerto seperti Baturaden, Curug Cipendok, dan Kebun Teh Tambi. Boss Sewa Motor Purwokerto berkomitmen untuk menjadi mitra perjalanan terbaik bagi wisatawan asing yang ingin menjelajah Purwokerto dengan kebebasan dan kenyamanan maksimal.',
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
