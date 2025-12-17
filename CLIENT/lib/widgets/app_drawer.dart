import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// --- IMPORT MODEL DAN SERVICE ---
import '/features/login/models/user_logged_model.dart';
import '/features/login/services/auth.service.dart'; // Digunakan untuk fungsi logout
// -------------------------------

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Dapatkan instance UserLoggedModel
    final userModel = UserLoggedModel();
    final user = userModel.currentUser;
    final employee = userModel.employeeData;
    
    // Cek status dan role
    final bool isLoggedIn = userModel.isLoggedIn;
    // Role 1 = Admin, Role 0 = Employee
    final bool isAdmin = user?.role == 1; 

    // Jika pengguna belum login, tampilkan drawer kosong atau kosongkan data
    if (!isLoggedIn || user == null) {
      // Jika ini terjadi, harusnya navigasi sudah diarahkan ke halaman login.
      // Kita hanya menampilkan Drawer kosong atau yang sangat dasar.
       return Drawer(
          child: ListView(
            children: [
              const DrawerHeader(
                child: Center(child: Text("Silakan Login")),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Login'),
                onTap: () => context.go('/login'),
              ),
            ],
          ),
      );
    }
    
    // Data Pengguna yang akan ditampilkan di Header
    final String userName = user.name.isNotEmpty ? user.name : "Pengguna";
    final String userRoleText = isAdmin ? "Administrator" : (employee?['position']?['name'] ?? 'Karyawan');
    final String initial = userName.isNotEmpty ? userName[0].toUpperCase() : '?';
    
    final primaryColor = Theme.of(context).colorScheme.primary;

    // ✅ FUNGSI LOGOUT YANG DIPERBAIKI
    Future<void> handleLogout() async {
      // Simpan context sebelum async operation
      final navigator = Navigator.of(context);
      final scaffoldMessenger = ScaffoldMessenger.of(context);
      
      // Tutup drawer terlebih dahulu
      navigator.pop();
      
      try {
        // Panggil fungsi logout
        await AuthService().logout();
        
        // Gunakan context.go yang aman untuk GoRouter
        if (context.mounted) {
          context.go('/login');
        }
      } catch (e) {
        // Tampilkan error jika logout API gagal
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text("Gagal logout: $e"),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }


    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ==== MODERN DRAWER HEADER ====
          UserAccountsDrawerHeader(
            accountName: Text(
              userName, 
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            accountEmail: Text(
              userRoleText, // Jabatan/Peran
              style: const TextStyle(
                fontSize: 14,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.8),
              child: Text(
                initial, 
                style: TextStyle(
                  fontSize: 28, 
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
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
              Navigator.of(context).pop();
              context.go('/employee/profile');
            },
          ),
          // ==== AKHIR MODERN DRAWER HEADER ====

          // ==== MENU UNTUK EMPLOYEE (ROLE 0) ====
          if (!isAdmin) ...[
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/employee-dashboard');
              },
            ),
            const Divider(),
          
            ListTile(
              leading: const Icon(Icons.access_time_outlined),
              title: const Text('Absensi'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/attendance');
              },
            ),
            ListTile(
              leading: const Icon(Icons.insert_chart_outlined),
              title: const Text('Laporan Absensi'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/employee/report');
              },
            ),
            ListTile(
              leading: const Icon(Icons.mail_outline),
              title: const Text("Pengajuan Surat"),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/form-surat');
              },
            ),
            ListTile(
              leading: const Icon(Icons.money_outlined),
              title: const Text('Gaji'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/employee/salary');
              },
            ),
          ],
          

          // ==== MENU UNTUK ADMIN (ROLE 1) ====
          if (isAdmin) ...[
            ListTile(
              leading: const Icon(Icons.dashboard_outlined),
              title: const Text('Dashboard'),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/admin-dashboard');
              },
            ),
            const Divider(),

            ListTile(
              leading: const Icon(Icons.storage_outlined),
              title: const Text("Master Data"),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/master-data');
              },
            ),
           
            ListTile(
              leading: const Icon(Icons.article_outlined),
              title: const Text("Laporan Gaji Karyawan"),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/summary-salary');
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: const Text("Kelola Template Surat"),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/letters');
              },
            ),
            ListTile(
              leading: const Icon(Icons.done_all_outlined),
              title: const Text("Persetujuan Surat"),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/hrd-list');
              },
            ),
            ListTile(
              leading: const Icon(Icons.assessment),
              title: const Text("Rekap Surat Karyawan"),
              onTap: () {
                Navigator.of(context).pop();
                context.go('/employee-recap');
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text("Jadwal Hari Libur"),
              onTap: () => context.go('/schedule'),
            ),
            ListTile(
              leading: const Icon(Icons.assignment),
              title: const Text("Rekap Absensi"),
              onTap: () => context.go('/attendance_report_page'),
            ),
            const Divider(),
          ],

          // ==== LOGOUT ====
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: handleLogout,
          ),
        ],
      ),
    );
  }
}