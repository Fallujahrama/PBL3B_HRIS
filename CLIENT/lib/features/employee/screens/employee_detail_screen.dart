import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/employee_model.dart';
import '../services/employee_api_service.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final String employeeId;

  const EmployeeDetailScreen({super.key, required this.employeeId});

  @override
  State<EmployeeDetailScreen> createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  final _apiService = EmployeeApiService();
  Employee? _employee;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadEmployee();
  }

  Future<void> _loadEmployee() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final employee = await _apiService.getEmployeeById(int.parse(widget.employeeId));
      setState(() {
        _employee = employee;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteEmployee() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Employee'),
        content: const Text('Are you sure you want to delete this employee?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _apiService.deleteEmployee(int.parse(widget.employeeId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee deleted successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Detail', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(),
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
              onPressed: _loadEmployee,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_employee == null) {
      return const Center(child: Text('Employee not found'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              _employee!.firstName[0].toUpperCase(),
              style: const TextStyle(fontSize: 40, color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

          Text(
            _employee!.fullName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildDetailRow('Nama Depan', _employee!.firstName),
                  const Divider(),
                  _buildDetailRow('Nama Belakang', _employee!.lastName),
                  const Divider(),
                  _buildDetailRow('Gender', _employee!.gender),
                  const Divider(),
                  _buildDetailRow('Posisi', _employee!.position?.name ?? '-'),
                  const Divider(),
                  _buildDetailRow('Departemen', _employee!.department?.name ?? '-'),
                  const Divider(),
                  _buildDetailRow('Alamat', _employee!.address ?? '-'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/employee/edit/${widget.employeeId}').then((_) => _loadEmployee());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Update', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _deleteEmployee,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Delete', style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}