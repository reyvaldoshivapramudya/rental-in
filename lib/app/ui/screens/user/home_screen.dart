import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentalin/app/providers/sewa_provider.dart';
import 'package:rentalin/app/ui/screens/user/profile_screen.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/motor_provider.dart';
import '../../../data/models/motor_model.dart';
import 'history_screen.dart';
import 'motor_detail_screen.dart';

// 1. WIDGET UTAMA SEBAGAI WADAH/SHELL (TIDAK ADA PERUBAHAN)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Daftar halaman yang akan ditampilkan di dalam shell
  static const List<Widget> _widgetOptions = <Widget>[
    MotorListTab(), // Halaman untuk daftar motor
    HistoryScreen(), // Halaman untuk riwayat pesanan
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.motorcycle),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}

// 2. WIDGET UNTUK TAB DAFTAR MOTOR (DENGAN MODIFIKASI)
class MotorListTab extends StatefulWidget {
  const MotorListTab({super.key});

  @override
  State<MotorListTab> createState() => _MotorListTabState();
}

class _MotorListTabState extends State<MotorListTab> {
  // --- PERUBAHAN 1: Menambahkan state untuk mengelola mode tampilan ---
  bool _isGridView = false;

  Future<void> _refreshMotors(BuildContext context) async {
    await Provider.of<MotorProvider>(
      context,
      listen: false,
    ).fetchMotorsManual();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshMotors(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Motor'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView;
              });
            },
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
            icon: const Icon(Icons.person),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Future.microtask(() {
                showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Konfirmasi Logout'),
                    content: const Text('Apakah Anda yakin ingin keluar?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: const Text('Batal'),
                      ),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(ctx).pop(); // Tutup dialog
                          Future.microtask(() {
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            final sewaProvider = Provider.of<SewaProvider>(
                              context,
                              listen: false,
                            );
                            sewaProvider.clearUserSewaData();
                            authProvider.logout();
                          });
                        },
                        child: const Text('Logout'),
                      ),
                    ],
                  ),
                );
              });
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refreshMotors(context),
        child: Consumer<MotorProvider>(
          builder: (context, motorProvider, child) {
            if (motorProvider.isLoading && motorProvider.motors.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (motorProvider.motors.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      height: constraints.maxHeight,
                      alignment: Alignment.center,
                      child: const Text('Belum ada motor yang tersedia.'),
                    ),
                  );
                },
              );
            }

            // --- PERUBAHAN 3: Memilih widget berdasarkan state _isGridView ---
            return _isGridView
                ? buildGridView(motorProvider.motors)
                : buildListView(motorProvider.motors);
          },
        ),
      ),
    );
  }

  // Widget untuk membangun ListView
  Widget buildListView(List<MotorModel> motors) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8.0),
      itemCount: motors.length,
      itemBuilder: (context, index) {
        final motor = motors[index];
        return MotorCard(motor: motor, isGridView: false); // Kirim flag view
      },
    );
  }

  // Widget untuk membangun GridView
  Widget buildGridView(List<MotorModel> motors) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // Jumlah kolom dalam grid
        crossAxisSpacing: 8.0, // Spasi horizontal antar item
        mainAxisSpacing: 8.0, // Spasi vertikal antar item
        childAspectRatio: 0.75, // Rasio aspek untuk setiap item
      ),
      itemCount: motors.length,
      itemBuilder: (context, index) {
        final motor = motors[index];
        return MotorCard(motor: motor, isGridView: true); // Kirim flag view
      },
    );
  }
}

// 3. WIDGET KARTU MOTOR (DENGAN MODIFIKASI KECIL)
class MotorCard extends StatelessWidget {
  final MotorModel motor;
  final bool isGridView; // Tambahkan flag untuk membedakan tampilan

  const MotorCard({super.key, required this.motor, this.isGridView = false});

  @override
  Widget build(BuildContext context) {
    String imageUrl = motor.gambarUrl;
    if (imageUrl.isNotEmpty && imageUrl.startsWith('http://')) {
      imageUrl = imageUrl.replaceFirst('http://', 'https://');
    }

    final Widget placeholder = Container(
      height: isGridView ? 120 : 150, // Sesuaikan tinggi untuk grid
      color: Colors.grey[200],
      child: const Icon(Icons.two_wheeler, size: 50, color: Colors.grey),
    );

    // Mengubah tampilan 'Lihat Detail' untuk Grid agar lebih ringkas
    final lihatDetailWidget = isGridView
        ? const Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: Colors.blueAccent,
          )
        : const Text(
            'Lihat Detail >',
            style: TextStyle(color: Colors.blueAccent),
          );

    return Card(
      margin: const EdgeInsets.all(
        4,
      ), // Margin diatur oleh parent (ListView/GridView)
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior:
          Clip.antiAlias, // Memastikan InkWell tidak keluar dari border
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MotorDetailScreen(motorId: motor.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar Motor
            SizedBox(
              height: isGridView ? 120 : 150, // Sesuaikan tinggi gambar
              width: double.infinity,
              child: imageUrl.isEmpty
                  ? placeholder
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => placeholder,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            // Detail Teks di bawah gambar
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    motor.nama,
                    style: TextStyle(
                      fontSize: isGridView ? 15 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${motor.merek} - ${motor.tahun}',
                    style: TextStyle(
                      fontSize: isGridView ? 12 : 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: isGridView ? 6 : 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Rp ${motor.hargaSewa}',
                          style: TextStyle(
                            fontSize: isGridView ? 14 : 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Teks '/ hari' hanya ditampilkan jika bukan grid view untuk menghemat ruang
                      if (!isGridView)
                        const Text(
                          '/ hari',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      const Spacer(), // Memberi ruang fleksibel
                      lihatDetailWidget,
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
