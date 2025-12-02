import 'package:go_router/go_router.dart';
import 'package:tracer_study_test_api/features/summary_salary/screens/summary_salary_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/superior/screens/superior_screen.dart';
import '../features/position/screens/position_screen.dart';
import '../features/position/screens/position_form_screen.dart'; // Import baru
import '../features/position/models/position.dart'; // Import model

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
        path: '/summary-salary',
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
    ],

    
  );
}