import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentalin/app/providers/sewa_provider.dart';
import 'package:rentalin/app/ui/screens/user/profile_screen.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/motor_provider.dart';
import '../../../data/models/motor_model.dart';
import 'history_screen.dart';
import 'motor_detail_screen.dart';

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
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _refreshMotors(context),
    );
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
            onPressed: () => setState(() => _isGridView = !_isGridView),
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
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
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
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                        final authProvider = Provider.of<AuthProvider>(
                          context,
                          listen: false,
                        );
                        final sewaProvider = Provider.of<SewaProvider>(
                          context,
                          listen: false,
                        );
                        sewaProvider.clearUserSewaData();
                        await authProvider.logout();
                      },
                      child: const Text('Logout'),
                    ),
                  ],
                ),
              );
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
                    child: SizedBox(
                      height: constraints.maxHeight,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.motorcycle, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('Belum ada motor yang tersedia.'),
                        ],
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
                            color: Colors.blueAccent,
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
