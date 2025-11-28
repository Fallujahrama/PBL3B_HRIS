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

          // MENU HOME (tetap)
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text("Home"),
            onTap: () => context.go('/home'),
          ),

          // MENU SUPERIOR (tetap)
          ListTile(
            leading: const Icon(Icons.group),
            title: const Text("Superior"),
            onTap: () => context.go('/superior'),
          ),

          // 🌟 MENU BARU: DEPARTMENT
          ListTile(
            leading: const Icon(Icons.apartment),
            title: const Text("Department"),
            onTap: () => context.go('/departments'),
          ),
        ],
      ),
    );
  }
} 