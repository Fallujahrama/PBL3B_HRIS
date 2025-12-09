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
  static const Color _scaffoldBgColor = Color(0xFFF5F6F8);
  static const EdgeInsets _listPadding = EdgeInsets.fromLTRB(16, 16, 16, 80);

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

  void _navigateToForm() async {
    final result = await context.push('/department-form');
    if (result == true) await _refreshDepartments();
  }

  // ------------------------------------------------------------
  // CARD STYLING — sama persis dengan style EMPLOYEE LIST
  // ------------------------------------------------------------
  Widget _departmentCard(Department dept, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7), // warna card employee
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            spreadRadius: 1,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),

      child: ListTile(
        contentPadding: EdgeInsets.zero,

        leading: CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFFCFE3FF), // avatar seperti employee
          child: Text(
            dept.name.isNotEmpty ? dept.name[0].toUpperCase() : "?",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color(0xFF2F6FE4), // teks avatar employee
            ),
          ),
        ),

        title: Text(
          dept.name,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),

        subtitle: const Text(
          "Department",
          style: TextStyle(fontSize: 13, color: Colors.black54),
        ),

        trailing: const Icon(Icons.chevron_right, color: Colors.black54),

        onTap: () {
          context.push('/department-detail', extra: dept);
        },
      ),
    );
  }

  // ------------------------------------------------------------
  // FUTURE BUILDER CONTENT
  // ------------------------------------------------------------
  Widget _buildBody(BuildContext context) {
    return FutureBuilder<List<Department>>(
      future: _futureDepartments,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 60, color: Colors.red),
                const SizedBox(height: 10),
                Text("Error: ${snapshot.error}"),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _refreshDepartments,
                  child: const Text("Retry"),
                ),
              ],
            ),
          );
        }

        final departments = snapshot.data ?? [];

        if (departments.isEmpty) {
          return const Center(child: Text("Belum ada department."));
        }

        return RefreshIndicator(
          onRefresh: _refreshDepartments,
          child: ListView.builder(
            padding: _listPadding,
            itemCount: departments.length,
            itemBuilder: (context, i) => _departmentCard(departments[i], i),
          ),
        );
      },
    );
  }

  // ------------------------------------------------------------
  // MAIN
  // ------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const AppDrawer(),

      appBar: AppBar(
        title: const Text(
          "MASTER DEPARTMENTS",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToForm,
        backgroundColor: Theme.of(context).colorScheme.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        child: const Icon(Icons.add_rounded, size: 30, color: Colors.white),
      ),

      body: _buildBody(context),
    );
  }
}
