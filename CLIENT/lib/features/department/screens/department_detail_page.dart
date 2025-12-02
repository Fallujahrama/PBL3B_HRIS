import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/department.dart';
import '../services/department_service.dart';   // ⬅ penting untuk delete
import '../../../routes/app_routes.dart';      // ⬅ untuk pushNamed
import '../../../widgets/app_drawer.dart';

class DepartmentDetailPage extends StatelessWidget {
  final Department department;

  const DepartmentDetailPage({
    super.key,
    required this.department,
  });

  // ⬇ fungsi konfirmasi + delete
  Future<void> _confirmDelete(BuildContext context) async {
    final parentContext = context;

    final bool? confirmed = await showDialog<bool>(
      context: parentContext,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Hapus Department'),
          content: Text(
            'Yakin ingin menghapus "${department.name}"? Tindakan ini tidak bisa dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop(false); // Batal
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop(true); // Konfirmasi
              },
              child: const Text(
                'Hapus',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      try {
        // Panggil API delete
        await DepartmentService.deleteDepartment(department.id);

        // Beri info ke user
        ScaffoldMessenger.of(parentContext).showSnackBar(
          const SnackBar(content: Text('Department berhasil dihapus')),
        );

        // Kembali ke halaman sebelumnya, kirim result = true
        parentContext.pop(true);
      } catch (e) {
        ScaffoldMessenger.of(parentContext).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(department.name),
        actions: [
          // EDIT
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await context.pushNamed(
                AppRoutes.departmentForm,
                extra: department,
              );

              if (result == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Department berhasil diperbarui'),
                  ),
                );
              }
            },
          ),
          // DELETE
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _confirmDelete(context);
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  department.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Radius: ${department.radius} meter'),
                const SizedBox(height: 8),
                Text('Latitude : ${department.latitude ?? '-'}'),
                Text('Longitude: ${department.longitude ?? '-'}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}