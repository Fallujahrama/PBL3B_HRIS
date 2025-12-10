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
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          title: const Text('Hapus Department'),
          content: Text(
            'Yakin ingin menghapus "${department.name}"? Tindakan ini tidak bisa dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx, true),
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

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Department berhasil dihapus')),
        );

        context.pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
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
          Icon(icon, size: 28, color: Colors.blueGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
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
      drawer: const AppDrawer(),
      backgroundColor: const Color(0xFFF5F6FA),

      // ----------------------------------------
      // APP BAR: tombol BACK saja
      // ----------------------------------------
      appBar: AppBar(
        leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => Navigator.pop(context),
  ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
        title: Text(
          department.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ---------------- HEADER CARD ----------------
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.28),
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

            const SizedBox(height: 26),

            // ---------------- INFORMATION TILES ----------------
            _infoTile(
              icon: Icons.radar,
              label: "Radius",
              value: "${department.radius} meter",
            ),

            const SizedBox(height: 16),

            _infoTile(
              icon: Icons.location_on,
              label: "Latitude",
              value: department.latitude?.toString() ?? "-",
            ),

            const SizedBox(height: 16),

            _infoTile(
              icon: Icons.location_on_outlined,
              label: "Longitude",
              value: department.longitude?.toString() ?? "-",
            ),

            const SizedBox(height: 40),

            // ---------------- BOTTOM BUTTON AREA ----------------
            Row(
              children: [
                // EDIT BUTTON
                Expanded(
                  child: ElevatedButton.icon(
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
                    icon: const Icon(Icons.edit, size: 18, color: Colors.white),
                    label: const Text("Edit", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF375A8C),
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // DELETE BUTTON
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _confirmDelete(context),
                    icon: const Icon(Icons.delete, size: 18, color: Colors.white),
                    label: const Text("Hapus", style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 28),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
