import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../letter/controllers/letter_controller.dart';
import '../../letter/models/letter_format.dart';
import '../services/api_service.dart';

class FormSuratPage extends StatefulWidget {
  const FormSuratPage({super.key});

  @override
  State<FormSuratPage> createState() => _FormSuratPageState();
}

class _FormSuratPageState extends State<FormSuratPage> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController jabatanController = TextEditingController();
  final TextEditingController departemenController = TextEditingController();

  final LetterController letterController = LetterController();

  List<LetterFormat> templateList = [];
  LetterFormat? selectedTemplate;
  DateTime? tanggalMulai;
  DateTime? tanggalSelesai;

  bool isLoading = true;

  int? employeeId;
  int? positionId;
  int? departmentId;

  @override
  void initState() {
    super.initState();
    initData();
  }

  Future<void> initData() async {
    setState(() => isLoading = true);

    try {
      final response = await ApiService.fetchProfile();

      print("PROFILE RESPONSE => $response");

      if (response == null || response is! Map) {
        throw "Response profile tidak valid";
      }

      final employee = response['employee'];

      if (employee == null) {
        throw "Data employee tidak ditemukan";
      }

      // Simpan ID
      employeeId = employee['id'];
      positionId = employee['position_id'];
      departmentId = employee['department_id'];

      // Autofill input
      namaController.text = 
        "${employee['first_name'] ?? ''} ${employee['last_name'] ?? ''}".trim();
      jabatanController.text = employee['position']?['name'] ?? '';
      departemenController.text = employee['department']?['name'] ?? '';

      // Load template surat
      templateList = await letterController.fetchLetterFormats();
      print('✅ Templates loaded: ${templateList.length} items');
      for (var t in templateList) {
        print('  - ${t.id}: ${t.name}');
      }
    } catch (e) {
      print("ERROR initData(): $e");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal memuat data: $e")),
        );
      }
    }

    if (mounted) setState(() => isLoading = false);
  }

  Future<void> pickTanggalMulai() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2050),
    );

    if (picked != null) {
      setState(() {
        tanggalMulai = picked;
      });
    }
  }

  Future<void> pickTanggalSelesai() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: tanggalMulai ?? DateTime.now(),
      firstDate: tanggalMulai ?? DateTime.now(),
      lastDate: DateTime(2050),
    );

    if (picked != null) {
      setState(() {
        tanggalSelesai = picked;
      });
    }
  }

  Future<void> submitSurat() async {
    if (selectedTemplate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih jenis surat terlebih dahulu!')),
      );
      return;
    }

    if (tanggalMulai == null || tanggalSelesai == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih tanggal mulai dan selesai!')),
      );
      return;
    }

    final data = {
      'letter_format_id': selectedTemplate!.id,
      'tanggal_mulai': tanggalMulai!.toIso8601String().split('T')[0],    // YYYY-MM-DD
      'tanggal_selesai': tanggalSelesai!.toIso8601String().split('T')[0], // YYYY-MM-DD
    };

    print('📤 Submitting letter data: $data');

    try {
      final success = await ApiService.createPengajuanSurat(data);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Surat berhasil diajukan!'),
            backgroundColor: Colors.green,
          ),
        );

        // Kembali ke home
        context.go('/letter-home');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ Gagal mengajukan surat'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('❌ Submit error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget inputBox({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xffb5d8ff)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xffe7f2ff), Color(0xffd3e8ff)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                    onPressed: () => context.go('/letter-home'),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xff1e6ab3),
                    ),
                  ),

                  const SizedBox(height: 5),

                  const Text(
                    "Form Pengajuan Surat",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xff1e6ab3),
                    ),
                  ),
                  const SizedBox(height: 25),

                  if (isLoading)
                    const Center(child: CircularProgressIndicator())
                  else ...[
                    // NAMA
                    inputBox(
                      child: TextField(
                        controller: namaController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Nama Lengkap",
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // JABATAN
                    inputBox(
                      child: TextField(
                        controller: jabatanController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Jabatan",
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // DEPARTEMEN
                    inputBox(
                      child: TextField(
                        controller: departemenController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Departemen",
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // TEMPLATE
                    inputBox(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<LetterFormat>(
                          value: selectedTemplate,
                          hint: const Text(
                            "Pilih Jenis Surat",
                            style: TextStyle(color: Colors.blue),
                          ),
                          isExpanded: true,
                          items: templateList.map((template) {
                            return DropdownMenuItem(
                              value: template,
                              child: Text(template.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedTemplate = value;
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // TANGGAL MULAI
                    GestureDetector(
                      onTap: pickTanggalMulai,
                      child: inputBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tanggalMulai == null
                                  ? "Pilih Tanggal Mulai"
                                  : "${tanggalMulai!.day}-${tanggalMulai!.month}-${tanggalMulai!.year}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_month,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // TANGGAL SELESAI
                    GestureDetector(
                      onTap: pickTanggalSelesai,
                      child: inputBox(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              tanggalSelesai == null
                                  ? "Pilih Tanggal Selesai"
                                  : "${tanggalSelesai!.day}-${tanggalSelesai!.month}-${tanggalSelesai!.year}",
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                              ),
                            ),
                            const Icon(
                              Icons.calendar_month,
                              color: Colors.blue,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 35),

                    // TOMBOL SUBMIT
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: submitSurat,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xff4da3ff),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shadowColor: Colors.black.withOpacity(0.2),
                          elevation: 5,
                        ),
                        child: const Text(
                          "Ajukan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    namaController.dispose();
    jabatanController.dispose();
    departemenController.dispose();
    super.dispose();
  }
}
