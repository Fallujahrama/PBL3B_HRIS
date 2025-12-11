<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class CheckClocksSeeder extends Seeder
{
    public function run(): void
    {
        $data = [];

        // ambil employee id yang ada
        $employeeIds = DB::table('employees')->pluck('id')->toArray();
        if (empty($employeeIds)) {
            $this->command->error('No employees found. Seed employees first.');
            return;
        }

        // Helper random time
        function randomTime($start, $end) {
            $min = strtotime($start);
            $max = strtotime($end);
            return date('H:i:s', rand($min, $max));
        }

        // Bulan yang ingin di-seed
        $months = [10, 11, 12];
        $year = Carbon::now()->year; // Tahun ini

        foreach ($employeeIds as $emp) {

            foreach ($months as $month) {

                // Total hari per bulan
                $daysInMonth = Carbon::create($year, $month, 1)->daysInMonth;

                for ($day = 1; $day <= $daysInMonth; $day++) {

                    $date = Carbon::create($year, $month, $day)->format('Y-m-d');

                    // Status random
                    $statuses = ['hadir', 'hadir', 'hadir', 'sakit', 'dinas', 'cuti'];
                    $status = $statuses[array_rand($statuses)];

                    $clockIn = null;
                    $clockOut = null;
                    $overtimeStart = null;
                    $overtimeEnd = null;
                    $checkClockType = 0; // 0 = Reguler

                    if ($status === 'hadir') {

                        $clockIn = randomTime('07:30:00', '08:10:00');

                        $isOvertime = rand(1, 100) <= 30;

                        if ($isOvertime) {
                            $checkClockType = 1; // lembur
                            $clockOut = randomTime('16:10:00', '19:00:00');

                            $overtimeStart = randomTime('16:10:00', '17:30:00');
                            $overtimeEnd   = randomTime('17:31:00', '19:30:00');

                        } else {
                            $clockOut = randomTime('15:30:00', '16:00:00');
                        }

                    } else {
                        // sakit / dinas / cuti → jam default kantor
                        $clockIn = '08:00:00';
                        $clockOut = '16:00:00';
                        $checkClockType = 0;
                    }

                    $data[] = [
                        'employee_id'      => $emp,
                        'check_clock_type' => $checkClockType,
                        'status'           => $status,
                        'date'             => $date,
                        'clock_in'         => $clockIn,
                        'clock_out'        => $clockOut,
                        'overtime_start'   => $overtimeStart,
                        'overtime_end'     => $overtimeEnd,
                        'created_at'       => now(),
                        'updated_at'       => now(),
                    ];
                }
            }

        }

        DB::table('check_clocks')->insert($data);
    }
}
