import 'user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class UserLoggedModel {
  // 1. Singleton Instantiation
  static final UserLoggedModel _instance = UserLoggedModel._internal();
  factory UserLoggedModel() => _instance;
  UserLoggedModel._internal();

  // 2. Data State
  User? _currentUser;
  
  // Getter untuk mengakses data pengguna
  User? get currentUser => _currentUser;
  // Getter untuk data employee (Akses melalui objek User)
  Map<String, dynamic>? get employeeData => _currentUser?.employeeData; 

  // Cek apakah user sudah login
  bool get isLoggedIn => _currentUser != null;

  // 3. Methods untuk Set Data Setelah Login
  void setLoggedInUser(User user) {
    _currentUser = user;
    _saveUserToPrefs(user); 
  }

  // 4. Methods untuk LogOut
  Future<void> clearUser() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userDataJson'); // Hapus JSON lengkap
    // Hapus kunci lama/tambahan
    await prefs.remove('userName');
    await prefs.remove('userEmail');
    await prefs.remove('employeeDataJson'); 
  }

  // =========================================================
  // 5. Persistensi: Inisialisasi dari SharedPreferences (Startup)
  // =========================================================

  Future<void> initializeUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userDataJson = prefs.getString('userDataJson'); // Ambil JSON lengkap

    if (token != null && token.isNotEmpty && userDataJson != null) {
      try {
        final userMap = jsonDecode(userDataJson) as Map<String, dynamic>;
        
        // Buat ulang objek User dari JSON yang tersimpan
        _currentUser = User.fromJson(userMap, token); 
      } catch (e) {
        // Gagal parsing, hapus data lama
        await clearUser();
        print("Error loading user data from prefs: $e");
      }
    }
  }

  // Metode untuk Menyimpan Objek User lengkap
  void _saveUserToPrefs(User user) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Simpan token (kunci utama)
    await prefs.setString('token', user.token);
    
    // Simpan seluruh data user (termasuk employeeData) sebagai JSON string
    // NOTE: Kita perlu menyertakan token saat memuat ulang, jadi kita simpan JSON struktural saja.
    final userJsonStructure = user.toJson();

    await prefs.setString('userDataJson', jsonEncode(userJsonStructure));
    
    // Simpan data kunci lama (optional, untuk backward compatibility)
    await prefs.setString('userName', user.name);
    await prefs.setString('userEmail', user.email);
  }
}