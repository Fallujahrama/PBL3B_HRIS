import 'package:flutter/material.dart';
import 'sidebar_employee.dart';
import '../../../widgets/app_drawer.dart';

void main() {
  runApp(const AdminDashboard());
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Dashboard',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    // Data contoh (kosongkan / bind dengan backend sesuai kebutuhan)
    final String adminName = 'Nama Admin';
    final String adminRole = 'HR Admin';
    final String totalEmployees = '124';
    final String pendingLeaves = '8';
    final String pendingApprovals = '6';
    final String payrollPending = '2';
    final String departmentsCount = '5';
    final String overtimeThisMonth = '14';
    final List<ActivityData> activityList = const [];

    return Scaffold(
      drawer: const AppDrawer(), // tetap pakai sidebar yang ada
      appBar: AppBar(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        title: const Text(
          "Dashboard Admin",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {},
          )
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selamat Datang, Admin!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Ringkasan HR hari ini:',
              style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 18),

            // ADMIN OVERVIEW CARD (menggantikan profile employee)
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: primary.withOpacity(0.06)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 34,
                      backgroundColor: primary,
                      child: const Icon(Icons.admin_panel_settings, size: 36, color: Colors.white),
                    ),
                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            adminName.isEmpty ? '-' : adminName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            adminRole.isEmpty ? '-' : adminRole,
                            style: TextStyle(color: primary.withOpacity(0.75)),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(Icons.circle, size: 12, color: Colors.blueAccent),
                              const SizedBox(width: 6),
                              Text(
                                'Panel Admin',
                                style: const TextStyle(color: Colors.black87),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.chevron_right, color: primary),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ADMIN FEATURE HIGHLIGHTS
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: BlueFeatureCard(
                    primary: primary,
                    icon: Icons.group,
                    title: 'Total Karyawan',
                    lines: [
                      totalEmployees,
                      'Departemen: $departmentsCount',
                    ],
                    actionLabel: 'Kelola',
                    actionOnPressed: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: BlueFeatureCard(
                    primary: primary,
                    icon: Icons.pending_actions,
                    title: 'Pending Approvals',
                    lines: [
                      'Cuti: $pendingLeaves',
                      'Approval: $pendingApprovals',
                    ],
                    actionLabel: 'Tinjau',
                    actionOnPressed: () {},
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // SECOND ROW STATS
            Row(
              children: [
                Expanded(
                  child: StatCard(
                    title: 'Payroll Pending',
                    value: payrollPending,
                    icon: Icons.payments,
                    color: primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    title: 'Lembur Bulan Ini',
                    value: overtimeThisMonth,
                    icon: Icons.access_time,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // RINGKASAN ABSENSI / METRIK
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Icon(Icons.analytics, size: 36, color: primary),
                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Metrik HR Bulanan',
                              style: TextStyle(fontWeight: FontWeight.bold, color: primary)),
                          const SizedBox(height: 8),

                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: const [
                              SummaryPill(label: 'Hadir', value: '—'),
                              SummaryPill(label: 'Telat', value: '—'),
                              SummaryPill(label: 'Cuti', value: '—'),
                              SummaryPill(label: 'Lembur', value: '—'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    TextButton(
                      onPressed: () {},
                      child: Text('Lihat Laporan', style: TextStyle(color: primary)),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // CHART / STATISTICS PLACEHOLDER
            Text(
              'Statistik & Tren',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
            ),
            const SizedBox(height: 8),

            Container(
              height: 160,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: primary.withOpacity(0.06)),
              ),
              child: const Center(
                child: Text('Chart Placeholder (integrasikan chart library seperti fl_chart)', style: TextStyle(color: Colors.grey)),
              ),
            ),

            const SizedBox(height: 16),

            // PENGUMUMAN (ADMIN CAN MANAGE)
            Text(
              'Pengumuman & Broadcast',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
            ),
            const SizedBox(height: 8),

            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  children: [
                    const Text('Tidak ada pengumuman saat ini.', style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.campaign_outlined),
                        label: const Text('Buat Pengumuman'),
                        style: ElevatedButton.styleFrom(backgroundColor: primary),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // QUICK ACTIONS — ADMIN FEATURES
            Text(
              'Menu Admin Cepat',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
            ),
            const SizedBox(height: 10),

            GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 0.95,
              children: [
                QuickActionTile(icon: Icons.people, label: 'Kelola Karyawan', primary: primary, onTap: () {}),
                QuickActionTile(icon: Icons.event, label: 'Kelola Cuti', primary: primary, onTap: () {}),
                QuickActionTile(icon: Icons.access_time, label: 'Kelola Absensi', primary: primary, onTap: () {}),
                QuickActionTile(icon: Icons.payments, label: 'Kelola Payroll', primary: primary, onTap: () {}),
                QuickActionTile(icon: Icons.schedule, label: 'Shift & Jadwal', primary: primary, onTap: () {}),
                QuickActionTile(icon: Icons.check_circle, label: 'Persetujuan', primary: primary, onTap: () {}),
                QuickActionTile(icon: Icons.bar_chart, label: 'Laporan', primary: primary, onTap: () {}),
                QuickActionTile(icon: Icons.campaign, label: 'Pengumuman', primary: primary, onTap: () {}),
                QuickActionTile(icon: Icons.settings, label: 'Pengaturan', primary: primary, onTap: () {}),
              ],
            ),

            const SizedBox(height: 16),

            // AKTIVITAS SISTEM / RIWAYAT
            Text(
              'Riwayat Aktivitas Sistem',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
            ),
            const SizedBox(height: 8),

            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Column(
                children: activityList.isEmpty
                    ? const [ActivityTile(title: 'Belum ada aktivitas', date: '-') ]
                    : activityList
                        .map((a) => ActivityTile(title: a.title, date: a.date))
                        .toList(),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------
// COMPONENTS (Reuse & tweak)
// ---------------------------------------

class BlueFeatureCard extends StatelessWidget {
  final Color primary;
  final IconData icon;
  final String title;
  final List<String> lines;
  final String actionLabel;
  final VoidCallback actionOnPressed;

  const BlueFeatureCard({
    super.key,
    required this.primary,
    required this.icon,
    required this.title,
    required this.lines,
    required this.actionLabel,
    required this.actionOnPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ...lines.map((l) => Text(l, style: const TextStyle(color: Colors.white))).toList(),
                ],
              ),
            ),

            ElevatedButton(
              onPressed: actionOnPressed,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: primary),
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.06)),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Row(
        children: [
          Icon(icon, size: 36, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value.isEmpty ? '-' : value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(title, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: color),
        ],
      ),
    );
  }
}

class SummaryPill extends StatelessWidget {
  final String label;
  final String value;

  const SummaryPill({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: primary.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: TextStyle(color: primary, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          Text(value.isEmpty ? '-' : value, style: const TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
}

class QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color primary;
  final VoidCallback onTap;

  const QuickActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: primary.withOpacity(0.12),
            child: Icon(icon, color: primary, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: primary, fontWeight: FontWeight.w600, fontSize: 13), textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class ActivityTile extends StatelessWidget {
  final String title;
  final String date;

  const ActivityTile({super.key, required this.title, required this.date});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return ListTile(
      leading: Icon(Icons.history, color: primary),
      title: Text(title),
      subtitle: Text(date),
    );
  }
}

class ActivityData {
  final String title;
  final String date;

  const ActivityData({required this.title, required this.date});
}
