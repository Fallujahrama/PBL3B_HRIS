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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(
        0xFFF5F6F8,
      ), // Abu-abu sangat muda (clean look)
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text(
          "MASTER POSITIONS",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        backgroundColor: Colors.blueAccent, // Warna Biru sesuai referensi
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: Column(
        children: [
          // Expanded List View
          Expanded(
            child: FutureBuilder<List<Position>>(
              future: futureData,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text("Belum ada data posisi."));
                }

                final data = snapshot.data!;

                return RefreshIndicator(
                  onRefresh: () async => _loadData(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(top: 10, bottom: 100),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      return PositionTile(
                        item: data[index],
                        onTap: () => _navigateToForm(data[index]),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      // Tombol Floating Action Button yang Lebar (Custom di bawah)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () => _navigateToForm(),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text(
            "Add Position",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
