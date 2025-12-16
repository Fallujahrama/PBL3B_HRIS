import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Dapatkan warna primer dari tema
    final primaryColor = Theme.of(context).colorScheme.primary;

    // Data Pengguna (Placeholder)
    const String userName = "John Doe";
    // Ambil huruf pertama sebagai inisial
    final String initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ==== MODERN DRAWER HEADER ====
          UserAccountsDrawerHeader(
            accountName: const Text(
              userName, // Placeholder Nama Pengguna
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
              // Latar belakang tetap menggunakan warna default
              backgroundColor: Colors.white.withOpacity(0.8),
              // **MODIFIKASI: Mengganti Icon dengan Text (Inisial)**
              child: Text(
                initial, // Menampilkan inisial nama (contoh: J)
                style: TextStyle(
                  fontSize: 28, // Ukuran font disesuaikan
                  fontWeight: FontWeight.bold,
                  color: primaryColor, // Warna teks inisial menggunakan primaryColor
                ),
              ),
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, primaryColor.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            onDetailsPressed: () {
              context.pop(); 
              context.go('/employee/profile');
            },
          ),
          // ==== AKHIR MODERN DRAWER HEADER ====

          // ==== HOME ====
          ListTile(
            leading: const Icon(Icons.home_outlined),
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
            leading: const Icon(Icons.access_time_outlined),
            title: const Text('Absensi'),
            onTap: () => context.go('/attendance'),
          ),

          const Divider(),

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