import 'package:flutter/material.dart';

class SummaryKpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color; 

  const SummaryKpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    const textColor = Colors.white;

    return SizedBox(
      width: double.infinity, 
      child: Card(
        elevation: 4,
        color: primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Stack(
            children: [
              Positioned(
                bottom: 0,
                right: 0,
                child: Icon(
                  icon,
                  size: 70,
                  color: textColor.withOpacity(0.15),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
