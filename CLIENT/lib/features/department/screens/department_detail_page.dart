import 'package:flutter/material.dart';

import '../models/department.dart';
import '../../../widgets/app_drawer.dart';

class DepartmentDetailPage extends StatelessWidget {
  final Department department;

  const DepartmentDetailPage({
    super.key,
    required this.department,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(department.name),
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  department.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Radius: ${department.radius} meter'),
                const SizedBox(height: 8),
                Text('Latitude : ${department.latitude ?? '-'}'),
                Text('Longitude: ${department.longitude ?? '-'}'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}