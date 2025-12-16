import 'package:flutter/material.dart';
import '../../../widgets/app_drawer.dart';
import 'package:go_router/go_router.dart';
import '../../../theme/app_theme.dart';

class MasterDataScreen extends StatelessWidget {
  const MasterDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // 1. Disesuaikan: Judul AppBar
        title: const Text("Manajemen Data Karyawan"),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Header Card - Disesuaikan untuk Master Data
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    // 2. Disesuaikan: Ikon
                    Icons.storage_outlined, 
                    size: 80,
                    color: AppTheme.primaryBlue,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    // 2. Disesuaikan: Judul Header
                    'Master Data',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    // 2. Disesuaikan: Subjudul Header
                    'Kelola data dasar untuk operasional sistem',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Menu Cards - Disesuaikan
            
            // Menu 1: /positions -> Kelola Jabatan
            _buildMenuCard(
              context,
              icon: Icons.badge_outlined, // Disesuaikan Ikon
              title: 'Kelola Jabatan', // Disesuaikan Judul
              subtitle: 'Tambahkan, ubah, dan hapus data jabatan', // Disesuaikan Subjudul
              color: AppTheme.secondaryGreen,
              onTap: () => context.go('/positions'),
            ),
            
            const SizedBox(height: 16),
            
            // Menu 2: /departments -> Kelola Departemen
            _buildMenuCard(
              context,
              icon: Icons.business_outlined, // Disesuaikan Ikon
              title: 'Kelola Departemen', // Disesuaikan Judul
              subtitle: 'Manajemen data unit departemen dan divisi', // Disesuaikan Subjudul
              color: AppTheme.primaryBlue,
              onTap: () => context.go('/departments'),
            ),
            
            const SizedBox(height: 16),
            
            // Menu 3: /department-map -> Mapping Departemen
            _buildMenuCard(
              context,
              icon: Icons.link_outlined, // Disesuaikan Ikon
              title: 'Mapping Departemen', // Disesuaikan Judul
              subtitle: 'Hubungkan dan petakan struktur antar departemen', // Disesuaikan Subjudul
              color: AppTheme.accentOrange, // Warna diubah agar berbeda dari menu sebelumnya
              onTap: () => context.go('/department-map'),
            ),
            
            const SizedBox(height: 16),
            
            // Menu 4: /employee -> Kelola Data Karyawan
            _buildMenuCard(
              context,
              icon: Icons.people_alt_outlined, // Disesuaikan Ikon
              title: 'Kelola Data Karyawan', // Disesuaikan Judul
              subtitle: 'Daftar dan manajemen data personal karyawan', // Disesuaikan Subjudul
              color: AppTheme.accentOrange,
              onTap: () => context.go('/employee'),
            ),
            
          
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}