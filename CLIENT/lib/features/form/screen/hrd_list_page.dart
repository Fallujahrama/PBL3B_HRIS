import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';
import '../../../routes/app_routes.dart';

class HrdListPage extends StatefulWidget {
  const HrdListPage({super.key});

  @override
  State<HrdListPage> createState() => _HrdListPageState();
}

class _HrdListPageState extends State<HrdListPage> {
  List data = [];
  bool loading = false;

  Future<void> loadData() async {
    setState(() => loading = true);
    
    try {
      data = await ApiService.getSurat();
      print('📋 Loaded ${data.length} letters');
      
      // Debug: Print data structure
      if (data.isNotEmpty) {
        print('Sample data: ${data.first}');
      }
    } catch (e) {
      print('Error loading data: $e');
    }
    
    setState(() => loading = false);
  }

  String formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('dd MMM yyyy').format(date);
    } catch (e) {
      return dateStr;
    }
  }

  // ✅ FIX: Format range tanggal
  String formatDateRange(Map<String, dynamic> surat) {
    final mulai = surat['tanggal_mulai'];
    final selesai = surat['tanggal_selesai'];
    
    // Coba tanggal_mulai & tanggal_selesai dulu
    if (mulai != null && selesai != null) {
      return '${formatDate(mulai)} - ${formatDate(selesai)}';
    }
    
    // Fallback ke tanggal (backward compatibility)
    if (surat['tanggal'] != null) {
      return formatDate(surat['tanggal']);
    }
    
    return '-';
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/letter-home'),
        ),
        title: const Text("Approval HRD"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadData,
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : data.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.inbox, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      const Text('Belum ada pengajuan surat'),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: loadData,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Refresh'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadData,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: data.length,
                    itemBuilder: (context, index) {
                      final s = data[index];
                      final status = s['status'] ?? 'pending';
                      
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: getStatusColor(status).withOpacity(0.2),
                            child: Text(
                              (s['name'] ?? '?').substring(0, 1).toUpperCase(),
                              style: TextStyle(
                                color: getStatusColor(status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            s['name'] ?? 'Nama tidak tersedia',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('Jenis: ${s['letter_format']?['name'] ?? '-'}'),
                              Text('Jabatan: ${s['jabatan'] ?? '-'}'),
                              Text('Departemen: ${s['departemen'] ?? '-'}'),
                              // ✅ FIX: Gunakan formatDateRange
                              Text('Periode: ${formatDateRange(s)}'),
                            ],
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: getStatusColor(status),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () async {
                            await context.push(AppRoutes.detailSurat, extra: s);
                            await loadData();
                          },
                        ),
                      );
                    },
                  ),
                ),
    );
  }
}
