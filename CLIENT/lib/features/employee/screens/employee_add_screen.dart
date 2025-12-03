import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/employee_model.dart';
import '../services/employee_api_service.dart';

class EmployeeAddScreen extends StatefulWidget {
  const EmployeeAddScreen({super.key});

  @override
  State<EmployeeAddScreen> createState() => _EmployeeAddScreenState();
}

class _EmployeeAddScreenState extends State<EmployeeAddScreen> {
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

  String _selectedGender = 'L';
  int? _selectedPositionId;
  int? _selectedDepartmentId;

  bool _isLoading = false;

  List<Position> _positions = [];
  List<Department> _departments = [];

  @override
  void initState() {
    super.initState();
    _loadMasterData();
  }

  Future<void> _loadMasterData() async {
    try {
      _positions = await _apiService.fetchPositions();
      _departments = await _apiService.fetchDepartments();
      setState(() {});
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data master: $e")),
        );
      }
    }
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

  Future<void> _saveEmployee() async {
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
        'password': _passwordController.text,
        'is_admin': _isAdmin,
        
        // Employee data
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'gender': _selectedGender,
        'position_id': _selectedPositionId,
        'department_id': _selectedDepartmentId,
        'address': _addressController.text.isEmpty ? null : _addressController.text,
      };

      await _apiService.createEmployee(requestData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Karyawan berhasil ditambahkan')),
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
          'Tambah Karyawan',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Form(
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
                        if (value == null || value.isEmpty) return 'Email wajib diisi';
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
                        hintText: 'Masukkan kata sandi (minimal 6 karakter)',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Password wajib diisi';
                        if (value.length < 6) return 'Password minimal 6 karakter';
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
                        hintText: 'Masukkan Nama Depan',
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
                        hintText: 'Masukkan Nama Belakang',
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
                      hint: const Text('Pilih departemen'),
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

            // SAVE BUTTON
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveEmployee,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Simpan',
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