import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/employee_model.dart';
// import '../models/department_model.dart';     // NEW
// import '../models/position_model.dart';       // NEW

import '../services/employee_api_service.dart';

class EmployeeAddScreen extends StatefulWidget {
  const EmployeeAddScreen({super.key});

  @override
  State<EmployeeAddScreen> createState() => _EmployeeAddScreenState();
}

class _EmployeeAddScreenState extends State<EmployeeAddScreen> {
  final _formKey = GlobalKey<FormState>();
  final _apiService = EmployeeApiService();

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _addressController = TextEditingController();

  String _selectedGender = 'L';
  int? _selectedPositionId; // NEW
  int? _selectedDepartmentId; // NEW
  int _userId = 1;

  String _email = "";
String _password = "";
bool _isAdmin = false;


  bool _isLoading = false;

  // ========== NEW: Data dari API ==========
  List<Position> _positions = []; // NEW
  List<Department> _departments = []; // NEW

  @override
  void initState() {
    super.initState();
    _loadMasterData(); // NEW
  }

  // ========== NEW: fetch data Position & Department ==========
  Future<void> _loadMasterData() async {
    try {
      _positions = await _apiService.fetchPositions();
      _departments = await _apiService.fetchDepartments();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal memuat data master: $e")));
    }
  }

  @override
  void dispose() {
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
      final employee = Employee(
        id: 0,
        userId: _userId,
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        gender: _selectedGender,
        positionId: _selectedPositionId,
        departmentId: _selectedDepartmentId,
        address: _addressController.text.isEmpty
            ? null
            : _addressController.text,
      );

      await _apiService.createEmployee(employee);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee added successfully')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
          'Tambah Employee',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
  padding: const EdgeInsets.all(16),
  children: [

    // =====================================
    // SECTION: USER ACCOUNT
    // =====================================
    const Text(
      'User Account',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 12),

    // Email
    const Text('Email', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    const SizedBox(height: 8),
    TextFormField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Enter email',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Email is required';
        return null;
      },
      onChanged: (v) => _email = v,
    ),
    const SizedBox(height: 16),

    // Password
    const Text('Password', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    const SizedBox(height: 8),
    TextFormField(
      obscureText: true,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Enter password',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Password is required';
        return null;
      },
      onChanged: (v) => _password = v,
    ),
    const SizedBox(height: 16),

    // Toggle is admin
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Is Admin', style: TextStyle(fontSize: 16)),
        Switch(
          value: _isAdmin,
          onChanged: (value) {
            setState(() => _isAdmin = value);
          },
        )
      ],
    ),

    const Divider(height: 32, thickness: 2),

    // =====================================
    // SECTION: EMPLOYEE
    // =====================================
    const Text(
      'Employee Information',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    ),
    const SizedBox(height: 12),

    // ============================
    // First name
    // ============================
    const Text('Nama Depan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    const SizedBox(height: 8),
    TextFormField(
      controller: _firstNameController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Enter first name',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter first name';
        return null;
      },
    ),
    const SizedBox(height: 16),

    // ============================
    // Last name
    // ============================
    const Text('Nama Belakang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    const SizedBox(height: 8),
    TextFormField(
      controller: _lastNameController,
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        hintText: 'Enter last name',
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Please enter last name';
        return null;
      },
    ),
    const SizedBox(height: 16),

    // ============================
    // Gender
    // ============================
    const Text('Gender', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    const SizedBox(height: 8),
    Row(
      children: [
        Expanded(
          child: RadioListTile<String>(
            title: const Text('M'),
            value: 'L',
            groupValue: _selectedGender,
            onChanged: (value) => setState(() => _selectedGender = value!),
          ),
        ),
        Expanded(
          child: RadioListTile<String>(
            title: const Text('F'),
            value: 'P',
            groupValue: _selectedGender,
            onChanged: (value) => setState(() => _selectedGender = value!),
          ),
        ),
      ],
    ),
    const SizedBox(height: 16),

    // ============================
    // Position
    // ============================
    const Text('Posisi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    const SizedBox(height: 8),
    DropdownButtonFormField<int>(
      decoration: const InputDecoration(border: OutlineInputBorder()),
      hint: const Text('Select position'),
      value: _selectedPositionId,
      items: _positions.map((pos) {
        return DropdownMenuItem<int>(
          value: pos.id,
          child: Text(pos.name),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedPositionId = value),
    ),
    const SizedBox(height: 16),

    // ============================
    // Department
    // ============================
    const Text('Departemen', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
    const SizedBox(height: 8),
    DropdownButtonFormField<int>(
      decoration: const InputDecoration(border: OutlineInputBorder()),
      hint: const Text('Select department'),
      value: _selectedDepartmentId,
      items: _departments.map((dept) {
        return DropdownMenuItem<int>(
          value: dept.id,
          child: Text(dept.name),
        );
      }).toList(),
      onChanged: (value) => setState(() => _selectedDepartmentId = value),
    ),
    const SizedBox(height: 16),

    // ============================
    // Address
    // ============================
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

    // ============================
    // SAVE BUTTON
    // ============================
    SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveEmployee,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text('Simpan', style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    ),
  ],
),

      ),
    );
  }
}
