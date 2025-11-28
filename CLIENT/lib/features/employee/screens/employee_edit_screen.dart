import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/employee_model.dart';
import '../services/employee_api_service.dart';

class EmployeeEditScreen extends StatefulWidget {
  final String employeeId;

  const EmployeeEditScreen({super.key, required this.employeeId});

  @override
  State<EmployeeEditScreen> createState() => _EmployeeEditScreenState();
}

class _EmployeeEditScreenState extends State<EmployeeEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = EmployeeApiService();
  
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();
  
  String _selectedGender = 'L';
  int? _selectedPositionId;
  int? _selectedDepartmentId;
  int? _userId;
  
  bool _isLoading = true;
  bool _isSaving = false;

  final List<Map<String, dynamic>> _positions = [
    {'id': 1, 'name': 'Chef'},
    {'id': 2, 'name': 'Bartender'},
    {'id': 3, 'name': 'Waiter'},
  ];

  final List<Map<String, dynamic>> _departments = [
    {'id': 1, 'name': 'Kitchen'},
    {'id': 2, 'name': 'Bar'},
    {'id': 3, 'name': 'Service'},
  ];

  @override
  void initState() {
    super.initState();
    _loadEmployee();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadEmployee() async {
    try {
      final employee = await _apiService.getEmployeeById(int.parse(widget.employeeId));
      
      setState(() {
        _firstNameController.text = employee.firstName;
        _lastNameController.text = employee.lastName;
        _addressController.text = employee.address ?? '';
        _selectedGender = employee.gender;
        _selectedPositionId = employee.positionId;
        _selectedDepartmentId = employee.departmentId;
        _userId = employee.userId;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading employee: $e')),
        );
        context.pop();
      }
    }
  }

  Future<void> _updateEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final employee = Employee(
        id: int.parse(widget.employeeId),
        userId: _userId!,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        gender: _selectedGender,
        positionId: _selectedPositionId,
        departmentId: _selectedDepartmentId,
        address: _addressController.text.isEmpty ? null : _addressController.text,
      );

      await _apiService.updateEmployee(int.parse(widget.employeeId), employee);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee updated successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Employee', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Text('Nama Depan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter first name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter first name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text('Nama Belakang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter last name',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter last name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text('Gender', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('L'),
                          value: 'L',
                          groupValue: _selectedGender,
                          onChanged: (value) => setState(() => _selectedGender = value!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('P'),
                          value: 'P',
                          groupValue: _selectedGender,
                          onChanged: (value) => setState(() => _selectedGender = value!),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Other'),
                          value: 'O',
                          groupValue: _selectedGender,
                          onChanged: (value) => setState(() => _selectedGender = value!),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  const Text('Posisi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    hint: const Text('Select position'),
                    value: _selectedPositionId,
                    items: _positions.map((pos) {
                      return DropdownMenuItem<int>(
                        value: pos['id'],
                        child: Text(pos['name']),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedPositionId = value),
                  ),
                  const SizedBox(height: 16),

                  const Text('Departemen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    hint: const Text('Select department'),
                    value: _selectedDepartmentId,
                    items: _departments.map((dept) {
                      return DropdownMenuItem<int>(
                        value: dept['id'],
                        child: Text(dept['name']),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedDepartmentId = value),
                  ),
                  const SizedBox(height: 16),

                  const Text('Alamat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _addressController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter address',
                    ),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _updateEmployee,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: _isSaving
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Update', style: TextStyle(fontSize: 16, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}