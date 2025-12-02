<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Carbon\Carbon;

class SalaryReportSeeder extends Seeder
{
    public function run()
    {
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');

        // Truncate tables
        DB::table('users')->truncate();
        DB::table('departments')->truncate();
        DB::table('positions')->truncate();
        DB::table('employees')->truncate();
        DB::table('check_clocks')->truncate();
        DB::table('letter_formats')->truncate();
        DB::table('letters')->truncate();

        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        // --- DEPARTMENTS ---
        $departmentsData = [
            ['name' => 'Factory', 'radius' => '150'], // Disesuaikan dengan mockup
            ['name' => 'Marketing', 'radius' => '150'],
            ['name' => 'Finance', 'radius' => '150'],
            ['name' => 'HR', 'radius' => '150'],
            ['name' => 'Research & Dev', 'radius' => '150'],
        ];
        DB::table('departments')->insert($departmentsData);
        $departments = DB::table('departments')->pluck('id', 'name')->toArray();

        // --- POSITIONS ---
        $positionsData = [
            ['name' => 'Supervisor', 'rate_reguler' => 72000, 'rate_overtime' => 108000],
            ['name' => 'Operator A', 'rate_reguler' => 55000, 'rate_overtime' => 82500],
            ['name' => 'Operator B', 'rate_reguler' => 50000, 'rate_overtime' => 75000],
            ['name' => 'Marketing Specialist', 'rate_reguler' => 60000, 'rate_overtime' => 90000],
            ['name' => 'Accountant', 'rate_reguler' => 65000, 'rate_overtime' => 97500],
            ['name' => 'HR Officer', 'rate_reguler' => 62000, 'rate_overtime' => 93000],
        ];
        DB::table('positions')->insert($positionsData);
        $positions = DB::table('positions')->pluck('id', 'name')->toArray();

        // --- USERS & EMPLOYEES ---
        $employeesData = [];
        $usersData = [];
        $employeeId = 1;

        // Data Karyawan Bervariasi (Total 35 Karyawan)
        $employeesList = [
            // Factory (Banyak & Lembur tinggi untuk meniru mockup)
            ['first_name' => 'John', 'last_name' => 'Doe', 'dept' => 'Factory', 'pos' => 'Supervisor'],
            ['first_name' => 'Mary', 'last_name' => 'Smith', 'dept' => 'Factory', 'pos' => 'Operator A'],
            ['first_name' => 'Peter', 'last_name' => 'Jones', 'dept' => 'Factory', 'pos' => 'Operator B'],
            ['first_name' => 'Anna', 'last_name' => 'Lee', 'dept' => 'Factory', 'pos' => 'Operator A'],
            ['first_name' => 'Ben', 'last_name' => 'Chua', 'dept' => 'Factory', 'pos' => 'Operator B'],
            ['first_name' => 'Cindy', 'last_name' => 'Wu', 'dept' => 'Factory', 'pos' => 'Operator A'],
            ['first_name' => 'David', 'last_name' => 'Chen', 'dept' => 'Factory', 'pos' => 'Operator B'],
            ['first_name' => 'Erica', 'last_name' => 'Lin', 'dept' => 'Factory', 'pos' => 'Operator A'],
            ['first_name' => 'Gary', 'last_name' => 'Huang', 'dept' => 'Factory', 'pos' => 'Operator B'],
            ['first_name' => 'Helen', 'last_name' => 'Wang', 'dept' => 'Factory', 'pos' => 'Operator A'],
            // Tambahkan 10 karyawan Factory lagi
            ...array_map(function($i) {
                return ['first_name' => "FactEmp", 'last_name' => "$i", 'dept' => 'Factory', 'pos' => ($i % 2 == 0 ? 'Operator A' : 'Operator B')];
            }, range(11, 20)),

            // Marketing
            ['first_name' => 'Michael', 'last_name' => 'Brown', 'dept' => 'Marketing', 'pos' => 'Marketing Specialist'],
            ['first_name' => 'Chloe', 'last_name' => 'Taylor', 'dept' => 'Marketing', 'pos' => 'Marketing Specialist'],
            ['first_name' => 'Kevin', 'last_name' => 'Davis', 'dept' => 'Marketing', 'pos' => 'Supervisor'],
            // Tambahkan 2 karyawan Marketing lagi
            ...array_map(function($i) {
                return ['first_name' => "Mktg", 'last_name' => "$i", 'dept' => 'Marketing', 'pos' => 'Marketing Specialist'];
            }, range(4, 5)),

            // Finance
            ['first_name' => 'Alex', 'last_name' => 'Johnson', 'dept' => 'Finance', 'pos' => 'Accountant'],
            ['first_name' => 'Sarah', 'last_name' => 'Wilson', 'dept' => 'Finance', 'pos' => 'Accountant'],
            ['first_name' => 'Daniel', 'last_name' => 'Miller', 'dept' => 'Finance', 'pos' => 'Supervisor'],
            // Tambahkan 2 karyawan Finance lagi
             ...array_map(function($i) {
                return ['first_name' => "Fin", 'last_name' => "$i", 'dept' => 'Finance', 'pos' => 'Accountant'];
            }, range(4, 5)),

            // HR
            ['first_name' => 'Emily', 'last_name' => 'Garcia', 'dept' => 'HR', 'pos' => 'HR Officer'],
            ['first_name' => 'Chris', 'last_name' => 'Martinez', 'dept' => 'HR', 'pos' => 'HR Officer'],
            ['first_name' => 'Jessica', 'last_name' => 'Rodri', 'dept' => 'HR', 'pos' => 'Supervisor'],
             // Tambahkan 2 karyawan HR lagi
             ...array_map(function($i) {
                return ['first_name' => "HR", 'last_name' => "$i", 'dept' => 'HR', 'pos' => 'HR Officer'];
            }, range(4, 5)),

            // Research & Dev
            ['first_name' => 'Rudy', 'last_name' => 'Setiawan', 'dept' => 'Research & Dev', 'pos' => 'Supervisor'],
            ['first_name' => 'Dian', 'last_name' => 'Wulandari', 'dept' => 'Research & Dev', 'pos' => 'Marketing Specialist'], // Position flex
        ];

        foreach ($employeesList as $data) {
            $email = strtolower($data['first_name'] . '.' . $data['last_name']) . '@corp.com';
            $usersData[] = [
                'email' => $email,
                'password' => Hash::make('password'),
                'is_admin' => ($data['pos'] === 'Supervisor') ? 1 : 0,
            ];

            $employeesData[] = [
                'user_id' => $employeeId,
                'position_id' => $positions[$data['pos']],
                'department_id' => $departments[$data['dept']],
                'first_name' => $data['first_name'],
                'last_name' => $data['last_name'],
                'gender' => (in_array($data['first_name'], ['Mary', 'Anna', 'Cindy', 'Erica', 'Chloe', 'Sarah', 'Emily', 'Jessica', 'Dian'])) ? 'F' : 'M',
                'address' => 'Sample Address ' . $employeeId,
            ];
            $employeeId++;
        }

        // Tambahkan Admin Utama
        $usersData[] = ['email' => 'admin@example.com', 'password' => Hash::make('password'), 'is_admin' => 1];
        $adminUserId = count($usersData);

        DB::table('users')->insert($usersData);
        DB::table('employees')->insert($employeesData);

        // --- ATTENDANCE + OVERTIME (check_clocks) ---
        $allEmployees = DB::table('employees')->get();
        $checkClocks = [];

        // Rentang waktu: 2 bulan penuh (Bulan Sebelumnya dan Bulan Saat Ini)
        $today = Carbon::now();
        $startMonth = $today->copy()->subMonth()->startOfMonth();
        $endMonth = $today->endOfMonth();

        $currentDate = $startMonth->copy();

        while ($currentDate->lessThanOrEqualTo($endMonth)) {
            // Lewati Sabtu dan Minggu
            if ($currentDate->isWeekday()) {
                foreach ($allEmployees as $emp) {
                    // Cek apakah karyawan bekerja hari itu (misalnya 90% hari kerja)
                    if (rand(1, 10) <= 9) {
                        $dateString = $currentDate->toDateString();
                        $deptName = DB::table('departments')->where('id', $emp->department_id)->value('name');

                        $clockIn = Carbon::parse("$dateString 08:00:00");
                        $clockOut = Carbon::parse("$dateString 17:00:00");
                        $overtimeStart = null;
                        $overtimeEnd = null;

                        // Tambahkan Lembur (Overtime)
                        if ($deptName == 'Factory' || rand(1, 10) <= 4) { // Factory sering lembur, departemen lain kadang-kadang
                            $overtimeHours = ($deptName == 'Factory') ? rand(1, 3) : rand(1, 2); // Factory 1-3 jam, lain 1-2 jam
                            $overtimeStart = $clockOut;
                            $overtimeEnd = $clockOut->copy()->addHours($overtimeHours);
                        }

                        // Buat data CheckClock
                        $checkClocks[] = [
                            'employee_id' => $emp->id,
                            'check_clock_type' => 1, // present
                            'date' => $dateString,
                            'clock_in' => $clockIn,
                            'clock_out' => $clockOut,
                            'overtime_start' => $overtimeStart,
                            'overtime_end' => $overtimeEnd,
                            'created_at' => now(),
                            'updated_at' => now(),
                        ];
                    }
                }
            }
            $currentDate->addDay();
        }

        DB::table('check_clocks')->insert($checkClocks);

        // --- LETTER FORMATS (Templates) ---
        $formats = [
            ['name' => 'Surat Peringatan', 'content' => 'Isi SP'],
            ['name' => 'Surat Keterangan Kerja', 'content' => 'Isi SKK'],
            ['name' => 'Surat Cuti', 'content' => 'Isi Pengajuan Cuti'],
        ];
        DB::table('letter_formats')->insert($formats);

        // --- LETTERS ---
        $letters = [
            ['letter_format_id' => 1, 'employee_id' => 1, 'name' => 'SP-001', 'status' => 1],
            ['letter_format_id' => 3, 'employee_id' => 5, 'name' => 'CUTI-002', 'status' => 0],
        ];
        DB::table('letters')->insert($letters);

        echo "Seeder sukses dijalankan dengan " . count($allEmployees) . " karyawan dan " . count($checkClocks) . " data kehadiran/lembur.\n";
    }
}
