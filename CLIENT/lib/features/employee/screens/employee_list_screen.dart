import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// PASTIKAN SEMUA MODEL INI SUDAH DI-IMPORT DENGAN PATH YANG TEPAT
import '../models/employee_model.dart'; // Ganti dengan path model Anda
import '../services/employee_api_service.dart'; // Ganti dengan path service Anda
import '../../../widgets/app_drawer.dart'; // Ganti dengan path widget Anda

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({super.key});

  @override
  State<EmployeeListScreen> createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final EmployeeApiService _apiService = EmployeeApiService();
  final ScrollController _scrollController = ScrollController();
  
  List<Employee> _allEmployees = []; 
  List<Department> _allDepartments = [];
  List<Position> _allPositions = [];
  List<Employee> _employees = []; 
  
  bool _isLoading = true;
  String? _error;
  String _searchText = '';
  bool _isFabVisible = true;

  int? _selectedDepartmentId; 
  int? _selectedPositionId;

  // >> STATE UNTUK PENGURUTAN
  String _sortCriteria = 'id';// 'id' atau 'fullName'
  bool _sortDescending = true; // true = Z-A atau Terbaru-Terlama
  String _sortLabel = 'Terbaru ke Terlama (ID)'; // Label default detail

  @override
  void initState() {
    super.initState();
    _loadEmployees();
    _scrollController.addListener(_scrollListener);
  }
  
@override
void dispose() {
  _scrollController.removeListener(_scrollListener); 
  _scrollController.dispose();
  super.dispose();
}

  void _scrollListener() {
    if (_scrollController.offset > 0 && _isFabVisible) {
      setState(() {
        _isFabVisible = false;
      });
    } else if (_scrollController.offset <= 0 && !_isFabVisible) {
      setState(() {
        _isFabVisible = true;
      });
    }
  }

  // -------------------------------------------------------------------------
  // FUNGSI PENGURUTAN
  // -------------------------------------------------------------------------

  void _sortEmployees() {
    setState(() {
      _employees.sort((a, b) {
        int comparison = 0;
        
        if (_sortCriteria == 'fullName') {
          // Urutkan berdasarkan Nama (case-insensitive)
          comparison = a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase());
        } else { // _sortCriteria == 'id'
          // Urutkan berdasarkan ID (mewakili urutan masukan)
          comparison = a.id.compareTo(b.id);
        }

        // Terapkan arah pengurutan
        return _sortDescending ? -comparison : comparison;
      });
    });
  }

  void _applySort(String criteria, bool descending, String label) {
    setState(() {
      _sortCriteria = criteria;
      _sortDescending = descending;
      _sortLabel = label; // Menyimpan label yang dipilih
    });
    // _filterEmployees(_searchText); // Panggil ini jika Anda ingin filter ulang setelah sort
    _sortEmployees();
  }

  void _showSortSheet() {
    final List<Map<String, dynamic>> sortOptions = [
      {'label': 'Nama (A-Z)', 'criteria': 'fullName', 'descending': false},
      {'label': 'Nama (Z-A)', 'criteria': 'fullName', 'descending': true},
      {'label': 'Terlama ke Terbaru', 'criteria': 'id', 'descending': false},
      {'label': 'Terbaru ke Terlama', 'criteria': 'id', 'descending': true},
    ];

    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Urutkan Berdasarkan',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            ...sortOptions.map((option) {
              final isSelected = option['criteria'] == _sortCriteria && option['descending'] == _sortDescending;
              return ListTile(
                leading: isSelected 
                    ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
                    : const Icon(Icons.circle_outlined),
                title: Text(option['label']),
                onTap: () {
                  _applySort(option['criteria'], option['descending'], option['label']);
                  Navigator.pop(ctx);
                },
              );
            }).toList(),
            const SizedBox(height: 16),
          ],
        );
      },
    );
  }

  // -------------------------------------------------------------------------
  // FUNGSI LOAD & FILTER DATA
  // -------------------------------------------------------------------------

  Future<void> _loadEmployees() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final employees = await _apiService.getAllEmployees();
      final departments = await _apiService.fetchDepartments(); 
      final positions = await _apiService.fetchPositions(); 

      setState(() {
        _allEmployees = employees;
        _allDepartments = departments; 
        _allPositions = positions;
        _isLoading = false;
        
        _filterEmployees(_searchText);
        _sortEmployees(); 
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _filterEmployees(String searchText) {
    final searchLower = searchText.toLowerCase();
    setState(() {
      _searchText = searchText;
      
      Iterable<Employee> filtered = _allEmployees;

      // 1. Terapkan filter teks
      if (searchLower.isNotEmpty) {
          filtered = filtered.where((employee) {
            final fullName = employee.fullName.toLowerCase();
            final positionName = employee.position?.name.toLowerCase() ?? '';
            final departmentName = employee.department?.name.toLowerCase() ?? '';

            return fullName.contains(searchLower) ||
                positionName.contains(searchLower) ||
                departmentName.contains(searchLower);
          });
      }
      
      // 2. Terapkan filter departemen
      if (_selectedDepartmentId != null) {
        filtered = filtered.where((employee) => employee.department?.id == _selectedDepartmentId);
      }
      
      // 3. Terapkan filter posisi
      if (_selectedPositionId != null) {
        filtered = filtered.where((employee) => employee.position?.id == _selectedPositionId);
      }

      _employees = filtered.toList();
      _sortEmployees(); // Panggil pengurutan setelah pemfilteran selesai
    });
  }

  // -------------------------------------------------------------------------
  // FUNGSI UTILITY (Filter Sheet & Chip)
  // -------------------------------------------------------------------------

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onPressed,
    VoidCallback? onDeleted,
  }) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: InputChip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        onPressed: onPressed,
        backgroundColor: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.15) : Colors.grey.shade200,
        labelStyle: TextStyle(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        side: BorderSide(
          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
          width: 1,
        ),
        deleteIcon: isSelected ? const Icon(Icons.cancel, size: 18) : null,
        onDeleted: onDeleted,
      ),
    );
  }

  Future<int?> _showFilterSheet<T>({
    required String title,
    required List<T> items,
    required int? selectedId,
    required int Function(T item) getId,
    required String Function(T item) getName,
  }) async {
    return await showModalBottomSheet<int?>(
      context: context,
      isScrollControlled: true, 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
      ),
      builder: (ctx) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5, 
          minChildSize: 0.3,
          maxChildSize: 0.9,
          expand: false,
          builder: (BuildContext context, ScrollController scrollController) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: items.length, 
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final itemId = getId(item);
                      final itemName = getName(item);
                      final isSelected = itemId == selectedId;

                      return ListTile(
                        leading: Icon(
                          isSelected ? Icons.check_circle : Icons.circle_outlined,
                          color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
                        ),
                        title: Text(itemName),
                        onTap: () => Navigator.pop(context, itemId),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _selectDepartment() async {
    final selectedId = await _showFilterSheet<Department>(
      title: "Filter Berdasarkan Departemen",
      items: _allDepartments,
      selectedId: _selectedDepartmentId,
      getId: (d) => d.id,
      getName: (d) => d.name,
    );

    if (selectedId != _selectedDepartmentId) {
      setState(() {
        _selectedDepartmentId = selectedId;
      });
      _filterEmployees(_searchText);
    }
  }

  void _selectPosition() async {
    final selectedId = await _showFilterSheet<Position>(
      title: "Filter Berdasarkan Posisi",
      items: _allPositions,
      selectedId: _selectedPositionId,
      getId: (p) => p.id,
      getName: (p) => p.name,
    );

    if (selectedId != _selectedPositionId) {
      setState(() {
        _selectedPositionId = selectedId;
      });
      _filterEmployees(_searchText);
    }
  }

  // -------------------------------------------------------------------------
  // FUNGSI HAPUS
  // -------------------------------------------------------------------------

  Future<bool> _confirmDelete(Employee employee) async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hapus Karyawan"),
        content: Text(
          "Apakah Anda yakin ingin menghapus ${employee.fullName}? Aksi ini tidak dapat dibatalkan.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text("Hapus"),
          ),
        ],
      ),
    ) ?? false;
  }

  Future<void> _deleteEmployee(int id) async {
    try {
      await _apiService.deleteEmployee(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Karyawan berhasil dihapus')),
        );
        _loadEmployees();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus karyawan: $e')),
        );
        _loadEmployees(); 
      }
    }
  }

  // -------------------------------------------------------------------------
  // WIDGET UTAMA
  // -------------------------------------------------------------------------

  Widget _buildBody() {
    // Kriteria default sort: id descending
    final isDefaultSort = _sortCriteria == 'id' && _sortDescending == true;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
        return Center(
         child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadEmployees,
              child: const Text('Retry'),
            ),
          ],
         ),
       );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- Search Bar ---
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            onChanged: _filterEmployees,
            decoration: InputDecoration(
              hintText: "Cari",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.grey),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            ),
          ),
        ),
        // ------------------

        // >> ROW FILTER DAN SORT
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: SingleChildScrollView( 
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // >> CHIP SORT (InputChip untuk support onDeleted)
                InputChip(
                  avatar: Icon(
                    Icons.sort, 
                    size: 18, 
                    color: isDefaultSort ? Colors.black87 : Theme.of(context).colorScheme.primary
                  ), 
                  // >>> PERUBAHAN DI SINI <<<
                  // Label akan menjadi 'Urutkan' jika default, atau label spesifik jika non-default
                  label: Text(isDefaultSort ? 'Urutkan' : _sortLabel), 
                  onPressed: _showSortSheet, 
                  
                  // Logika Delete (Reset ke default)
                  deleteIcon: isDefaultSort
                    ? null 
                    : const Icon(Icons.cancel, size: 18),
                  onDeleted: isDefaultSort
                    ? null
                    : () {
                        // Reset ke ID descending (default)
                        // Ketika ini dipanggil, isDefaultSort akan menjadi true, 
                        // dan label akan kembali menjadi 'Urutkan'
                        _applySort('id', true, 'Terbaru ke Terlama (ID)'); 
                      },
                  
                  // Styling untuk highlight jika tidak default
                  backgroundColor: isDefaultSort 
                    ? Colors.grey.shade200 
                    : Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  labelStyle: TextStyle(
                    color: isDefaultSort 
                      ? Colors.black87 
                      : Theme.of(context).colorScheme.primary, 
                    fontWeight: isDefaultSort 
                      ? FontWeight.normal 
                      : FontWeight.bold,
                  ),
                  side: BorderSide(
                    color: isDefaultSort 
                      ? Colors.grey.shade400 
                      : Theme.of(context).colorScheme.primary, 
                    width: 1,
                  ),
                ),
                const SizedBox(width: 8),

                // Button Filter Departemen
                _buildFilterChip(
                  label: _selectedDepartmentId == null 
                      ? "Departemen" 
                      : _allDepartments.firstWhere((d) => d.id == _selectedDepartmentId).name,
                  icon: Icons.business,
                  isSelected: _selectedDepartmentId != null,
                  onPressed: _selectDepartment,
                  onDeleted: _selectedDepartmentId != null ? () {
                    setState(() { _selectedDepartmentId = null; });
                    _filterEmployees(_searchText);
                  } : null,
                ),

                // Button Filter Posisi
                _buildFilterChip(
                  label: _selectedPositionId == null 
                      ? "Posisi" 
                      : _allPositions.firstWhere((p) => p.id == _selectedPositionId).name,
                  icon: Icons.work,
                  isSelected: _selectedPositionId != null,
                  onPressed: _selectPosition,
                  onDeleted: _selectedPositionId != null ? () {
                    setState(() { _selectedPositionId = null; });
                    _filterEmployees(_searchText);
                  } : null,
                ),
              ],
            ),
          ),
        ),
        // ----------------------
        
        Expanded(
          child: _employees.isEmpty && (_searchText.isNotEmpty || _selectedDepartmentId != null || _selectedPositionId != null) 
          ? const Center(child: Text('Tidak ada karyawan yang cocok dengan filter atau pencarian'))
          : _employees.isEmpty
              ? const Center(child: Text('Tidak ada karyawan yang ditemukan'))
              : RefreshIndicator(
            onRefresh: _loadEmployees,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: _employees.length,
              itemBuilder: (context, index) {
                final employee = _employees[index];
                
                return Dismissible(
                  key: ValueKey(employee.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  confirmDismiss: (direction) async {
                    return await _confirmDelete(employee);
                  },
                  onDismissed: (direction) {
                    _deleteEmployee(employee.id);
                  },
                  child: Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade100,
                        child: Text(
                          employee.firstName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(
                        employee.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(employee.position?.name ?? 'No Position'),
                          Text(employee.department?.name ?? 'No Department', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/employee/detail/${employee.id}').then((_) => _loadEmployees()),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Master Karyawan', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: const AppDrawer(),
      body: _buildBody(),
      
      resizeToAvoidBottomInset: false, 

      floatingActionButton: AnimatedOpacity(
        opacity: _isFabVisible ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: FloatingActionButton(
          onPressed: () => context.push('/employee/add').then((_) => _loadEmployees()),
          child: const Icon(Icons.add, color: Colors.white), 
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}