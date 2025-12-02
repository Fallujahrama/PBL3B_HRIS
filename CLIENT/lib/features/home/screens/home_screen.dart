import 'package:flutter/material.dart';
import '../../../widgets/app_drawer.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Selamat Datang"),
      ),
      drawer: const AppDrawer(),
      body: Center(
        // child: ElevatedButton(
        //   onPressed: () => context.go('/superior'),
        //   child: const Text("Lihat Data Superior"),
        // ),
      ),
    );
  }
}
