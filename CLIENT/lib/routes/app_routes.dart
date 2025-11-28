import 'package:go_router/go_router.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/superior/screens/superior_screen.dart';
import '../features/employee/screens/employee_list_screen.dart';
import '../features/employee/screens/employee_add_screen.dart';
import '../features/employee/screens/employee_detail_screen.dart';
import '../features/employee/screens/employee_edit_screen.dart';

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