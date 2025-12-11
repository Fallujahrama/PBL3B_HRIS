import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeEditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> data;

  const EmployeeEditProfileScreen(this.data, {super.key});

  @override
  EmployeeEditProfileScreenState createState() =>
      EmployeeEditProfileScreenState();
}

class EmployeeEditProfileScreenState
    extends State<EmployeeEditProfileScreen> {
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController addressController;

  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    firstNameController =
        TextEditingController(text: widget.data["first_name"] ?? '');
    lastNameController =
        TextEditingController(text: widget.data["last_name"] ?? '');
    addressController =
        TextEditingController(text: widget.data["address"] ?? '');
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    setState(() => isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Token tidak ditemukan. Silakan login ulang.')),
        );
        setState(() => isSaving = false);
        return;
      }

      final url = Uri.parse('http://localhost:8000/api/employee/profile');

      final body = {
        "first_name": firstNameController.text.trim(),
        "last_name": lastNameController.text.trim(),
        "address": addressController.text.trim(),
      };

      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonBody = jsonDecode(response.body);
        final updatedData = jsonBody["data"] ?? jsonBody;

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil diperbarui")),
        );

        Navigator.pop(context, updatedData);
      } else {
        final jsonBody = jsonDecode(response.body);
        final message = jsonBody["message"] ??
            jsonBody["errors"]?.toString() ??
            "Gagal menyimpan perubahan";

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        backgroundColor: Color(0xFF446A8C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildInput("First Name", firstNameController),
            const SizedBox(height: 12),
            buildInput("Last Name", lastNameController),
            const SizedBox(height: 12),
            buildInput("Address", addressController, maxLines: 3),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSaving ? null : saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF446A8C),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSaving
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        "Save Changes",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildInput(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
