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

  // User fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isAdmin = false;

  // Employee fields
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedGender = 'M';
  int? _selectedPositionId;
  int? _selectedDepartmentId;

  bool _isLoading = false;
  bool _isLoadingData = true;

  List<Position> _positions = [];
  List<Department> _departments = [];

  Employee? _employee;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      // Load master data dan employee data secara bersamaan
      await Future.wait([
        _loadMasterData(),
        _loadEmployeeData(),
      ]);

      setState(() => _isLoadingData = false);
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data: $e")),
        );
      }
    }
  }

  Future<void> _loadMasterData() async {
    _positions = await _apiService.fetchPositions();
    _departments = await _apiService.fetchDepartments();
  }

  Future<void> _loadEmployeeData() async {
    final id = int.parse(widget.employeeId);
    _employee = await _apiService.getEmployeeById(id);

    // Populate form dengan data employee
    _emailController.text = _employee!.user?.email ?? '';
    _isAdmin = _employee!.user?.isAdmin ?? false;

    _firstNameController.text = _employee!.firstName;
    _lastNameController.text = _employee!.lastName;
    _selectedGender = _employee!.gender;
    _selectedPositionId = _employee!.position?.id;
    _selectedDepartmentId = _employee!.department?.id;
    _addressController.text = _employee!.address ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _updateEmployee() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedPositionId == null || _selectedDepartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Posisi dan Departemen wajib dipilih")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Data yang dikirim ke API sesuai dengan Laravel Controller
      final requestData = {
        // User data
        'email': _emailController.text,
        'is_admin': _isAdmin,
        
        // Employee data
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'gender': _selectedGender,
        'position_id': _selectedPositionId,
        'department_id': _selectedDepartmentId,
        'address': _addressController.text.isEmpty ? null : _addressController.text,
      };

      // Tambahkan password hanya jika diisi
      if (_passwordController.text.isNotEmpty) {
        requestData['password'] = _passwordController.text;
      }

      await _apiService.updateEmployee(int.parse(widget.employeeId), requestData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Karyawan berhasil diperbarui')),
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
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Karyawan',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // =====================================
                  // CARD: USER ACCOUNT
                  // =====================================
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Akun Pengguna',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),

                          // Email
                          const Text('Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Masukkan email',
                              prefixIcon: Icon(Icons.email),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Email harus diisi';
                              if (!value.contains('@')) return 'Email tidak valid';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password
                          const Text('Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Kosongkan jika tidak ingin mengubah password',
                              prefixIcon: Icon(Icons.lock),
                            ),
                            validator: (value) {
                              if (value != null && value.isNotEmpty && value.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Toggle is admin
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Admin ?', style: TextStyle(fontSize: 16)),
                                Switch(
                                  value: _isAdmin,
                                  onChanged: (value) {
                                    setState(() => _isAdmin = value);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =====================================
                  // CARD: EMPLOYEE INFORMATION
                  // =====================================
                  Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Informasi Karyawan',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),

                          // First name
                          const Text('Nama Depan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _firstNameController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Masukkan nama depan',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Nama depan wajib diisi';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Last name
                          const Text('Nama Belakang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _lastNameController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Masukkan nama belakang',
                              prefixIcon: Icon(Icons.person_outline),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Nama belakang wajib diisi';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Gender
                          const Text('Jenis Kelamin', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey.shade300),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('L'),
                                    value: 'M',
                                    groupValue: _selectedGender,
                                    onChanged: (value) => setState(() => _selectedGender = value!),
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('P'),
                                    value: 'F',
                                    groupValue: _selectedGender,
                                    onChanged: (value) => setState(() => _selectedGender = value!),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Position
                          const Text('Posisi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.work),
                            ),
                            hint: const Text('Pilih Posisi'),
                            value: _selectedPositionId,
                            items: _positions.map((pos) {
                              return DropdownMenuItem<int>(
                                value: pos.id,
                                child: Text(pos.name),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedPositionId = value),
                            validator: (value) {
                              if (value == null) return 'Posisi wajib dipilih';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Department
                          const Text('Departemen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          DropdownButtonFormField<int>(
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              prefixIcon: Icon(Icons.business),
                            ),
                            hint: const Text('Pilih Departemen'),
                            value: _selectedDepartmentId,
                            items: _departments.map((dept) {
                              return DropdownMenuItem<int>(
                                value: dept.id,
                                child: Text(dept.name),
                              );
                            }).toList(),
                            onChanged: (value) => setState(() => _selectedDepartmentId = value),
                            validator: (value) {
                              if (value == null) return 'Departemen wajib dipilih';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Address
                          const Text('Alamat', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _addressController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Masukkan Alamat',
                              prefixIcon: Icon(Icons.home),
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // UPDATE BUTTON
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _updateEmployee,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Edit',
                              style: TextStyle(fontSize: 16, color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}