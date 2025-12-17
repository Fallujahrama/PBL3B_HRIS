<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class UsersTableSeeder extends Seeder
{
    public function run(): void
    {
        // Disable foreign key checks
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');

        // Truncate tables
        DB::table('users')->truncate();
        DB::table('employees')->truncate();
        DB::table('departments')->truncate();
        DB::table('positions')->truncate();

        // Enable foreign key checks
        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        // ==========================================
        // ============= DEPARTMENTS ================
        // ==========================================
        $departmentsData = [
            [
                'name' => 'Departemen Teknologi Informasi',
                'radius' => '150',
                'latitude' => '-7.946559',
                'longitude' => '112.615120',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Departemen Keuangan',
                'radius' => '120',
                'latitude' => '-7.946800',
                'longitude' => '112.614900',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Departemen SDM',
                'radius' => '100',
                'latitude' => '-7.946700',
                'longitude' => '112.615300',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Departemen Pemasaran',
                'radius' => '200',
                'latitude' => '-7.946400',
                'longitude' => '112.615500',
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Departemen Operasional',
                'radius' => '180',
                'latitude' => '-7.946250',
                'longitude' => '112.615650',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        DB::table('departments')->insert($departmentsData);
        $departments = DB::table('departments')->pluck('id', 'name')->toArray();

        // ==========================================
        // ============== POSITIONS =================
        // ==========================================
        $positionsData = [
            [
                'name' => 'Manager',
                'rate_reguler' => 150000,
                'rate_overtime' => 25000,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Staff HR',
                'rate_reguler' => 80000,
                'rate_overtime' => 15000,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Admin Office',
                'rate_reguler' => 60000,
                'rate_overtime' => 12000,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'name' => 'Staff',
                'rate_reguler' => 70000,
                'rate_overtime' => 13000,
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ];

        DB::table('positions')->insert($positionsData);
        $positions = DB::table('positions')->pluck('id', 'name')->toArray();

        // ==========================================
        // ========= USERS & EMPLOYEES ==============
        // ==========================================

        // Data Users dan Employees yang sesuai
        $usersAndEmployees = [
            [
                'email' => 'admin@corp.com',
                'password' => Hash::make('password'),
                'is_admin' => 1,
                'first_name' => 'Admin',
                'last_name' => 'System',
                'gender' => 'M',
                'address' => 'Malang, Jawa Timur',
                'department' => 'Departemen SDM',
                'position' => 'Manager',
            ],
            [
                'email' => 'satria@corp.com',
                'password' => Hash::make('password'),
                'is_admin' => 0,
                'first_name' => 'Satria',
                'last_name' => 'Wijaya',
                'gender' => 'M',
                'address' => 'Surabaya, Jawa Timur',
                'department' => 'Departemen Teknologi Informasi',
                'position' => 'Staff',
            ],
            [
                'email' => 'renal@corp.com',
                'password' => Hash::make('password'),
                'is_admin' => 0,
                'first_name' => 'Renal',
                'last_name' => 'Pratama',
                'gender' => 'M',
                'address' => 'Malang, Jawa Timur',
                'department' => 'Departemen Teknologi Informasi',
                'position' => 'Staff',
            ],
            [
                'email' => 'zaki@example.com',
                'password' => Hash::make('password'),
                'is_admin' => 0,
                'first_name' => 'Zaki',
                'last_name' => 'Ahmad',
                'gender' => 'M',
                'address' => 'Batu, Jawa Timur',
                'department' => 'Departemen Keuangan',
                'position' => 'Staff HR',
            ],
            [
                'email' => 'rahmalia@corp.com',
                'password' => Hash::make('password'),
                'is_admin' => 0,
                'first_name' => 'Rahmalia',
                'last_name' => 'Putri',
                'gender' => 'F',
                'address' => 'Malang, Jawa Timur',
                'department' => 'Departemen SDM',
                'position' => 'Staff HR',
            ],
            [
                'email' => 'arimbi@corp.com',
                'password' => Hash::make('password'),
                'is_admin' => 0,
                'first_name' => 'Arimbi',
                'last_name' => 'Sari',
                'gender' => 'F',
                'address' => 'Surabaya, Jawa Timur',
                'department' => 'Departemen Pemasaran',
                'position' => 'Staff',
            ],
            [
                'email' => 'fasya@corp.com',
                'password' => Hash::make('password'),
                'is_admin' => 0,
                'first_name' => 'Fasya',
                'last_name' => 'Amelia',
                'gender' => 'F',
                'address' => 'Malang, Jawa Timur',
                'department' => 'Departemen Operasional',
                'position' => 'Admin Office',
            ],
            [
                'email' => 'claudya@corp.com',
                'password' => Hash::make('password'),
                'is_admin' => 0,
                'first_name' => 'Claudya',
                'last_name' => 'Ningsih',
                'gender' => 'F',
                'address' => 'Batu, Jawa Timur',
                'department' => 'Departemen Keuangan',
                'position' => 'Admin Office',
            ],
        ];

        // Insert Users dan Employees
        foreach ($usersAndEmployees as $index => $data) {
            // Insert User
            $userId = DB::table('users')->insertGetId([
                'email' => $data['email'],
                'password' => $data['password'],
                'is_admin' => $data['is_admin'],
                'created_at' => now(),
                'updated_at' => now(),
            ]);

            // Insert Employee (kecuali untuk admin system yang tidak punya employee record)
            if ($data['email'] !== 'admin@corp.com' || $index === 0) {
                DB::table('employees')->insert([
                    'user_id' => $userId,
                    'position_id' => $positions[$data['position']],
                    'department_id' => $departments[$data['department']],
                    'first_name' => $data['first_name'],
                    'last_name' => $data['last_name'],
                    'gender' => $data['gender'],
                    'address' => $data['address'],
                    'created_at' => now(),
                    'updated_at' => now(),
                ]);
            }
        }

        echo "✅ Seeder berhasil dijalankan!\n";
        echo "   - " . count($departmentsData) . " Departments\n";
        echo "   - " . count($positionsData) . " Positions\n";
        echo "   - " . count($usersAndEmployees) . " Users & Employees\n";
    }
}
