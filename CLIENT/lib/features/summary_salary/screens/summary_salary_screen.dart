import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/summary_salary_api.dart';
import '../models/summary_salary.dart';
import '../widgets/bar_chart_widget.dart';
import '../widgets/summary_kpi_card.dart';
import '../widgets/total_salary_card.dart';
import '../../../../widgets/app_drawer.dart';

class SummarySalaryScreen extends StatefulWidget {
  const SummarySalaryScreen({super.key});

  @override
  State<SummarySalaryScreen> createState() => _SummarySalaryScreenState();
}

class _SummarySalaryScreenState extends State<SummarySalaryScreen> {
  late Future<SalaryReportCombined> futureCombinedData;

  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  dynamic selectedDepartmentId = 'all';

  List<Department> departmentOptions = [];

  @override
  void initState() {
    super.initState();
    departmentOptions = [Department(id: 'all', name: 'Loading Departments...')];
    _fetchCombinedData();
  }

  void _fetchCombinedData() {
    setState(() {
      futureCombinedData =
          SummarySalaryApi.fetchCombinedData(
                month: selectedMonth,
                year: selectedYear,
                department: selectedDepartmentId,
              )
              .then((combined) {
                if (combined.departments.isNotEmpty) {
                  departmentOptions = combined.departments;

                  if (!departmentOptions.any((d) => d.id == 'all')) {
                    departmentOptions.insert(
                      0,
                      Department(id: 'all', name: 'All Departments'),
                    );
                  }
                }
                return combined;
              })
              .catchError((error) {
                print("Error fetching data: $error");
                throw error;
              });
    });
  }

  String _formatRupiah(double number, {bool includeSymbol = true}) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: includeSymbol ? 'Rp' : '',
      decimalDigits: 0,
    );
    return formatter.format(number).trim();
  }

  // ======================================================
  // BUILD UI
  // ======================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text("Laporan Gaji Karyawan"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      drawer: const AppDrawer(),
      body: FutureBuilder<SalaryReportCombined>(
        future: futureCombinedData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                textAlign: TextAlign.center,
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("No report data available."));
          }

          final report = snapshot.data!.report;
          final summary = report.summary;
          final history = snapshot.data!.history;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterBar(),
                const SizedBox(height: 16),

                // SUMMARY BOX
                IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        flex: 5,
                        child: TotalSalaryCard(
                          summary: summary,
                          // history: history,
                          formatRupiah: _formatRupiah,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 4,
                        child: Column(
                          children: [
                            SummaryKpiCard(
                              title: "Total Jam Regular",
                              value:
                                  "${summary.totalHours.toStringAsFixed(0)} Jam",
                              icon: Icons.timer_outlined,
                              color: Colors.blueGrey,
                            ),
                            const SizedBox(height: 16),
                            SummaryKpiCard(
                              title: "Total Jam Lembur",
                              value:
                                  "${summary.totalOvertime.toStringAsFixed(0)} Jam",
                              icon: Icons.access_time_filled,
                              color: Colors.deepOrange,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // SALARY CHART
                _buildChartSection(
                  title: "Gaji per Departemen",
                  data: report.salaryByDepartment,
                  type: 'salary',
                ),

                const SizedBox(height: 20),

                // OVERTIME CHART
                _buildChartSection(
                  title: "Jam Lembur per Departemen",
                  data: report.overtimeByDepartment,
                  type: 'overtime',
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ======================================================
  // FILTER BAR
  // ======================================================
  Widget _buildFilterBar() {
    String getDepartmentName() {
      return departmentOptions
          .firstWhere(
            (dept) => dept.id == selectedDepartmentId,
            orElse: () => Department(id: 'all', name: 'All Departments'),
          )
          .name;
    }

    return Row(
      children: [
        Expanded(
          child: _buildFilterButton(
            title: DateFormat.MMMM().format(DateTime(0, selectedMonth)),
            onTap: _showMonthPicker,
            isPrimary: true,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFilterButton(
            title: selectedYear.toString(),
            onTap: _showYearPicker,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildFilterButton(
            title: getDepartmentName(),
            onTap: _showDepartmentDialog,
          ),
        ),
      ],
    );
  }

  Widget _buildFilterButton({
    required String title,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    final color = isPrimary
        ? Theme.of(context).colorScheme.primary
        : Colors.black87;
    final bgColor = isPrimary
        ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
        : Colors.grey.shade100;

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color,
                  fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
                  fontSize: 13,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down, size: 18, color: color),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // DEPARTMENT PICKER
  // ======================================================
  void _showDepartmentDialog() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                "Select Department",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView(
                children: departmentOptions.map((dept) {
                  return ListTile(
                    title: Text(dept.name),
                    trailing: dept.id == selectedDepartmentId
                        ? Icon(
                            Icons.check,
                            color: Theme.of(context).colorScheme.primary,
                          )
                        : null,
                    onTap: () {
                      setState(() {
                        selectedDepartmentId = dept.id;
                        _fetchCombinedData();
                      });
                      Navigator.pop(context);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  // ======================================================
  // MONTH PICKER
  // ======================================================
  void _showMonthPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          height: 350,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Select Month',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: GridView.builder(
                  itemCount: 12,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                  ),
                  itemBuilder: (_, index) {
                    final month = index + 1;
                    final isSelected = selectedMonth == month;

                    return ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedMonth = month;
                          _fetchCombinedData();
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade200,
                        foregroundColor: isSelected
                            ? Colors.white
                            : Colors.black87,
                      ),
                      child: Text(DateFormat.MMM().format(DateTime(0, month))),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ======================================================
  // YEAR PICKER
  // ======================================================
  void _showYearPicker() {
    int currentYear = DateTime.now().year;
    List<int> years = List.generate(5, (i) => currentYear - i);

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          height: 350,
          padding: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  'Select Year',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 10),

              Expanded(
                child: ListView(
                  children: years.map((year) {
                    return ListTile(
                      title: Text(year.toString()),
                      trailing: selectedYear == year
                          ? Icon(
                              Icons.check,
                              color: Theme.of(context).colorScheme.primary,
                            )
                          : null,
                      onTap: () {
                        setState(() {
                          selectedYear = year;
                          _fetchCombinedData();
                        });
                        Navigator.pop(context);
                      },
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ======================================================
  // CHART SECTION
  // ======================================================
  Widget _buildChartSection({
    required String title,
    required List<DepartmentChartData> data,
    required String type,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        // Hapus Container styling lama, dan biarkan BarChartWidget yang mengambil alih ruang
        Container(
          height: 250,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                blurRadius: 6,
                offset: const Offset(0, 3),
                color: Colors.grey.withOpacity(0.2),
              ),
            ],
          ),
          // BarChartWidget yang sudah difix akan menangani padding internal
          child: BarChartWidget(data: data, type: type),
        ),
      ],
    );
  }
}
