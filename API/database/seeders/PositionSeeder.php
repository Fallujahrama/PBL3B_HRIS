<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class PositionSeeder extends Seeder
{
    public function run(): void
    {
        DB::table('positions')->insert([
            [
                'name' => 'Manager',
                'rate_reguler' => 150000,
                'rate_overtime' => 25000,
            ],
            [
                'name' => 'Staff HR',
                'rate_reguler' => 80000,
                'rate_overtime' => 15000,
            ],
            [
                'name' => 'Admin Office',
                'rate_reguler' => 60000,
                'rate_overtime' => 12000,
            ],
        ]);
    }
}