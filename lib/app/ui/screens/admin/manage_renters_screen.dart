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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            renter.nama.substring(0, 1),
            style: TextStyle(fontSize: 24.0),
          ),
        ),
        title: Text(
          renter.nama,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(renter.email),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.blue),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => RenterFormScreen(renter: renter),
              ),
            );
          },
        ),
      ),
    );
  }
}
