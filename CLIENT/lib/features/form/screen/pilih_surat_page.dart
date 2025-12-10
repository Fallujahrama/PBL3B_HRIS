import 'package:flutter/material.dart';

class FormSuratPage extends StatefulWidget {
  const FormSuratPage({super.key});

  @override
  State<FormSuratPage> createState() => _FormSuratPageState();
}

class _FormSuratPageState extends State<FormSuratPage> {
  final TextEditingController namaController = TextEditingController();
  final TextEditingController tanggalController = TextEditingController();

  String? selectedSurat;

  final List<String> jenisSurat = [
    "Surat Izin",
    "Surat Sakit",
    "Surat Tugas",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          "Form Pengajuan Surat",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // ===== CARD CONTAINER =====
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // ========== INPUT NAMA ==========
                    const Text(
                      "Nama Karyawan",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: namaController,
                      decoration: InputDecoration(
                        hintText: "Masukkan nama lengkap...",
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ========== PILIH JENIS SURAT ==========
                    const Text(
                      "Jenis Surat",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedSurat,
                          hint: const Text("Pilih jenis surat"),
                          items: jenisSurat.map((surat) {
                            return DropdownMenuItem(
                              value: surat,
                              child: Text(surat),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedSurat = value;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ========== TANGGAL PENGAJUAN ==========
                    const Text(
                      "Tanggal Pengajuan",
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: tanggalController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: "Pilih tanggal...",
                        filled: true,
                        fillColor: Colors.grey[100],
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onTap: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                          initialDate: DateTime.now(),
                        );

                        if (pickedDate != null) {
                          tanggalController.text =
                              "${pickedDate.day}-${pickedDate.month}-${pickedDate.year}";
                        }
                      },
                    ),

                    const SizedBox(height: 30),

                    // ========== TOMBOL SUBMIT ==========
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () {
                          if (namaController.text.isEmpty ||
                              selectedSurat == null ||
                              tanggalController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Semua field wajib diisi!"),
                              ),
                            );
                            return;
                          }

                          // === Aksi Submit ===
                          print("Nama: ${namaController.text}");
                          print("Jenis Surat: $selectedSurat");
                          print("Tanggal: ${tanggalController.text}");
                        },
                        child: const Text(
                          "Ajukan Surat",
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
