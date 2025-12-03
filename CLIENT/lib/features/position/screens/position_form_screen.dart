import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter/services.dart';
import '../models/position.dart';
import '../services/position_api.dart';

class PositionFormScreen extends StatefulWidget {
  final Position? position;

  const PositionFormScreen({super.key, this.position});

  @override
  State<PositionFormScreen> createState() => _PositionFormScreenState();
}

class _PositionFormScreenState extends State<PositionFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _rateRegulerController;
  late TextEditingController _rateOvertimeController;

  bool _isLoading = false;
  late bool _readOnly;

  double? _rateRegulerValue;
  double? _rateOvertimeValue;

  final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  final FocusNode _firstFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    _readOnly = widget.position != null;

    _rateRegulerValue = widget.position?.rateReguler?.toDouble();
    _rateOvertimeValue = widget.position?.rateOvertime?.toDouble();

    _nameController = TextEditingController(text: widget.position?.name ?? '');
    _rateRegulerController = TextEditingController();
    _rateOvertimeController = TextEditingController();

    _setControllersInitialText();
  }

  void _setControllersInitialText() {
    _rateRegulerController.text = _rateRegulerValue != null
        ? _currencyFormat.format(_rateRegulerValue)
        : '';
    _rateOvertimeController.text = _rateOvertimeValue != null
        ? _currencyFormat.format(_rateOvertimeValue)
        : '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _rateRegulerController.dispose();
    _rateOvertimeController.dispose();
    _firstFocus.dispose();
    super.dispose();
  }

  String _unformatNumber(String s) {
    return s.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<void> _submitForm() async {
    if (_readOnly) return;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final regulerRaw = _unformatNumber(_rateRegulerController.text);
    final overtimeRaw = _unformatNumber(_rateOvertimeController.text);

    final data = {
      "name": _nameController.text,
      "rate_reguler": double.tryParse(regulerRaw) ?? 0,
      "rate_overtime": double.tryParse(overtimeRaw) ?? 0,
    };

    bool success;
    try {
      if (widget.position == null) {
        success = await PositionApi.createPosition(data);
      } else {
        success = await PositionApi.updatePosition(widget.position!.id, data);
      }
    } catch (e) {
      success = false;
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Data berhasil disimpan!")));
      // Mengirimkan true kembali agar halaman list me-refresh data
      context.pop(true); 
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Gagal menyimpan data.")));
    }
  }

  Future<void> _deletePosition() async {
    if (widget.position == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Posisi"),
        content: Text(
          "Apakah Anda yakin ingin menghapus posisi ${widget.position!.name}?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final success = await PositionApi.deletePosition(widget.position!.id);

      setState(() => _isLoading = false);
      if (success && mounted) {
        context.pop(true);
      } else if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("Gagal menghapus data.")));
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool isNumber = false,
    FocusNode? focusNode,
  }) {
    final List<TextInputFormatter>? inputFormatters = isNumber
        ? <TextInputFormatter>[
            MoneyInputFormatter(
              leadingSymbol: 'Rp ',
              useSymbolPadding: true,
              thousandSeparator: ThousandSeparator.Period,
              mantissaLength: 0,
            ),
          ]
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          // Menggunakan style yang lebih tebal untuk label di atas field (seperti form pegawai)
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          readOnly: _readOnly,
          inputFormatters: inputFormatters,
          validator: _readOnly
              ? null
              : (val) {
                  if (val == null || val.isEmpty) return "Wajib diisi";
                  if (isNumber && _unformatNumber(val).isEmpty)
                    return "Wajib diisi";
                  return null;
                },
          decoration: InputDecoration(
            // Menghapus filled: true, karena form pegawai tidak menggunakan filled.
            // Mengubah border menjadi OutlineInputBorder standar (seperti form pegawai)
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
            // Mengatur padding yang sama dengan form pegawai
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            // Menambahkan prefixIcon agar field terlihat seragam dengan form pegawai
            prefixIcon: isNumber
                ? const Icon(Icons.money, size: 20)
                : const Icon(Icons.badge, size: 20),
            // Menggunakan warna background jika readOnly
            fillColor: _readOnly ? Colors.grey.shade100 : Colors.white,
            filled: _readOnly, // Hanya filled jika readOnly
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditMode = widget.position != null;

    final title = isEditMode
        ? (_readOnly ? "Detail Posisi" : "Edit Posisi")
        : "Tambah Posisi";
    final primaryButtonLabel = isEditMode
        ? (_readOnly ? "Ubah Data" : "Simpan Perubahan")
        : "Simpan";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.black), // Warna teks hitam
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.black), // Ikon panah kembali
        elevation: 1, // Memberi sedikit elevasi pada AppBar
        actions: [
          if (isEditMode && !_readOnly)
            // Tombol batal di AppBar untuk mode edit
            TextButton(
              onPressed: () {
                _setControllersInitialText();
                _nameController.text = widget.position?.name ?? '';
                setState(() => _readOnly = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Pengeditan dibatalkan.")),
                );
              },
              child: Text(
                "Batal",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary, // Menggunakan warna primary
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        // Padding disamakan dengan form pegawai
        padding: const EdgeInsets.all(16), 
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // CARD: INFORMASI POSISI (Seperti Card di Form Pegawai)
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
                      // Header Card
                      // const Text(
                      //   'Informasi Posisi',
                      //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      // ),
                      const SizedBox(height: 16),
                      
                      // Bidang Input
                      _buildTextField(
                        label: "Nama Posisi",
                        controller: _nameController,
                        focusNode: _firstFocus,
                      ),
                      _buildTextField(
                        label: "Rate Reguler",
                        controller: _rateRegulerController,
                        isNumber: true,
                      ),
                      _buildTextField(
                        label: "Rate Overtime",
                        controller: _rateOvertimeController,
                        isNumber: true,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Tombol Utama (Ubah Data / Simpan Perubahan / Simpan)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (isEditMode && _readOnly) {
                            setState(() => _readOnly = false);
                            Future.delayed(
                              const Duration(milliseconds: 100),
                              () => _firstFocus.requestFocus(),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Mode edit aktif. Silakan ubah data.",
                                ),
                              ),
                            );
                            return;
                          }
                          _submitForm();
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(
                          primaryButtonLabel,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              // Tombol Hapus (Hanya di mode edit)
              if (isEditMode) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton( // Mengubah TextButton menjadi ElevatedButton agar style-nya lebih konsisten dengan Save/Edit Button
                    onPressed: _isLoading || !_readOnly
                        ? null
                        : _deletePosition,
                    style: ElevatedButton.styleFrom(
                      // Menggunakan warna error sebagai background (merah)
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onError,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Hapus", // Menggunakan "Hapus" (Indonesia)
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white, // Teks putih di atas background merah
                      ),
                    ),
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