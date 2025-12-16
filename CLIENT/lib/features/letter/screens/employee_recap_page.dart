import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hris_3B/widgets/app_drawer.dart';
import 'package:provider/provider.dart';
import '../controllers/employee_recap_controller.dart';
import 'employee_recap_detail_page.dart';

class EmployeeRecapPage extends StatefulWidget {
  const EmployeeRecapPage({super.key});

  @override
  State<EmployeeRecapPage> createState() => _EmployeeRecapPageState();
}

class _EmployeeRecapPageState extends State<EmployeeRecapPage> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ChangeNotifierProvider(
        create: (_) {
          print('🔄 Creating EmployeeRecapController');
          final controller = EmployeeRecapController();
          controller.fetchEmployeeRecap().catchError((error) {
            print('❌ Error in fetchEmployeeRecap: $error');
          });
          return controller;
        },
        child: Consumer<EmployeeRecapController>(
          builder: (context, controller, _) {
            print('🔍 Building with state: loading=${controller.isLoading}, error=${controller.error}');
            
            if (controller.isLoading) {
              return Scaffold(
                appBar: AppBar(
                  // leading: IconButton(
                  //   icon: const Icon(Icons.arrow_back),
                  //   onPressed: () => context.go('/admin-dashboard'),
                  // ),
                  title: const Text('Laporan Rekap Karyawan'),
                ),
                drawer: const AppDrawer(),
                body: const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Memuat data...'),
                    ],
                  ),
                ),
              );
            }
            
            if (controller.error != null) {
              return Scaffold(
                appBar: AppBar(
                  
                  // leading: IconButton(
                  //   icon: const Icon(Icons.arrow_back),
                  //   onPressed: () => context.go('/admin-dashboard'),
                  // ),
                  title: const Text('Laporan Rekap Karyawan'),
                ),
                drawer: const AppDrawer(),
                body: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        const Text(
                          'Terjadi Kesalahan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          controller.error ?? 'Unknown error',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () => controller.fetchEmployeeRecap(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Coba Lagi'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            // Filter hanya karyawan yang memiliki pengajuan surat
            var employeesWithLetters = controller.employees
                .where((emp) => emp.letters != null && emp.letters!.isNotEmpty)
                .toList();

            // Filter berdasarkan search query
            if (searchQuery.isNotEmpty) {
              employeesWithLetters = employeesWithLetters
                  .where((emp) =>
                      emp.name.toLowerCase().contains(searchQuery.toLowerCase()))
                  .toList();
            }

            return Scaffold(
              appBar: AppBar(
                // leading: IconButton(
                //   icon: const Icon(Icons.arrow_back),
                //   onPressed: () => context.go('/admin-dashboard'),
                // ),
                title: const Text('Laporan Rekap Karyawan'),
                
                actions: [
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => controller.fetchEmployeeRecap(),
                  ),
                ],
              ),
              drawer: const AppDrawer(),
              body: Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari nama karyawan...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  searchController.clear();
                                  setState(() => searchQuery = '');
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() => searchQuery = value);
                      },
                    ),
                  ),
                  // List Results
                  Expanded(
                    child: employeesWithLetters.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.inbox, size: 64, color: Colors.grey),
                                const SizedBox(height: 16),
                                Text(
                                  searchQuery.isNotEmpty
                                      ? 'Tidak ada karyawan dengan nama "$searchQuery"'
                                      : 'Belum ada pengajuan surat dari karyawan',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => controller.fetchEmployeeRecap(),
                            child: ListView.builder(
                              itemCount: employeesWithLetters.length,
                              padding: const EdgeInsets.all(8),
                              itemBuilder: (context, index) {
                                final emp = employeesWithLetters[index];
                                return EmployeeListItem(employee: emp);
                              },
                            ),
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class EmployeeListItem extends StatefulWidget {
  final dynamic employee;

  const EmployeeListItem({super.key, required this.employee});

  @override
  State<EmployeeListItem> createState() => _EmployeeListItemState();
}

class _EmployeeListItemState extends State<EmployeeListItem> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.person, color: Colors.blue),
            title: Text(
              widget.employee.name ?? 'Unknown',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Text(
              '${widget.employee.letters?.length ?? 0} pengajuan surat',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: IconButton(
              icon: Icon(
                isExpanded ? Icons.expand_less : Icons.expand_more,
                color: Colors.blue,
              ),
              onPressed: () {
                setState(() => isExpanded = !isExpanded);
              },
            ),
            onTap: () {
              try {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmployeeRecapDetailPage(employee: widget.employee),
                  ),
                );
              } catch (e) {
                print('❌ Error navigating to detail: $e');
              }
            },
          ),
          if (isExpanded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                border: Border(
                  top: BorderSide(color: Colors.blue.shade200),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow('Departemen', widget.employee.departement ?? '-'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Posisi', widget.employee.position ?? '-'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Gender', widget.employee.gender ?? '-'),
                  const SizedBox(height: 8),
                  _buildDetailRow('Bergabung', widget.employee.createdAt ?? '-'),
                  const SizedBox(height: 16),
                  const Text(
                    'Daftar Pengajuan Surat:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...?widget.employee.letters?.map<Widget>((letter) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: _getStatusColor(letter['status']),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    letter['name'] ?? '-',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                letter['status'] ?? 'unknown',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusTextColor(letter['status']),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList() ??
                      [],
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.blue,
            ),
          ),
        ),
        const Text(': '),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green.shade100;
      case 'rejected':
        return Colors.red.shade100;
      case 'pending':
        return Colors.yellow.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green.shade700;
      case 'rejected':
        return Colors.red.shade700;
      case 'pending':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }
}
