import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async { 
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env"); 
  
  runApp(const MyApp()); 
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const primaryBlue = Color.fromARGB(255, 0, 140, 255);
    final lightColorScheme = ColorScheme.fromSeed(
        seedColor: primaryBlue,
        brightness: Brightness.light, // Pastikan ini mode terang
    );
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: AppRoutes.router,
      themeMode: ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: lightColorScheme, // Gunakan skema yang dihasilkan
      ),
    );
  }
}
