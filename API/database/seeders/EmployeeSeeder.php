<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\Department;
use App\Models\Position;
use App\Models\Employee;
use Illuminate\Support\Facades\Hash;

class EmployeeSeeder extends Seeder
{
    public function run()
    {
        // ===== 1. DEPARTMENTS =====
        $deptHR = Department::create([
            'name' => 'Human Resource',
            'radius' => '100'
        ]);

        $deptIT = Department::create([
            'name' => 'Information Technology',
            'radius' => '100'
        ]);

        $deptFinance = Department::create([
            'name' => 'Finance',
            'radius' => '100'
        ]);

        // ===== 2. POSITIONS =====
        $posManager = Position::create([
            'name' => 'Manager',
            'rate_reguler' => 50000,
            'rate_overtime' => 80000,
        ]);

        $posStaff = Position::create([
            'name' => 'Staff',
            'rate_reguler' => 30000,
            'rate_overtime' => 50000,
        ]);

        $posIntern = Position::create([
            'name' => 'Intern',
            'rate_reguler' => 15000,
            'rate_overtime' => 20000,
        ]);

        // ===== 3. USERS =====
        $user1 = User::create([
            'email' => 'manager@example.com',
            'password' => Hash::make('password'),
            'is_admin' => 1,
        ]);

        $user2 = User::create([
            'email' => 'staff@example.com',
            'password' => Hash::make('password'),
            'is_admin' => 0,
        ]);

        $user3 = User::create([
            'email' => 'intern@example.com',
            'password' => Hash::make('password'),
            'is_admin' => 0,
        ]);

        // ===== 4. EMPLOYEES =====
        Employee::create([
            'user_id' => $user1->id,
            'position_id' => $posManager->id,
            'department_id' => $deptHR->id,
            'first_name' => 'Wahyu',
            'last_name' => 'Saputra',
            'gender' => 'M',
            'address' => 'Malang'
        ]);

        Employee::create([
            'user_id' => $user2->id,
            'position_id' => $posStaff->id,
            'department_id' => $deptIT->id,
            'first_name' => 'Aldo',
            'last_name' => 'Febriansyah',
            'gender' => 'M',
            'address' => 'Batu'
        ]);

        Employee::create([
            'user_id' => $user3->id,
            'position_id' => $posIntern->id,
            'department_id' => $deptFinance->id,
            'first_name' => 'Siti',
            'last_name' => 'Rahma',
            'gender' => 'F',
            'address' => 'Malang'
        ]);
    }
}
