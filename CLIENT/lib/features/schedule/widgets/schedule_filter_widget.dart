import 'package:flutter/material.dart';

class HolidayFilterWidget extends StatefulWidget {
  final void Function(int month, int year) onFilterChanged;
  final int initialMonth;
  final int initialYear;

  const HolidayFilterWidget({
    super.key,
    required this.onFilterChanged,
    required this.initialMonth,
    required this.initialYear,
  });

  @override
  State<HolidayFilterWidget> createState() => _HolidayFilterWidgetState();
}

class _HolidayFilterWidgetState extends State<HolidayFilterWidget> {
  late int _selectedMonth;
  late int _selectedYear;

  @override
  void initState() {
    super.initState();
    _selectedMonth = widget.initialMonth;
    _selectedYear = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Dropdown bulan
        DropdownButton<int>(
          value: _selectedMonth,
          items: List.generate(12, (i) {
            final m = i + 1;
            return DropdownMenuItem(value: m, child: Text('Bulan $m'));
          }),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedMonth = val);
              widget.onFilterChanged(_selectedMonth, _selectedYear);
            }
          },
        ),
        const SizedBox(width: 16),
        // Dropdown tahun
        DropdownButton<int>(
          value: _selectedYear,
          items: List.generate(10, (i) {
            final y = DateTime.now().year - 5 + i;
            return DropdownMenuItem(value: y, child: Text('$y'));
          }),
          onChanged: (val) {
            if (val != null) {
              setState(() => _selectedYear = val);
              widget.onFilterChanged(_selectedMonth, _selectedYear);
            }
          },
        ),
      ],
    );
  }
}
