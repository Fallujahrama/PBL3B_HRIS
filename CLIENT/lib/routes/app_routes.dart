import 'package:go_router/go_router.dart';

import '../features/splash/screens/splash_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/superior/screens/superior_screen.dart';
import '../features/department/screens/department_list_page.dart';
import '../features/department/screens/department_detail_page.dart';
import '../features/department/models/department.dart';

class AppRoutes {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/superior',
        builder: (context, state) => const SuperiorScreen(),
      ),
      GoRoute(
        path: '/departments',
        builder: (context, state) => const DepartmentListPage(),
      ),
      GoRoute(
        path: '/department-detail',
        builder: (context, state) {
          final dept = state.extra as Department;
          return DepartmentDetailPage(department: dept);
        },
      ),
    ],
  );
}