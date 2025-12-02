import 'package:go_router/go_router.dart';

import '../features/splash/screens/splash_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/superior/screens/superior_screen.dart';
import '../features/department/screens/department_list_page.dart';
import '../features/department/screens/department_detail_page.dart';
import '../features/department/screens/department_form_page.dart';
import '../features/department/models/department.dart';

class AppRoutes {
  // 🔹 tambahkan konstanta nama route
  static const String departmentList = 'departmentList';
  static const String departmentDetail = 'departmentDetail';
  static const String departmentForm = 'departmentForm';

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
        path: '/superior',
        name: 'superior',
        builder: (context, state) => const SuperiorScreen(),
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
    ],
  );
}