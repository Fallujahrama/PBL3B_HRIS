import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/department.dart';
import '../services/department_service.dart';
import '../../../widgets/app_drawer.dart';

class DepartmentListPage extends StatefulWidget {
  const DepartmentListPage({super.key});

  @override
  State<DepartmentListPage> createState() => _DepartmentListPageState();
}

class _DepartmentListPageState extends State<DepartmentListPage> {
  late Future<List<Department>> _futureDepartments;

  @override
  void initState() {
    super.initState();
    _futureDepartments = DepartmentService.fetchDepartments();
  }

  Future<void> _refreshDepartments() async {
    setState(() {
      _futureDepartments = DepartmentService.fetchDepartments();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Department'),
      ),
      drawer: const AppDrawer(),

      // 🔹 FAB untuk tambah department
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // buka form create (extra = null)
          final result = await context.push('/department-form');

          // kalau form sukses menyimpan, kita bisa pakai result == true
          if (result == true) {
            await _refreshDepartments();
          } else {
            // atau langsung refresh tanpa cek result pun boleh:
            await _refreshDepartments();
          }
        },
        child: const Icon(Icons.add),
      ),

      body: FutureBuilder<List<Department>>(
        future: _futureDepartments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final departments = snapshot.data ?? [];

          if (departments.isEmpty) {
            return const Center(
              child: Text('Tidak ada data department'),
            );
          }

          return ListView.builder(
            itemCount: departments.length,
            itemBuilder: (context, index) {
              final dept = departments[index];

              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                child: ListTile(
                  title: Text(dept.name),
                  leading: CircleAvatar(
                    child: Text(dept.id.toString()),
                  ),
                  trailing: const Icon(Icons.chevron_right),

                  // 👉 Pindah ke halaman detail, bawa object dept
                  onTap: () {
                    context.push(
                      '/department-detail',
                      extra: dept,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}