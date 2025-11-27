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

        DB::table('users')->truncate();
        DB::table('departments')->truncate();
        DB::table('positions')->truncate();
        DB::table('employees')->truncate();
        DB::table('check_clocks')->truncate();
        DB::table('letter_formats')->truncate();
        DB::table('letters')->truncate();

        DB::statement('SET FOREIGN_KEY_CHECKS=1;');

        // ============================================================
        // USERS
        // ============================================================
        $users = [
            ['email' => 'admin@example.com', 'password' => Hash::make('password'), 'is_admin' => 1],
            ['email' => 'john@example.com',  'password' => Hash::make('password'), 'is_admin' => 0],
            ['email' => 'mary@example.com',  'password' => Hash::make('password'), 'is_admin' => 0],
            ['email' => 'alex@example.com',  'password' => Hash::make('password'), 'is_admin' => 0],
        ];

        DB::table('users')->insert($users);

        // ============================================================
        // DEPARTMENTS
        // ============================================================
        $departments = [
            ['name' => 'Production', 'radius' => '150'],
            ['name' => 'Marketing', 'radius' => '150'],
            ['name' => 'Finance',   'radius' => '150'],
            ['name' => 'HR',        'radius' => '150'],
        ];

        DB::table('departments')->insert($departments);

        // ============================================================
        // POSITIONS
        // ============================================================
        $positions = [
            ['name' => 'Production Supervisor', 'rate_reguler' => 72000, 'rate_overtime' => 108000],
            ['name' => 'Operator',              'rate_reguler' => 55000, 'rate_overtime' => 82500],
            ['name' => 'Marketing Specialist',  'rate_reguler' => 60000, 'rate_overtime' => 90000],
            ['name' => 'Accountant',            'rate_reguler' => 65000, 'rate_overtime' => 97500],
            ['name' => 'HR Officer',            'rate_reguler' => 62000, 'rate_overtime' => 93000],
        ];

        DB::table('positions')->insert($positions);

        // ============================================================
        // EMPLOYEES
        // ============================================================
        $employees = [
            [
                'user_id' => 2,
                'position_id' => 1,
                'department_id' => 1,
                'first_name' => 'John',
                'last_name' => 'Doe',
                'gender' => 'M',
                'address' => 'Jl. Mawar 12'
            ],
            [
                'user_id' => 3,
                'position_id' => 2,
                'department_id' => 1,
                'first_name' => 'Mary',
                'last_name' => 'Smith',
                'gender' => 'F',
                'address' => 'Jl. Melati 45'
            ],
            [
                'user_id' => 4,
                'position_id' => 5,
                'department_id' => 4,
                'first_name' => 'Alex',
                'last_name' => 'Johnson',
                'gender' => 'M',
                'address' => 'Jl. Kenanga 88'
            ],
        ];

        DB::table('employees')->insert($employees);

        // ============================================================
        // ATTENDANCE + OVERTIME (check_clocks)
        // ============================================================
        $checkClocks = [];

        foreach (DB::table('employees')->get() as $emp) {
            for ($i = 1; $i <= 10; $i++) {
                $date = Carbon::now()->subDays($i)->toDateString();

                $start = Carbon::parse("$date 08:00:00");
                $end = Carbon::parse("$date 17:00:00");

                $checkClocks[] = [
                    'employee_id' => $emp->id,
                    'check_clock_type' => 1, // present
                    'date' => $date,
                    'clock_in' => $start,
                    'clock_out' => $end,
                    'overtime_start' => $end,
                    'overtime_end' => Carbon::parse("$date 19:00:00"),
                    'created_at' => now(),
                    'updated_at' => now(),
                ];
            }
        }

        DB::table('check_clocks')->insert($checkClocks);

        // ============================================================
        // LETTER FORMATS (Templates)
        // ============================================================
        $formats = [
            ['name' => 'Surat Peringatan', 'content' => 'Isi SP'],
            ['name' => 'Surat Keterangan Kerja', 'content' => 'Isi SKK'],
            ['name' => 'Surat Cuti', 'content' => 'Isi Pengajuan Cuti'],
        ];

        DB::table('letter_formats')->insert($formats);

        // ============================================================
        // LETTERS
        // ============================================================
        $letters = [
            [
                'letter_format_id' => 1,
                'employee_id' => 1,
                'name' => 'SP-001',
                'status' => 1
            ],
            [
                'letter_format_id' => 3,
                'employee_id' => 2,
                'name' => 'CUTI-002',
                'status' => 0
            ],
        ];

        DB::table('letters')->insert($letters);

        echo "Seeder sukses dijalankan.\n";
    }
}
