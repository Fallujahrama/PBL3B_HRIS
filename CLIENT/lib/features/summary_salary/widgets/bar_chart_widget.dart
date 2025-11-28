import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/summary_salary.dart';

class BarChartWidget extends StatelessWidget {
  final List<DepartmentChartData> data;
  final String type; // 'salary' atau 'overtime'

  const BarChartWidget({super.key, required this.data, required this.type});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const Center(child: Text("No chart data available."));
    }

    final isSalaryChart = type == 'salary';

    // 1. Tentukan Max Value dan Amankan dari Nol (FIX KRITIS)
    final maxValue = data.map((e) => e.totalValue).fold(0.0, (a, b) => a > b ? a : b);

    final maxY = (maxValue > 0) ? maxValue * 1.2 : 10.0;
    final intervalValue = maxY / 4;
    final safeInterval = (intervalValue > 0) ? intervalValue : 2.5;

    // 2. Siapkan Bar Groups
    final barGroups = List.generate(data.length, (index) {
      final item = data[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.totalValue,
            color: isSalaryChart ? Theme.of(context).colorScheme.primary : Colors.teal.shade400,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });

    // 3. Bar Chart Data
    final BarChartData barChartData = BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: maxY,
      barGroups: barGroups,
      gridData: const FlGridData(show: false),

      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),

        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final deptName = data[value.toInt()].department.split(' ')[0];
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  deptName,
                  style: const TextStyle(fontSize: 10, color: Colors.black54),
                ),
              );
            },
            reservedSize: 30,
          ),
        ),

        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 40,
            interval: safeInterval,
            getTitlesWidget: (value, meta) {
              final formatted = isSalaryChart
                  ? 'Rp${(value / 1000000).toStringAsFixed(0)}M'
                  : value.toStringAsFixed(0);

              return Text(
                formatted,
                style: const TextStyle(fontSize: 10, color: Colors.black54),
              );
            },
          ),
        ),
      ),

      borderData: FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Colors.black12, width: 1),
          left: BorderSide(color: Colors.transparent),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      ),

      barTouchData: _getTouchData(isSalaryChart),
    );

    return Padding(
      padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 12.0),
      child: BarChart(barChartData),
    );
  }

  // --- Helper Methods ---

  List<BarChartGroupData> _getBarGroups(BuildContext context, bool isSalary) {
    return List.generate(data.length, (index) {
      final item = data[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: item.totalValue,
            color: isSalary
                ? Theme.of(context).colorScheme.primary
                : Colors.teal.shade400,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  BarTouchData _getTouchData(bool isSalary) {
    return BarTouchData(
      touchTooltipData: BarTouchTooltipData(
        getTooltipItem: (group, groupIndex, rod, rodIndex) {
          final deptName = data[groupIndex].department;
          final value = rod.toY.toStringAsFixed(isSalary ? 0 : 1);
          final unit = isSalary ? 'Rp' : 'Jam';

          return BarTooltipItem(
            '$deptName\n',
            const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            children: <TextSpan>[
              TextSpan(
                text: '$unit $value',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          );
        },
      ),
    );
  }
}
