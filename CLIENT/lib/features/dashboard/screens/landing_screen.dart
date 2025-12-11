import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF3D5A80), Color(0xFF2C4058)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo/Icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Color(0xFF4ECDC4),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Icon(
                        Icons.business_center,
                        color: Colors.white,
                        size: 60,
                      ),
                    ),
                    SizedBox(height: 40),
                    
                    // Welcome Text
                    Text(
                      'Welcome to',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 28,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 56, fontWeight: FontWeight.bold),
                        children: [
                          TextSpan(
                            text: 'HRIS ',
                            style: TextStyle(color: Colors.white),
                          ),
                          TextSpan(
                            text: 'System',
                            style: TextStyle(color: Color(0xFF4ECDC4)),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Description
                    Container(
                      constraints: BoxConstraints(maxWidth: 600),
                      child: Text(
                        'Platform manajemen sumber daya manusia yang lengkap untuk mengelola data karyawan, gaji, dan overtime dengan mudah dan efisien.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 18,
                          height: 1.6,
                        ),
                      ),
                    ),
                    SizedBox(height: 80),
                    
                    // Login Button
                    ElevatedButton(
                      onPressed: () => context.go('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4ECDC4),
                        padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 8,
                        shadowColor: Color(0xFF4ECDC4).withOpacity(0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.login, color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Text(
                            'Login',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 60),
                    
                    // Footer
                    Text(
                      '© 2024 HRIS System - PBL Project',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.6),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}