import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/department.dart';
import '../services/department_service.dart';
import '../../../widgets/app_drawer.dart';
import 'package:go_router/go_router.dart';


class DepartmentMapPage extends StatefulWidget {
  const DepartmentMapPage({super.key});

  @override
  State<DepartmentMapPage> createState() => _DepartmentMapPageState();
}

class _DepartmentMapPageState extends State<DepartmentMapPage> {
  late Future<List<Department>> _futureDepartments;

  @override
  void initState() {
    super.initState();
    _futureDepartments = DepartmentService.fetchDepartments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text("Map Department"),
      ),
      body: FutureBuilder<List<Department>>(
        future: _futureDepartments,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          }

          final departments = snapshot.data ?? [];

          if (departments.isEmpty) {
            return const Center(child: Text("Tidak ada data department"));
          }

          // Default center map (pakai salah satu department saja)
          final firstDept = departments.first;
          final defaultCenter = LatLng(
            double.tryParse(firstDept.latitude ?? "0") ?? 0,
            double.tryParse(firstDept.longitude ?? "0") ?? 0,
          );

          return FlutterMap(
            options: MapOptions(
              initialCenter: defaultCenter,
              initialZoom: 17,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "com.pbl3b.hris.whildan",
              ),

              // MARKER LAYER
              MarkerLayer(
                markers: departments
                    .map(
                      (dept) => Marker(
                        point: LatLng(
                          double.tryParse(dept.latitude ?? "0") ?? 0,
                          double.tryParse(dept.longitude ?? "0") ?? 0,
                        ),
                        width: 60,
                        height: 60,
                        child: GestureDetector(
                          onTap: () {
                            // buka detail departemen
                            context.push(
                              '/department-detail',
                              extra: dept,
                            );
                          },
                          child: const Icon(
                            Icons.location_on,
                            size: 40,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
