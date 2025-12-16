import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Dapatkan warna primer dari tema
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero, // Hapus padding default ListView
        children: [
          // ==== MODERN DRAWER HEADER ====
          UserAccountsDrawerHeader(
            accountName: const Text(
              "John Doe", // Placeholder Nama Pengguna
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            accountEmail: const Text(
              "HR Manager", // Placeholder Jabatan/Peran
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              // Ikon/Gambar Profil Placeholder
              child: Icon(
                Icons.person,
                size: 40,
                color: primaryColor,
              ),
            ),
            decoration: BoxDecoration(
              // Menggunakan gradien atau warna solid yang diperkaya
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            // Tambahkan onTap untuk navigasi ke halaman profile
            onDetailsPressed: () {
              context.pop(); // Tutup Drawer
              context.go('/employee/profile');
            },
          ),
          // ==== AKHIR MODERN DRAWER HEADER ====

          // ==== HOME ====
          ListTile(
            leading: const Icon(Icons.home_outlined), // Ubah ikon menjadi outlined
            title: const Text("Home"),
            onTap: () => context.go('/home'),
          ),

          ListTile(
            leading: const Icon(Icons.dashboard_outlined),
            title: const Text('Dashboard'),
            onTap: () => context.go('/employee-dashboard'),
          ),

          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Profile'),
            onTap: () => context.go('/employee/profile'),
          ),

          ListTile(
            leading: const Icon(Icons.access_time_outlined), // Ikon Absensi
            title: const Text('Absensi'),
            onTap: () => context.go('/attendance'),
          ),

          const Divider(), // Pemisah untuk kategori

          // ==== POSITION (MASTER DATA) ====
          ListTile(
            leading: const Icon(Icons.storage_outlined),
            title: const Text("Master Data"),
            onTap: () => context.go('/master-data'),
          ),

          // ==== PENGAJUAN SURAT ====
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: const Text("Pengajuan Surat"),
            onTap: () => context.go('/letter-home'),
          ),

          ListTile(
            leading: const Icon(Icons.money_outlined),
            title: const Text('Gaji'),
            onTap: () => context.go('/employee/salary'),
          ),
          ListTile(
            leading: const Icon(Icons.insert_chart_outlined),
            title: const Text('Laporan Absensi'),
            onTap: () => context.go('/employee/report'),
          ),

          // ==== LAPORAN GAJI ====
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text("Laporan Gaji Karyawan"),
            onTap: () => context.go('/summary-salary'),
          ),

          const Divider(),

          // ==== LOGOUT ====
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => context.go('/login'),
          ),
        ],
      ),
    );
  }
}