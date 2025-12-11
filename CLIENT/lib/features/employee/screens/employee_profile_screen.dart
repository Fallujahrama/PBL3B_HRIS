import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:hris_3B/features/employee/screens/employee_editProfile_screen.dart';

  String getGenderLabel(String gender) {
  if (gender == "M") return "Male";
  if (gender == "F") return "Female";
  return "Unknown";
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? employeeData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchEmployeeData();
  }

  String getGenderLabel(String gender) {
  if (gender == "M") return "Male";
  if (gender == "F") return "Female";
  return "Unknown";
}

Future<void> fetchEmployeeData() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("token");

    if (token == null) {
      print("Token tidak ditemukan");
      setState(() => isLoading = false);
      return;
    }

    final url = Uri.parse("http://127.0.0.1:8000/api/employee/profile");

    final response = await http.get(
  Uri.parse("http://127.0.0.1:8000/api/employee/profile"),
  headers: {
    "Authorization": "Bearer $token",
    "Accept": "application/json",
  },
);


    print("Status Code: ${response.statusCode}");
    print("Response Body: ${response.body}");

    final jsonBody = json.decode(response.body);

    if (response.statusCode == 200 && jsonBody["data"] != null) {
      setState(() {
        employeeData = jsonBody["data"];
        isLoading = false;
      });
    } else {
      print("Error: ${jsonBody["message"]}");
      setState(() => isLoading = false);
    }
  } catch (e) {
    print("Exception: $e");
    setState(() => isLoading = false);
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,


      appBar: AppBar(
        title: const Text(
          "Profile",
          style: TextStyle(
            color: Colors.white,     // <- Teks putih
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
          backgroundColor: Color(0xFF446A8C),
          elevation: 0,
          foregroundColor: Colors.white, // <- Biar icon juga putih
          leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/employee-dashboard'),
        ),
    ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : employeeData == null
              ? const Center(child: Text("Gagal memuat data"))
              : buildProfileUI(),
    );
  }

  Widget buildProfileUI() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),

          // FOTO PROFIL
          Center(
            child: Stack(
              children: [
                const CircleAvatar(
                  radius: 55,
                  backgroundImage: AssetImage("assets/profile.jpg"),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple,
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: const Icon(Icons.edit, color: Colors.white, size: 18),
                  ),
                )
              ],
            ),
          ),

          const SizedBox(height: 15),

          // NAMA
          Text(
            "${employeeData!['first_name']} ${employeeData!['last_name']}",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          // position — AMBIL DARI RELASI USER
          Text(
            employeeData!["position"]["name"]?? "-",
            style: const TextStyle(
              fontSize: 15,
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 25),

          // STATISTIC DUMMY
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              buildStatItem(Icons.timer_outlined, "180h", "Work Hours"),
              buildStatItem(Icons.local_fire_department, "3h", "Overtime"),
              buildStatItem(Icons.mail, "2", "Time Off Request"),
            ],
          ),

          const SizedBox(height: 30),

          // DETAIL PROFILE
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: DefaultTextStyle.merge(
              style: const TextStyle(fontSize: 20),
              child: Column(
                children: [
                  buildMenuItem(Icons.person, "First Name",
                      employeeData!["first_name"] ?? "-"),
                  buildMenuItem(Icons.badge, "Last Name",
                      employeeData!["last_name"] ?? "-"),
                  buildMenuItem(Icons.work, "Position",
                      employeeData!["position"]?["name"] ?? "-"),
                  buildMenuItem(Icons.apartment, "Department",
                      employeeData!["department"]?["name"] ?? "-"),
                  buildMenuItem(
                      Icons.male,
                      "Gender",
                      getGenderLabel(employeeData!["gender"]),
                    ),
                  buildMenuItem(Icons.location_on, "Address",
                      employeeData!["address"] ?? "-"),
                ],
              ),
            ),
          ),

          const SizedBox(height: 25),

          const SizedBox(height: 20),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmployeeEditProfileScreen(employeeData!),
                ),
              );
            },
            icon: const Icon(Icons.edit, color: Colors.white),
            label: const Text(
              "Edit Profile",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF446A8C),
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
          
        ],
      ),
    );
  }

  // ---- WIDGET BUILDER ----
  Widget buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.deepPurple),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
      ],
    );
  }

  Widget buildMenuItem(IconData icon, String title, String value) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: Colors.deepPurple),
          title: Text(title),
          trailing: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 16,        // 🩷 teks lebih besar
              color: Colors.black87,
            ),
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }
}

