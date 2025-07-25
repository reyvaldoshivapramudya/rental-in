import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentalin/app/data/models/user_model.dart';
import 'package:rentalin/app/providers/user_provider.dart';
import 'package:rentalin/app/ui/screens/admin/renter_form_screen.dart';
import 'package:rentalin/app/ui/widgets/loading_widget.dart';

class ManageRentersScreen extends StatefulWidget {
  const ManageRentersScreen({super.key});

  @override
  State<ManageRentersScreen> createState() => _ManageRentersScreenState();
}

class _ManageRentersScreenState extends State<ManageRentersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  @override
  void initState() {
    super.initState();
    // Listener untuk memperbarui UI saat admin mengetik
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserProvider>().fetchAllRenters();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Penyewa')),
      body: Column(
        children: [
          // ✨ WIDGET PENCARIAN ✨
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari Nama atau Email Penyewa',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear(),
                      )
                    : null,
              ),
            ),
          ),
          Expanded(
            child: Consumer<UserProvider>(
              builder: (context, userProvider, child) {
                if (userProvider.isLoading && userProvider.renters.isEmpty) {
                  return const LoadingWidget();
                }

                final List<UserModel> allRenters = userProvider.renters;
                final List<UserModel> filteredRenters = allRenters.where((
                  renter,
                ) {
                  final query = _searchQuery.toLowerCase();
                  final renterName = renter.nama.toLowerCase();
                  final renterEmail = renter.email.toLowerCase();

                  return renterName.contains(query) ||
                      renterEmail.contains(query);
                }).toList();

                if (filteredRenters.isEmpty) {
                  return Center(
                    child: Text(
                      _searchQuery.isNotEmpty
                          ? 'Tidak ada hasil untuk "$_searchQuery".'
                          : 'Tidak ada data penyewa.',
                    ),
                  );
                }
                if (userProvider.renters.isEmpty) {
                  return const Center(child: Text('Tidak ada data penyewa.'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount:
                      filteredRenters.length, // Gunakan daftar yang difilter
                  itemBuilder: (context, index) {
                    final renter =
                        filteredRenters[index]; // Gunakan daftar yang difilter
                    return RenterCard(renter: renter);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RenterCard extends StatelessWidget {
  final UserModel renter;
  const RenterCard({super.key, required this.renter});

  @override
  Widget build(BuildContext context) {
    final userProvider = context.read<UserProvider>();
    final titleColor = renter.isBlocked ? Colors.red : Colors.black;
    final cardColor = renter.isBlocked
        ? Colors.red.withOpacity(0.05)
        : Colors.white;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: cardColor,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: renter.isBlocked ? Colors.red.shade100 : Colors.transparent,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: titleColor.withOpacity(0.1),
            child: Text(
              renter.nama.isNotEmpty ? renter.nama.substring(0, 1) : '?',
              style: TextStyle(color: titleColor, fontWeight: FontWeight.bold),
            ),
          ),
          title: Text(
            renter.nama,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: titleColor,
              decoration: renter.isBlocked ? TextDecoration.lineThrough : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                renter.email,
                style: TextStyle(color: titleColor.withOpacity(0.8)),
              ),
              if (renter.isBlocked)
                const Padding(
                  padding: EdgeInsets.only(top: 4.0),
                  child: Text(
                    'DIBLOKIR',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Tombol Edit
              IconButton(
                icon: Icon(
                  Icons.edit,
                  color: renter.isBlocked ? Colors.grey : Colors.blue,
                ),
                tooltip: 'Edit Data Penyewa',
                onPressed: renter.isBlocked
                    ? null
                    : () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RenterFormScreen(renter: renter),
                          ),
                        );
                      },
              ),
              // ✨ Switch diganti dengan IconButton ini ✨
              IconButton(
                icon: Icon(
                  // Ubah ikon berdasarkan status blokir
                  renter.isBlocked ? Icons.lock_open : Icons.block,
                ),
                color: renter.isBlocked
                    ? Colors.green
                    : Colors.red, // Ubah warna juga
                tooltip: renter.isBlocked ? 'Buka Blokir' : 'Blokir',
                onPressed: () {
                  // Logika dialog konfirmasi sama seperti sebelumnya
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: Text(
                        renter.isBlocked
                            ? 'Buka Blokir Pengguna?'
                            : 'Blokir Pengguna?',
                      ),
                      content: Text(
                        'Anda yakin ingin mengubah status untuk ${renter.nama}?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Batal'),
                        ),
                        FilledButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                            userProvider.toggleBlockStatus(
                              renter.uid,
                              renter.isBlocked,
                            );
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: renter.isBlocked
                                ? Colors.green
                                : Colors.red,
                          ),
                          child: const Text('Ya, Lanjutkan'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
