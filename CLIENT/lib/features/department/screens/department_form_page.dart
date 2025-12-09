import 'package:flutter/material.dart';

import '../models/department.dart';
import '../services/department_service.dart';
import '../../../widgets/app_drawer.dart';

class DepartmentFormPage extends StatefulWidget {
  final Department? department; // null => create, != null => edit

  const DepartmentFormPage({super.key, this.department});

  @override
  State<DepartmentFormPage> createState() => _DepartmentFormPageState();
}

class _DepartmentFormPageState extends State<DepartmentFormPage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _radiusController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  bool _isSaving = false;

  bool get isEdit => widget.department != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.department?.name ?? '');
    _radiusController = TextEditingController(text: widget.department?.radius ?? '');
    _latitudeController = TextEditingController(text: widget.department?.latitude ?? '');
    _longitudeController = TextEditingController(text: widget.department?.longitude ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _radiusController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      if (isEdit) {
        await DepartmentService.updateDepartment(
          id: widget.department!.id,
          name: _nameController.text.trim(),
          radius: _radiusController.text.trim(),
          latitude: _latitudeController.text.trim().isEmpty ? null : _latitudeController.text.trim(),
          longitude: _longitudeController.text.trim().isEmpty ? null : _longitudeController.text.trim(),
        );
      } else {
        await DepartmentService.createDepartment(
          name: _nameController.text.trim(),
          radius: _radiusController.text.trim(),
          latitude: _latitudeController.text.trim().isEmpty ? null : _latitudeController.text.trim(),
          longitude: _longitudeController.text.trim().isEmpty ? null : _longitudeController.text.trim(),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit ? 'Department berhasil diupdate' : 'Department berhasil dibuat'),
        ),
      );

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
    icon: const Icon(Icons.arrow_back),
    onPressed: () => Navigator.pop(context),
  ),
        title: Text(
          isEdit ? 'Edit Department' : 'Tambah Department',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      drawer: const AppDrawer(),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // const Text(
                    //   'Informasi Department',
                    //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    // ),
                    // const SizedBox(height: 16),

                    // Name
                    const Text('Nama Department', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.business),
                        hintText: 'Masukkan nama department',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Nama wajib diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Radius
                    const Text('Radius (meter)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _radiusController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.radar),
                        hintText: 'Masukkan radius',
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return 'Radius wajib diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Latitude
                    const Text('Latitude (opsional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _latitudeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                        hintText: 'Masukkan latitude',
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Longitude
                    const Text('Longitude (opsional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _longitudeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on_outlined),
                        hintText: 'Masukkan longitude',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),

          // SAVE BUTTON
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      isEdit ? 'Simpan' : 'Simpan',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
