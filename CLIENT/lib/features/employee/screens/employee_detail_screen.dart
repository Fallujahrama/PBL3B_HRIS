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
        context.pop(true);
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
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 70,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              _employee!.firstName[0].toUpperCase(),
              style: const TextStyle(fontSize: 48, color: Colors.blue, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 20),

          // Full Name
          Text(
            _employee!.fullName,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),

          // Information Card dengan layout yang lebih besar dan rapih
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Nama Depan', _employee!.firstName),
                  const Divider(height: 32, thickness: 1),
                  
                  _buildDetailRow('Nama Belakang', _employee!.lastName),
                  const Divider(height: 32, thickness: 1),
                  
                  _buildDetailRow(
                    'Gender', 
                    _employee!.gender == 'M' ? 'Laki-laki' : 'Perempuan'
                  ),
                  const Divider(height: 32, thickness: 1),
                  
                  _buildDetailRow('Posisi', _employee!.position?.name ?? '-'),
                  const Divider(height: 32, thickness: 1),
                  
                  _buildDetailRow('Departemen', _employee!.department?.name ?? '-'),
                  const Divider(height: 32, thickness: 1),
                  
                  _buildDetailRow('Alamat', _employee!.address ?? '-'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 30),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.push('/employee/edit/${widget.employeeId}').then((_) => _loadEmployee());
                    },
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text('Update', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _deleteEmployee,
                    icon: const Icon(Icons.delete, color: Colors.white),
                    label: const Text('Delete', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget untuk menampilkan label di atas dan value di bawah dengan spacing yang lebih baik
  Widget _buildDetailRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}