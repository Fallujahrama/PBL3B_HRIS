
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
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
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
            filled: true,
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            fillColor: _readOnly ? Colors.grey.shade100 : Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
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
    final isEditMode = widget.position != null;

    final title = isEditMode
        ? (_readOnly ? "Position Detail" : "Edit Position")
        : "Tambah Position";
    final primaryButtonLabel = isEditMode
        ? (_readOnly ? "Ubah Data" : "Simpan Perubahan")
        : "Simpan";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          if (isEditMode && !_readOnly)
            TextButton(
              onPressed: () {
                _setControllersInitialText();
                _nameController.text = widget.position?.name ?? '';
                setState(() => _readOnly = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Pengeditan dibatalkan.")),
                );
              },
              child: const Text("Batal", style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              if (isEditMode) ...[
                const SizedBox(height: 10),
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(
                    'https://ui-avatars.com/api/?name=${Uri.encodeComponent(widget.position!.name ?? "Posisi")}&background=0D8ABC&color=fff',
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.position!.name ?? "-",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
              ],

              
              
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

              const SizedBox(height: 20),

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

              if (isEditMode) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: TextButton(
                    onPressed: _isLoading || !_readOnly
                        ? null
                        : _deletePosition,
                    style: TextButton.styleFrom(
                      
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(
                        context,
                      ).colorScheme.onError, 
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      "Delete",
                      style: TextStyle(
                        fontSize: 16,
                        
                        
                        fontWeight: FontWeight.bold,
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
