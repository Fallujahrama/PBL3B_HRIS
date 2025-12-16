import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Text(
              "Menu",
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),

          // ==== HOME ====
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () => context.go('/home'),
          ),

          // ==== POSITION (MASTER POSITION) ====
          ListTile(
            leading: const Icon(Icons.work),
            title: const Text("Posisi"),
            onTap: () => context.go('/positions'),
          ),

          // ==== DEPARTMENT LIST ====
          ListTile(
            leading: const Icon(Icons.apartment),
            title: const Text("Department"),
            onTap: () => context.go('/departments'),
          ),

          // ==== DEPARTMENT MAP (FITUR BARU) ====
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text("Department Map"),
            onTap: () => context.go('/department-map'),
          ),

          // ==== KARYAWAN ====
          ListTile(
            leading: const Icon(Icons.people),
            title: const Text("Karyawan"),
            onTap: () => context.go('/employee'),
          ),

          // ==== LAPORAN GAJI ====
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text("Laporan Gaji Karyawan"),
            onTap: () => context.go('/summary-salary'),
          ),
          
          // ==== PENGAJUAN SURAT ====
          ListTile(
            leading: const Icon(Icons.mail),
            title: const Text("Pengajuan Surat"),
            onTap: () => context.go('/letter-home'),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () => context.go('/employee-dashboard'),
          ),

          ListTile(
            leading: const Icon(Icons.money),
            title: const Text('Gaji'),
            onTap: () => context.go('/employee/salary'),
          ),
          ListTile(
            leading: const Icon(Icons.insert_chart),
            title: const Text('Report Absensi'),
            onTap: () => context.go('/employee/report'),
          ),

          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () => context.go('/employee/profile'),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () => context.go('/login'),
          ),

          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Absensi'),
            onTap: () => context.go('/attendance'),
          ),
        ],
      ),
    );
  }
}
