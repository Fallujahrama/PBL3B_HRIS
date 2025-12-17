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
        $this->call(UsersTableSeeder::class);

        $this->call(LetterFormatSeeder::class);
        // $this->call(EmployeeSeeder::class);
        $this->call(CheckClocksSeeder::class);
    }
}
