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
        color: primaryColor, 
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Stack(
            children: [
              
              Positioned(
                bottom: -10,
                right: -10,
                child: Icon(
                  backgroundIcon,
                  size: 120,
                  color: textColor.withOpacity(0.1), 
                ),
              ),

              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Total Gaji", 
                    style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.7)) 
                  ),
                  const SizedBox(height: 8),
                  
                  
                  Text(
                    formatRupiah(summary.totalSalary),
                    style: const TextStyle(
                      fontSize: 32, 
                      fontWeight: FontWeight.bold,
                      color: textColor, 
                    ),
                  ),
                  const SizedBox(height: 16), 

                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      
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