import 'package:flutter/material.dart';
import '../../../widgets/app_drawer.dart';
import '../../../theme/app_theme.dart';
import 'package:go_router/go_router.dart';

class LetterHomeScreen extends StatelessWidget {
  const LetterHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pengajuan Surat"),
      ),
      drawer: const AppDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Header Card
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
                    Icons.mail_outline,
                    size: 80,
                    color: AppTheme.primaryBlue,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Pengajuan Surat',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Sistem Pengajuan Surat Karyawan',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Menu Cards
            _buildMenuCard(
              context,
              icon: Icons.edit_document,
              title: 'Ajukan Surat',
              subtitle: 'Buat pengajuan surat baru',
              color: AppTheme.secondaryGreen,
              onTap: () => context.go('/form-surat'),
            ),
            
            const SizedBox(height: 16),
            
            _buildMenuCard(
              context,
              icon: Icons.settings,
              title: 'Kelola Template Surat',
              subtitle: 'Manajemen template (Admin)',
              color: AppTheme.primaryBlue,
              onTap: () => context.go('/letters'),
            ),
            
            const SizedBox(height: 16),
            
            _buildMenuCard(
              context,
              icon: Icons.list_alt,
              title: 'Daftar Pengajuan',
              subtitle: 'Review surat karyawan (HRD)',
              color: AppTheme.accentOrange,
              onTap: () => context.go('/hrd-list'),
            ),
            
            const SizedBox(height: 16),
            
            // ✅ TOMBOL LAPORAN (BARU)
            _buildMenuCard(
              context,
              icon: Icons.assessment,
              title: 'Laporan Rekap Karyawan',
              subtitle: 'Lihat statistik dan laporan',
              color: AppTheme.accentPurple,
              onTap: () => context.go('/employee-recap'),
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