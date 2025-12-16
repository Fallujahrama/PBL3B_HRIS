import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hris_3B/widgets/app_drawer.dart';
import '../../letter/controllers/letter_controller.dart';
import '../../letter/models/letter_format.dart';
import '../../login/models/user_logged_model.dart'; // Akses Singleton
import '../../login/models/user_model.dart'; // Model User
import '../services/api_service.dart'; // Digunakan di submitSurat

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
      // --- PENGAMBILAN DATA DARI USERLOGGEDMODEL ---
      final userModel = UserLoggedModel();
      final employee = userModel.employeeData; 

      if (employee == null) {
        if (!userModel.isLoggedIn) {
             throw "Sesi hilang. Harap login kembali.";
        }
        throw "Data employee tidak ditemukan di sesi."; 
      }

      // Simpan ID
      employeeId = employee['id'];
      positionId = employee['position_id'];
      departmentId = employee['department_id'];

      // Autofill input
      final firstName = employee['first_name'] ?? '';
      final lastName = employee['last_name'] ?? '';
      namaController.text = "$firstName $lastName".trim();

      // Akses nested map untuk jabatan dan departemen
      final positionName = employee['position']?['name'] ?? 'N/A';
      final departmentName = employee['department']?['name'] ?? 'N/A';
      
      jabatanController.text = positionName;
      departemenController.text = departmentName;

      // Load template surat (Membutuhkan API Call)
      templateList = await letterController.fetchLetterFormats();
      print('✅ Templates loaded: ${templateList.length} items');
      
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

    if (employeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data profil tidak lengkap. Coba relogin.')),
      );
      return;
    }
    
    final data = {
      'letter_format_id': selectedTemplate!.id,
      'tanggal_mulai': tanggalMulai!.toIso8601String().split('T')[0],    
      'tanggal_selesai': tanggalSelesai!.toIso8601String().split('T')[0], 
      // Karena API Service sudah mengambil user_id dari ULM, 
      // kita tidak perlu mengirimkannya di sini.
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

        // Arahkan ke dashboard employee
        context.go('/employee-dashboard'); 
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
    // Mengubah struktur untuk menggunakan Scaffold dengan AppBar
    return Scaffold(
      appBar: AppBar(
        // leading: Builder(
        //   builder: (context) => IconButton(
        //     icon: const Icon(Icons.menu),
        //     onPressed: () => Scaffold.of(context).openDrawer(),
        //   ),
        // ),
        title: const Text(
          "Form Pengajuan Surat",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xff1e6ab3), // Warna yang sama dengan teks di body
          ),
        ),
        backgroundColor: const Color(0xffd3e8ff), // Warna latar belakang AppBar
        elevation: 0, // Hilangkan shadow AppBar
        iconTheme: const IconThemeData(color: Color(0xff1e6ab3)), // Warna ikon menu
      ),
      drawer: const AppDrawer(),
      body: Container(
        // Latar belakang gradasi dipindahkan ke Body Container
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
                  
                  // Hapus: IconButton back dan Judul (sudah ada di AppBar)
                  // const SizedBox(height: 5),
                  // const Text("Form Pengajuan Surat", ... ),
                  
                  const SizedBox(height: 10), // Sedikit jarak dari AppBar

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