import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentalin/app/config/theme.dart';
import 'package:rentalin/app/providers/navigation_provider.dart';
import 'package:rentalin/app/ui/screens/panduan_user_screen.dart';
import 'package:rentalin/app/ui/screens/user/developer_screen.dart';
import 'package:rentalin/app/ui/screens/user/profile_screen.dart';
import 'package:rentalin/app/ui/screens/user/tentang_screen.dart';
import '../../../providers/motor_provider.dart';
import '../../../data/models/motor_model.dart';
import 'history_screen.dart';
import 'motor_detail_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    MotorListTab(),
    HistoryScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Jalankan setelah frame pertama selesai dibangun
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNotificationNavigation();
    });
  }

  // ✨ BUAT FUNGSI BARU UNTUK HANDLE NAVIGASI ✨
  void _handleNotificationNavigation() {
    final navProvider = context.read<NavigationProvider>();
    final target = navProvider.targetRoute;

    if (target == 'history_screen') {
      // Cari tahu indeks dari HistoryScreen
      const historyIndex = 1; // Berdasarkan urutan di _widgetOptions
      _onItemTapped(historyIndex);

      // Penting: Hapus target setelah digunakan agar tidak dieksekusi lagi
      navProvider.clearTargetRoute();
    }
  }

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
        onTap: _onItemTapped,
      ),
    );
  }
}

class MotorListTab extends StatefulWidget {
  const MotorListTab({super.key});

  @override
  State<MotorListTab> createState() => _MotorListTabState();
}

class _MotorListTabState extends State<MotorListTab> {
  bool _isGridView = false;

  Future<void> _refreshMotors(BuildContext context) async {
    await Provider.of<MotorProvider>(context, listen: false).refreshMotors();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshMotors(context);
      _loadViewPreference();
    });
  }

  // Load saved preference on startup
  Future<void> _loadViewPreference() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return; // ✅ check if still mounted
    setState(() {
      _isGridView = prefs.getBool('isGridView') ?? false;
    });
  }

  // Save preference whenever toggled
  Future<void> _toggleViewPreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isGridView = !_isGridView;
    });
    await prefs.setBool('isGridView', _isGridView);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Motor'),
        actions: [
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () => _toggleViewPreference(),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),
      drawer: buildAppDrawer(context),
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
                    child: SizedBox(
                      height: constraints.maxHeight,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.motorcycle,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text('Belum ada motor yang tersedia.'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            }

            return _isGridView
                ? buildGridView(motorProvider.motors)
                : buildListView(motorProvider.motors);
          },
        ),
      ),
    );
  }

  Widget buildAppDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                DrawerHeader(
                  decoration: const BoxDecoration(color: AppTheme.primaryColor),
                  child: Center(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/icon/icon.png',
                          width: 130,
                          height: 130,
                        ),
                      ],
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.info),
                  title: const Text('Tentang Perusahaan'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TentangScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.people),
                  title: const Text('Developer'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const DeveloperScreen(),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.help_outline,
                  ), // Mengganti ikon agar sesuai
                  title: const Text('Panduan Penyewa'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PanduanUserScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Contact Person:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text('0812-3450-5088'),
                SizedBox(height: 12),
                Text('Alamat:', style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(
                  'Jl. Watusari, Gg. Duku No.40, Watumas, Purwanegara, Purwokerto Utara',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildListView(List<MotorModel> motors) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8.0),
      itemCount: motors.length,
      itemBuilder: (context, index) {
        final motor = motors[index];
        return MotorCard(motor: motor, isGridView: false);
      },
    );
  }

  Widget buildGridView(List<MotorModel> motors) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 0.75,
      ),
      itemCount: motors.length,
      itemBuilder: (context, index) {
        final motor = motors[index];
        return MotorCard(motor: motor, isGridView: true);
      },
    );
  }
}

class MotorCard extends StatelessWidget {
  final MotorModel motor;
  final bool isGridView;

  const MotorCard({super.key, required this.motor, this.isGridView = false});

  @override
  Widget build(BuildContext context) {
    String imageUrl = motor.gambarUrl;
    if (imageUrl.isNotEmpty && imageUrl.startsWith('http://')) {
      imageUrl = imageUrl.replaceFirst('http://', 'https://');
    }

    final placeholder = Container(
      height: isGridView ? 120 : 150,
      color: Colors.grey[200],
      child: const Icon(Icons.two_wheeler, size: 50, color: Colors.grey),
    );

    final lihatDetailWidget = isGridView
        ? const Icon(Icons.arrow_forward_ios, size: 14)
        : const Text(
            'Lihat Detail >',
            style: TextStyle(fontWeight: FontWeight.bold),
          );

    return Card(
      margin: const EdgeInsets.all(4),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => MotorDetailScreen(motorId: motor.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: isGridView ? 120 : 150,
              width: double.infinity,
              child: imageUrl.isEmpty
                  ? placeholder
                  : Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => placeholder,
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
            ),
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
                          motor.formattedPrice,
                          style: TextStyle(
                            fontSize: isGridView ? 14 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isGridView)
                        const Text(
                          '/ hari',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      const Spacer(),
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
