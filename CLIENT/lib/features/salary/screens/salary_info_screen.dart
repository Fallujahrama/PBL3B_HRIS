import 'package:flutter/material.dart';

class SalaryInfoScreen extends StatelessWidget {
  final String userId;

  const SalaryInfoScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Gaji"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Informasi Gaji",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            Table(
              border: TableBorder.all(),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
              },
              children: const [
                TableRow(children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("Gaji Pokok"),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("Rp 4.000.000"),
                  ),
                ]),
                TableRow(children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("Tunjangan"),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("Rp 500.000"),
                  ),
                ]),
                TableRow(children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("Bonus"),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text("Rp 300.000"),
                  ),
                ]),
                TableRow(children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Total",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      "Rp 4.800.000",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ]),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
