import 'package:flutter/material.dart';
import '../screens/schedule_add_page.dart';
import '../widgets/schedule_calender_widget.dart';
import 'package:intl/date_symbol_data_local.dart';
import '../services/schedule_service.dart';
import '../../../theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  List<dynamic> schedules = [];
  bool isLoading = true;
  String? errorMessage;

  DateTime _focusedDay = DateTime.now();
  int _currentMonth = DateTime.now().month;
  int _currentYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    // Initialize locale data for TableCalendar header formatting
    initializeDateFormatting('id_ID', null).then((_) {
      if (mounted) setState(() {});
    });
    loadAll();
  }

  Future<void> loadAll() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    try {
      final data = await ScheduleService.fetchHolidays(year: _currentYear);
      final normalized = data.map((h) {
        final parsed = DateTime.tryParse(h['date'] ?? '');
        return {
          ...h,
          'parsedDate': parsed != null
              ? DateTime(parsed.year, parsed.month, parsed.day)
              : null,
        };
      }).toList();
      if (mounted) {
        setState(() {
          schedules = normalized;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = e.toString();
          isLoading = false;
        });
      }
    }
  }

  Future<void> _syncNationalHolidays() async {
    try {
      await ScheduleService.syncNationalHolidays(_currentYear);
      await loadAll();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sinkronisasi selesai'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sinkronisasi gagal: $e')));
      }
    }
  }

  void _onCalendarPageChanged(DateTime focused) {
    setState(() {
      _focusedDay = focused;
      _currentMonth = focused.month;
      _currentYear = focused.year;
    });
    loadAll();
  }

  void _onMonthYearChanged(int month, int year) {
    setState(() {
      _currentMonth = month;
      _currentYear = year;
      _focusedDay = DateTime(year, month, 1);
    });
    loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hari Libur Nasional'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            onPressed: _syncNationalHolidays,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text('Error: $errorMessage'))
          : RefreshIndicator(
              onRefresh: loadAll,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    ScheduleCalendar(
                      focusedDay: _focusedDay,
                      currentMonth: _currentMonth,
                      currentYear: _currentYear,
                      events: schedules,
                      onPageChanged: _onCalendarPageChanged,
                      onMonthYearChanged: _onMonthYearChanged,
                    ),
                    _buildScheduleList(),
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const ScheduleAddPage()),
          );
          if (result == true) loadAll();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildScheduleList() {
    final filtered =
        schedules.where((s) {
          final date = s['parsedDate'] as DateTime?;
          return date != null &&
              date.month == _currentMonth &&
              date.year == _currentYear;
        }).toList()..sort((a, b) {
          final ad = a['parsedDate'] as DateTime;
          final bd = b['parsedDate'] as DateTime;
          return ad.compareTo(bd);
        });

    return Container(
      padding: const EdgeInsets.all(16),
      child: filtered.isEmpty
          ? const Text(
              'Tidak ada hari libur di bulan ini',
              style: TextStyle(fontSize: 14),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: filtered.map((h) {
                final date = h['parsedDate'] as DateTime?;
                return ListTile(
                  leading: const Icon(Icons.flag, color: Colors.red),
                  title: Text(h['name'] ?? '-'),
                  subtitle: Text(
                    date != null
                        ? '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}'
                        : (h['date'] ?? '-'),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      await ScheduleService.deleteHoliday(h['id']);
                      loadAll();
                    },
                  ),
                );
              }).toList(),
            ),
    );
  }
}
