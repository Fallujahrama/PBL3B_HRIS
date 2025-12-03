import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/employee_model.dart';
import '../services/employee_api_service.dart';
import '../../../widgets/app_drawer.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final EmployeeApiService _apiService = EmployeeApiService();
  List<Employee> _employees = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final employees = await _apiService.getAllEmployees();
      setState(() {
        _employees = employees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KARYAWAN', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),

      ),
      drawer: const AppDrawer(),
      body: _buildBody(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/employee/add').then((_) => _loadEmployees()),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Karyawan'),
        backgroundColor: Colors.blue,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEmployees,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_employees.isEmpty) {
      return const Center(child: Text('Tidak ada karyawan yang ditemukan'));
    }

    return RefreshIndicator(
      onRefresh: _loadEmployees,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _employees.length,
        itemBuilder: (context, index) {
          final employee = _employees[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  employee.firstName[0].toUpperCase(),
                  style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(
                employee.fullName,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(employee.position?.name ?? 'No Position'),
                  Text(employee.department?.name ?? 'No Department', style: const TextStyle(color: Colors.grey)),
                ],
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/employee/detail/${employee.id}').then((_) => _loadEmployees()),
            ),
          );
        },
      ),
    );
  }
}