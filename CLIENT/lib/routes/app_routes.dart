import 'package:go_router/go_router.dart';
import 'package:tracer_study_test_api/features/summary_salary/screens/summary_salary_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/superior/screens/superior_screen.dart';
import '../features/employee/screens/employee_list_screen.dart';
import '../features/employee/screens/employee_add_screen.dart';
import '../features/employee/screens/employee_detail_screen.dart';
import '../features/employee/screens/employee_edit_screen.dart';
import '../features/position/screens/position_screen.dart';
import '../features/position/screens/position_form_screen.dart'; // Import baru
import '../features/position/models/position.dart'; // Import model
import '../features/department/screens/department_list_page.dart';
import '../features/department/screens/department_detail_page.dart';
import '../features/department/screens/department_form_page.dart';
import '../features/department/models/department.dart';
import '../features/department/screens/department_map_page.dart';

class AppRoutes {
  // 🔹 tambahkan konstanta nama route
  static const String departmentList = 'departmentList';
  static const String departmentDetail = 'departmentDetail';
  static const String departmentForm = 'departmentForm';
  static const String departmentMap = 'departmentMap';

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/summary-salary',
        name: 'summary-salary',
        builder: (context, state) => const SummarySalaryScreen(),
      ),
      GoRoute(
        path: '/positions',
        builder: (context, state) => const PositionScreen(),
        routes: [
          // Sub-route untuk Form (Tambah/Edit)
          GoRoute(
            path: 'form',
            builder: (context, state) {
              // Mengambil objek position yang dikirim via 'extra'
              Position? position = state.extra as Position?;
              return PositionFormScreen(position: position);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/departments',
        name: departmentList,
        builder: (context, state) => const DepartmentListPage(),
      ),
      GoRoute(
        path: '/department-detail',
        name: departmentDetail,
        builder: (context, state) {
          final dept = state.extra as Department;
          return DepartmentDetailPage(department: dept);
        },
      ),
      GoRoute(
        path: '/department-form',
        name: departmentForm, // ⬅ penting
        builder: (context, state) {
          final dept = state.extra as Department?;
          return DepartmentFormPage(department: dept);
        },
      ),
      GoRoute(
        path: '/department-map',
        name: departmentMap,
        builder: (context, state) => const DepartmentMapPage(),
      ),
      
      // Employee Routes
      GoRoute(
        path: '/employee',
        builder: (context, state) => const EmployeeListScreen(),
      ),
      GoRoute(
        path: '/employee/add',
        builder: (context, state) => const EmployeeAddScreen(),
      ),
      GoRoute(
        path: '/employee/detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EmployeeDetailScreen(employeeId: id);
        },
      ),
      GoRoute(
        path: '/employee/edit/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return EmployeeEditScreen(employeeId: id);
        },
      ),
    ],

    
  );
}