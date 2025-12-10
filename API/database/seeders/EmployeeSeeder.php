<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

// Models
use App\Models\User;
use App\Models\Department;
use App\Models\Position;
use App\Models\Employee;

class EmployeeSeeder extends Seeder
{
    public function run()
    {
        // ======================================================
        // =============== DEPARTMENTS ==========================
        // ======================================================
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

        // ======================================================
        // =============== POSITIONS ============================
        // ======================================================
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

        // ======================================================
        // =============== USERS ================================
        // ======================================================
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

        // ======================================================
        // =============== EMPLOYEES ============================
        // ======================================================
        $emp1 = Employee::create([
            'user_id' => $user1->id,
            'position_id' => $posManager->id,
            'department_id' => $deptHR->id,
            'first_name' => 'Wahyu',
            'last_name' => 'Saputra',
            'gender' => 'M',
            'address' => 'Malang'
        ]);

        $emp2 = Employee::create([
            'user_id' => $user2->id,
            'position_id' => $posStaff->id,
            'department_id' => $deptIT->id,
            'first_name' => 'Aldo',
            'last_name' => 'Febriansyah',
            'gender' => 'M',
            'address' => 'Batu'
        ]);

        $emp3 = Employee::create([
            'user_id' => $user3->id,
            'position_id' => $posIntern->id,
            'department_id' => $deptFinance->id,
            'first_name' => 'Siti',
            'last_name' => 'Rahma',
            'gender' => 'F',
            'address' => 'Malang'
        ]);

        // ======================================================
        // =============== CHECK CLOCKS =========================
        // ======================================================
        DB::table('check_clocks')->insert([
            [
                'employee_id' => $emp1->id,
                'check_clock_type' => 0,
                'date' => now(),
                'clock_in' => '08:00:00',
                'clock_out' => '17:00:00',
                'overtime_start' => null,
                'overtime_end' => null,
                'created_at' => now(),
                'updated_at' => now(),
            ],
            [
                'employee_id' => $emp2->id,
                'check_clock_type' => 1,
                'date' => now(),
                'clock_in' => '08:00:00',
                'clock_out' => '20:00:00',
                'overtime_start' => '17:00:00',
                'overtime_end' => '20:00:00',
                'created_at' => now(),
                'updated_at' => now(),
            ],
        ]);

        // ======================================================
        // =============== SCHEDULES ============================
        // ======================================================
        DB::table('schedules')->insert([
            ['date' => '2025-01-01', 'created_at' => now(), 'updated_at' => now()],
            ['date' => '2025-01-02', 'created_at' => now(), 'updated_at' => now()],
        ]);

        // ======================================================
        // =============== CACHE =================================
        // ======================================================
        DB::table('cache')->insert([
            [
                'key' => 'settings_app',
                'value' => json_encode(['theme' => 'dark']),
                'expiration' => time() + 3600,
            ],
        ]);

        // ======================================================
        // =============== CACHE LOCKS ===========================
        // ======================================================
        DB::table('cache_locks')->insert([
            [
                'key' => 'job_lock',
                'owner' => 'system',
                'expiration' => time() + 300,
            ],
        ]);

        // ======================================================
        // =============== JOBS ==================================
        // ======================================================
        DB::table('jobs')->insert([
            [
                'queue' => 'default',
                'payload' => json_encode(['task' => 'SendEmail']),
                'attempts' => 0,
                'reserved_at' => null,
                'available_at' => time(),
                'created_at' => time(),
            ],
        ]);

        // ======================================================
        // =============== JOB BATCH =============================
        // ======================================================
        DB::table('job_batches')->insert([
            [
                'id' => Str::uuid()->toString(),
                'name' => 'Batch Email',
                'total_jobs' => 10,
                'pending_jobs' => 0,
                'failed_jobs' => 1,
                'failed_job_ids' => json_encode([1]),
                'options' => null,
                'cancelled_at' => null,
                'created_at' => time(),
                'finished_at' => time(),
            ],
        ]);

        // ======================================================
        // =============== FAILED JOBS ===========================
        // ======================================================
        DB::table('failed_jobs')->insert([
            [
                'uuid' => Str::uuid()->toString(),
                'connection' => 'database',
                'queue' => 'default',
                'payload' => 'Sample payload',
                'exception' => 'Simulated exception...',
                'failed_at' => now(),
            ],
        ]);
    }
}
