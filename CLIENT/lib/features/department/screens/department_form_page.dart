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
    _nameController =
        TextEditingController(text: widget.department?.name ?? '');
    _radiusController =
        TextEditingController(text: widget.department?.radius ?? '');
    _latitudeController =
        TextEditingController(text: widget.department?.latitude ?? '');
    _longitudeController =
        TextEditingController(text: widget.department?.longitude ?? '');
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
        // UPDATE
        await DepartmentService.updateDepartment(
          id: widget.department!.id,
          name: _nameController.text.trim(),
          radius: _radiusController.text.trim(),
          latitude: _latitudeController.text.trim().isEmpty
              ? null
              : _latitudeController.text.trim(),
          longitude: _longitudeController.text.trim().isEmpty
              ? null
              : _longitudeController.text.trim(),
        );
      } else {
        // CREATE
        await DepartmentService.createDepartment(
          name: _nameController.text.trim(),
          radius: _radiusController.text.trim(),
          latitude: _latitudeController.text.trim().isEmpty
              ? null
              : _latitudeController.text.trim(),
          longitude: _longitudeController.text.trim().isEmpty
              ? null
              : _longitudeController.text.trim(),
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isEdit
              ? 'Department berhasil diupdate'
              : 'Department berhasil dibuat'),
        ),
      );

      // Kembali ke halaman sebelumnya (list/detail)
      Navigator.of(context).pop(true); // bisa dipakai untuk refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
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
        title: Text(isEdit ? 'Edit Department' : 'Tambah Department'),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Department',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _radiusController,
                    decoration: const InputDecoration(
                      labelText: 'Radius (meter)',
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Radius wajib diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _latitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Latitude (opsional)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _longitudeController,
                    decoration: const InputDecoration(
                      labelText: 'Longitude (opsional)',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _save,
                      child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(isEdit ? 'Simpan Perubahan' : 'Simpan'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}