<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class AbsensiSeeder extends Seeder
{
    public function run(): void
    {
        $data = [];

        // Helper function buat random jam masuk & pulang
        function randomTime($start, $end) {
            $min = strtotime($start);
            $max = strtotime($end);
            return date('H:i:s', rand($min, $max));
        }

        // Loop tiap employee
        for ($emp = 1; $emp <= 4; $emp++) {

            for ($day = 1; $day <= 30; $day++) {

                $date = '2025-11-' . str_pad($day, 2, '0', STR_PAD_LEFT);

                // Status random: hadir / sakit / izin
                $statuses = ['hadir', 'hadir', 'hadir', 'sakit', 'izin'];
                $status = $statuses[array_rand($statuses)];

                // Jam masuk
                $jamMasuk = randomTime('07:30:00', '08:10:00');

                // Tentukan jam pulang
                if ($status === 'hadir') {
                    // 70% pulang normal, 30% lembur
                    $isOvertime = rand(1, 100) <= 30;

                    if ($isOvertime) {
                        $jamPulang = randomTime('16:10:00', '19:00:00');
                        $status = 'lembur';
                    } else {
                        $jamPulang = randomTime('15:30:00', '16:00:00');
                    }

                } else {
                    // Sakit / izin → tidak ada jam kerja
                    $jamMasuk = null;
                    $jamPulang = null;
                }

                $data[] = [
                    'employee_id' => $emp,
                    'tanggal' => $date,
                    'status' => $status,
                    'jam_masuk' => $jamMasuk,
                    'jam_pulang' => $jamPulang,
                ];
            }
        }

        DB::table('absensi')->insert($data);
    }
}