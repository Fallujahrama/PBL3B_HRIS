<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;

class DepartmentSeeder extends Seeder
{
    public function run()

    
    {
        DB::table('departments')->insert([
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

            
        ]);
        
    }
}
