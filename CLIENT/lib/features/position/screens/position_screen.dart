import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/position.dart';
import '../services/position_api.dart';
import '../widgets/position_tile.dart';
import '../../../widgets/app_drawer.dart';

class PositionScreen extends StatefulWidget {
  const PositionScreen({super.key});

  @override
  State<PositionScreen> createState() => _PositionScreenState();
}

class _PositionScreenState extends State<PositionScreen> {
  // Mengubah futureData menjadi nullable untuk kemudahan handling state di build
  late Future<List<Position>> futureData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    setState(() {
      futureData = PositionApi.getPositions();
    });
  }

  // Navigasi ke Form (untuk Tambah atau Edit)
  void _navigateToForm([Position? position]) async {
    // Kita push ke route form (kita akan buat route-nya nanti)
    // Menggunakan extra untuk passing object position
    final result = await context.push('/positions/form', extra: position);

    // Jika kembali dengan nilai true (berhasil simpan/hapus), refresh data
    if (result == true) {
      _loadData();
    }
  }

  // --- Widget untuk menampilkan Body (Loading/Error/Data) ---
  Widget _buildBody(BuildContext context) {
    return FutureBuilder<List<Position>>(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // 1. Loading State (Sama seperti Employee Screen)
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          // 2. Error State (Sama seperti Employee Screen)
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 16),
                Text('Error: ${snapshot.error}', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          // 3. Empty State (Sama seperti Employee Screen)
          return const Center(child: Text("Belum ada data posisi."));
        }

        // 4. Data Loaded State
        final data = snapshot.data!;

        return RefreshIndicator(
          onRefresh: () async => _loadData(),
          child: ListView.builder(
            // Padding disamakan dengan Employee List Screen (padding: const EdgeInsets.all(16))
            padding: const EdgeInsets.all(16).copyWith(bottom: 80), // Menambahkan ruang untuk FAB
            itemCount: data.length,
            itemBuilder: (context, index) {
              // Menggunakan PositionTile yang sudah ada
              return PositionTile(
                item: data[index],
                onTap: () => _navigateToForm(data[index]),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
          0xFFF5F6F8), // Abu-abu sangat muda (clean look)
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text(
          "Master Posisi",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black), // Menambahkan ini agar mirip
      ),
      // Mengganti Column + Expanded dengan _buildBody
      body: _buildBody(context),

      // Mengganti bottomNavigationBar dengan FloatingActionButton.extended
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tambah Posisi', style: TextStyle(color: Colors.white)),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      // Menggunakan posisi yang sama
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      
      // bottomNavigationBar dihapus
    );
  }
}