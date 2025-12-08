import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/department.dart';
import '../services/department_service.dart';
import '../../../routes/app_routes.dart';
import '../../../widgets/app_drawer.dart';

class DepartmentDetailPage extends StatelessWidget {
  final Department department;

  const DepartmentDetailPage({
    super.key,
    required this.department,
  });

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
                Navigator.of(dialogCtx).pop(false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogCtx).pop(true);
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
        await DepartmentService.deleteDepartment(department.id);

        ScaffoldMessenger.of(parentContext).showSnackBar(
          const SnackBar(content: Text('Department berhasil dihapus')),
        );

        parentContext.pop(true);
      } catch (e) {
        ScaffoldMessenger.of(parentContext).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e')),
        );
      }
    }
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [
          Icon(icon, size: 28, color: Colors.deepPurple),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(department.name),
        actions: [
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
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFF5F6FA),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.deepPurple,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.deepPurple.withOpacity(0.3),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    department.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "Detail Lokasi Department",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Radius
            _infoTile(
              icon: Icons.radar,
              label: "Radius",
              value: "${department.radius} meter",
            ),

            const SizedBox(height: 16),

            // Latitude
            _infoTile(
              icon: Icons.location_on,
              label: "Latitude",
              value: department.latitude?.toString() ?? "-",
            ),

            const SizedBox(height: 16),

            // Longitude
            _infoTile(
              icon: Icons.location_on_outlined,
              label: "Longitude",
              value: department.longitude?.toString() ?? "-",
            ),
          ],
        ),
      ),
    );
  }
}
