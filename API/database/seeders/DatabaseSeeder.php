<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // $this->call(UsersSeeder::class);
        $this->call(LetterFormatSeeder::class);
        $this->call(EmployeeSeeder::class);
        $this->call(CheckClocksSeeder::class);

        $this->call([
            //LetterFormatsSeeder::class,
            //LettersSeeder::class,
            DepartmentSeeder::class,
            
        ]);

        $this->call(PositionSeeder::class);
        // $this->call(SalaryReportSeeder::class);
    }
}
