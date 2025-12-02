import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/position.dart';
import '../services/position_api.dart';

class PositionFormScreen extends StatefulWidget {
  final Position? position; // Jika null = Mode Tambah, Jika ada = Mode Edit

  const PositionFormScreen({super.key, this.position});

  @override
  State<PositionFormScreen> createState() => _PositionFormScreenState();
}

class _PositionFormScreenState extends State<PositionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _rateRegulerController;
  late TextEditingController _rateOvertimeController;

  bool _isLoading = false;

  /// Baru: kontrol apakah form dalam mode read-only.
  /// Jika membuka detail (edit mode), maka awalnya true (hanya lihat).
  /// Jika menambah data (widget.position == null), maka false (langsung edit).
  late bool _readOnly;

  @override
  void initState() {
    super.initState();
    // Inisialisasi controller dengan data jika mode edit
    _nameController = TextEditingController(text: widget.position?.name ?? '');
    _rateRegulerController = TextEditingController(
        text: widget.position?.rateReguler?.toString() ?? '');
    _rateOvertimeController = TextEditingController(
        text: widget.position?.rateOvertime?.toString() ?? '');

    // Inisialisasi readOnly berdasarkan apakah ada position (edit) atau tidak (create)
    _readOnly = widget.position != null;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rateRegulerController.dispose();
    _rateOvertimeController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final data = {
      "name": _nameController.text,
      "rate_reguler": double.tryParse(_rateRegulerController.text) ?? 0,
      "rate_overtime": double.tryParse(_rateOvertimeController.text) ?? 0,
    };

    bool success;
    if (widget.position == null) {
      // Create Mode
      success = await PositionApi.createPosition(data);
    } else {
      // Update Mode
      success = await PositionApi.updatePosition(widget.position!.id, data);
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Data berhasil disimpan!")),
      );
      context.pop(true); // Kembali ke list dan refresh
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal menyimpan data.")),
      );
    }
  }

  Future<void> _deletePosition() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Posisi"),
        content: const Text("Apakah Anda yakin ingin menghapus posisi ini?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Batal")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Hapus", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true && widget.position != null) {
      setState(() => _isLoading = true);
      final success = await PositionApi.deletePosition(widget.position!.id);
      
      if (success && mounted) {
        context.pop(true); // Kembali dan refresh
      } else if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Gagal menghapus data.")),
        );
      }
    }
  }

  // Helper Widget untuk Input Field yang konsisten
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          // validasi hanya berlaku saat form bisa diedit / ketika akan disubmit
          validator: (val) {
            if (_readOnly) return null; // di mode read-only, skip validator
            return val == null || val.isEmpty ? "Wajib diisi" : null;
          },
          // Enabled mengikuti flag readOnly dan loading
          enabled: !_readOnly && !_isLoading,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.position != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8), // Background abu-abu muda
      appBar: AppBar(
        title: Text(isEdit ? "Position Detail" : "Tambah Position"),
        backgroundColor: Colors.blueAccent, // Warna biru header
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header Avatar (Opsional, mempercantik tampilan detail)
              if (isEdit) ...[
                const SizedBox(height: 10),
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage('https://ui-avatars.com/api/?name=Job+Position&background=0D8ABC&color=fff'), 
                ),
                const SizedBox(height: 10),
                Text(
                  widget.position!.name ?? "-",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
              ],

              // Form Fields (enabled mengikuti _readOnly)
              _buildTextField(label: "Nama Posisi", controller: _nameController),
              _buildTextField(label: "Rate Reguler", controller: _rateRegulerController, isNumber: true),
              _buildTextField(label: "Rate Overtime", controller: _rateOvertimeController, isNumber: true),

              const SizedBox(height: 20),

              // Tombol Simpan/Update
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          // Jika mode edit dan saat ini read-only -> ubah mode jadi editable (first press)
                          if (isEdit && _readOnly) {
                            setState(() {
                              _readOnly = false;
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Mode edit aktif. Silakan ubah data lalu tekan Update lagi untuk menyimpan.")),
                            );
                            return;
                          }

                          // Jika sedang create, atau sudah dalam mode edit (editable), submit
                          _submitForm();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      // Tetap pakai label "Update" sesuai permintaan user saat edit; saat create tampil "Simpan"
                      : Text(
                          isEdit ? "Update" : "Simpan",
                          style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                ),
              ),

              // Tombol Hapus (Hanya muncul saat edit)
              if (isEdit) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: _isLoading ? null : _deletePosition,
                    style: TextButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text("Delete", style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}