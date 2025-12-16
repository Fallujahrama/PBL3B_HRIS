import 'package:go_router/go_router.dart';
import 'package:hris_3B/features/summary_salary/screens/summary_salary_screen.dart';
// import 'package:tracer_study_test_api/features/summary_salary/screens/summary_salary_screen.dart';
import '../features/splash/screens/splash_screen.dart';
import '../features/home/screens/home_screen.dart';
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

import '../features/home/screens/letter_home_screen.dart';
import '../features/master-data/screens/master_data_screen.dart';
import '../features/letter/screens/letter_list_screen.dart';
import '../features/letter/screens/letter_create_screen.dart';
import '../features/letter/screens/letter_detail_screen.dart';
import '../features/letter/screens/letter_template_form_screen.dart';
import '../features/letter/models/letter_format.dart';
import '../features/letter/screens/employee_recap_page.dart';
import '../features/form/screen/form_surat_page.dart';
import '../features/form/screen/hrd_list_page.dart';
import '../features/form/screen/hrd_detail_page.dart';
import '../features/employee/screens/employee_salary_screen.dart';
import '../features/employee/screens/employee_report_screen.dart';
import '../features/employee/screens/employee_profile_screen.dart';
import '../features/absensi/screens/attendance_screen.dart';
import '../features/login/screens/login_screen.dart';
import '../features/login/screens/forgot_password_page.dart';
import '../features/dashboard/screens/landing_screen.dart';
import '../features/dashboard/screens/admin_dashboard_screen.dart';
import '../features/dashboard/screens/employee_dashboard_screen.dart';

class AppRoutes {
  // 🔹 tambahkan konstanta nama route
  static const String departmentList = 'departmentList';
  static const String departmentDetail = 'departmentDetail';
  static const String departmentForm = 'departmentForm';
  static const String departmentMap = 'departmentMap';

  static const String letterHome = '/letter-home';
  static const String formSurat = '/form-surat';
  static const String hrdList = '/hrd-list';
  static const String detailSurat = '/detail-surat';
  static const String employeeRecap = '/employee-recap';
  static const String letterList = '/letters';
  static const String letterTemplateCreate = '/letter/template/create';
  static const String letterTemplateEdit = '/letter/template/edit';
  static const String letterCreate = '/letter/create';
  static const String letterDetail = '/letter';

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
      path: '/landing',
      builder: (context, state) => const LandingScreen(),
    ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/master-data',
        name: 'master-data',
        builder: (context, state) => const MasterDataScreen(),
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
      // ============================
      // LETTER ROUTES
      // ============================
      // GoRoute(
      //   path: letterHome,
      //   builder: (context, state) => const LetterHomeScreen(),
      // ),

      // KARYAWAN ROUTES
      GoRoute(
        path: formSurat,
        builder: (context, state) => const FormSuratPage(),
      ),

      // HRD ROUTES
      GoRoute(
        path: hrdList,
        builder: (context, state) => const HrdListPage(),
      ),
      GoRoute(
        path: detailSurat,
        builder: (context, state) =>
            HrdDetailPage(surat: state.extra as Map<String, dynamic>),
      ),

      // ADMIN ROUTES - Template Management
      GoRoute(
        path: letterList,
        builder: (context, state) => const LettersListScreen(),
      ),
      GoRoute(
        path: letterTemplateCreate,
        builder: (context, state) => const LetterTemplateFormScreen(),
      ),
      GoRoute(
        path: letterTemplateEdit,
        builder: (context, state) {
          final template = state.extra as LetterFormat;
          return LetterTemplateFormScreen(template: template);
        },
      ),
      GoRoute(
        path: letterCreate,
        builder: (context, state) {
          final extra = state.extra as LetterFormat;
          return LetterCreateScreen(jenisSurat: extra);
        },
      ),
      GoRoute(
        path: '$letterDetail/:id',
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return LetterDetailScreen(id: id);
        },
      ),

      // LAPORAN
      GoRoute(
        path: employeeRecap,
        builder: (context, state) => const EmployeeRecapPage(),
      ),

       // ======================
      // AUTH
      // ======================
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordPage(),
      ),

      // ======================
      // DASHBOARD ADMIN
      // ======================
      GoRoute(
        path: '/admin-dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),

      // ======================
      // DASHBOARD EMPLOYEE
      // ======================
      GoRoute(
        path: '/employee-dashboard', 
        builder: (context, state) => const EmployeeDashboardScreen(),
      ),
  

      GoRoute(
        path: '/employee/salary',
        builder: (context, state) => const EmployeeSalaryScreen(),
      ),

      GoRoute(
        path: '/employee/report',
        builder: (context, state) => const EmployeeReportScreen(),
      ),
      GoRoute(
        path: '/employee/profile',
        builder: (context, state) => const ProfilePage(),
      ),
      // Attendance ROUTES
      GoRoute(
        path: '/attendance',
        builder: (context, state) => const AttendanceScreen(),
      ),
    ],
  );
}