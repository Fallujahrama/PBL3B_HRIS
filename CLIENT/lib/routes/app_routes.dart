import 'package:go_router/go_router.dart';
import 'package:tracer_study_test_api/features/summary_salary/screens/summary_salary_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/superior/screens/superior_screen.dart';

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
        path: '/summary-salary',
        builder: (context, state) => const SummarySalaryScreen(),
      ),
    ],
  );
}
