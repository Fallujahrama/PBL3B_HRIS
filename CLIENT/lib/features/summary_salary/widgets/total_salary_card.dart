import 'package:flutter/material.dart';
import '../models/summary_salary.dart';

class TotalSalaryCard extends StatelessWidget {
  final SummaryReport summary;
  final String Function(double, {bool includeSymbol}) formatRupiah;

  const TotalSalaryCard({
    super.key,
    required this.summary,
    required this.formatRupiah,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    const textColor = Colors.white;

    final backgroundIcon = Icons.paid; 
    

    return SizedBox(
      width: double.infinity, 
      child: Card(
        elevation: 6,
        color: primaryColor, // FIX: Mengubah warna Card menjadi primary blue
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Stack(
            children: [
              // 1. IKON BESAR DI LATAR BELAKANG (Sudut Kanan Bawah)
              Positioned(
                bottom: -10,
                right: -10,
                child: Icon(
                  backgroundIcon,
                  size: 120,
                  color: textColor.withOpacity(0.1), // FIX: Opacity rendah
                ),
              ),

              // 2. KONTEN UTAMA
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Salary", 
                    style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.7)) // Teks putih buram
                  ),
                  const SizedBox(height: 8),
                  
                  // NILAI TOTAL GAJI UTAMA
                  Text(
                    formatRupiah(summary.totalSalary),
                    style: const TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.bold,
                      color: textColor, // FIX: Teks putih
                    ),
                  ),
                  const SizedBox(height: 16), 

                  // BARIS BAWAH: PERSENTASE PERUBAHAN & EMPLOYEE COUNT
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Employee Count
                      Row(
                        children: [
                          const Icon(Icons.people_alt, size: 18, color: Colors.white70),
                          const SizedBox(width: 4),
                          Text(
                            "${summary.employeeCount} Karyawan", 
                            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}