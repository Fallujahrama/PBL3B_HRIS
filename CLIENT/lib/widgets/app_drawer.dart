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
            title: const Text("Positions"),
            onTap: () => context.go('/positions'),
          ),
          
          ListTile(
            leading: const Icon(Icons.article),
            title: const Text("Laporan Gaji Pegawai"),
            onTap: () => context.go('/summary-salary'),
          ),
          
        ],
      ),
    );
  }
}
