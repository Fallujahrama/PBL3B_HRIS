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
        title: const Text(
          'DAFTAR DEPARTMENT',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
      drawer: const AppDrawer(),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/department-form');
          if (result == true) await _refreshDepartments();
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
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final departments = snapshot.data ?? [];

          if (departments.isEmpty) {
            return const Center(
              child: Text('Tidak ada data department'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: departments.length,
            itemBuilder: (context, index) {
              final dept = departments[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),

                  // ⬇️ Tampilkan nomor urut (1, 2, 3…)
                  leading: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      "${index + 1}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  title: Text(
                    dept.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  trailing: const Icon(Icons.chevron_right),

                  onTap: () {
                    context.push('/department-detail', extra: dept);
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
