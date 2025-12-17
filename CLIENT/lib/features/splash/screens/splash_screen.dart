import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Durasi splash screen
  static const int _splashDuration = 3; 

  @override
  void initState() {
    super.initState();

    // Mengubah durasi menjadi 3 detik agar tidak terlalu lama
    Timer(const Duration(seconds: _splashDuration), () {
      if (mounted) {
        context.go('/landing');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Ambil warna primer dari tema
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      // Menggunakan Container dengan dekorasi gradien sebagai body
      body: Container(
        decoration: BoxDecoration(
          // Gradien untuk tampilan modern
          gradient: LinearGradient(
            colors: [
              primaryColor,
              primaryColor.withOpacity(0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Ikon/Logo Aplikasi (Placeholder)
              Icon(
                Icons.people_alt_rounded, // Menggunakan ikon yang relevan untuk HRIS
                size: 100,
                color: Colors.white,
              ),
              const SizedBox(height: 24),

              // 2. Nama Aplikasi
              const Text(
                "HRIS SIB 3B",
                style: TextStyle(
                  fontSize: 36,
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2.0, // Memberi sedikit jarak antar huruf
                ),
              ),
              const SizedBox(height: 8),
              
              // Subteks
              const Text(
                "Sistem Informasi Sumber Daya Manusia",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w300,
                ),
              ),

              const SizedBox(height: 80),

              // 3. Loading Indicator
              SizedBox(
                width: 30,
                height: 30,
                child: CircularProgressIndicator(
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                  backgroundColor: Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}