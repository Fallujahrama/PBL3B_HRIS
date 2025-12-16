<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class UsersTableSeeder extends Seeder
{
    public function run(): void
    {
        DB::statement('SET FOREIGN_KEY_CHECKS=0;');
    DB::table('users')->truncate();
    DB::statement('SET FOREIGN_KEY_CHECKS=1;');
        DB::table('users')->insert([
            ['id' => 1, 'email' => 'admin@corp.com', 'password' => Hash::make('password'), 'is_admin' => 1, 'created_at' => now(), 'updated_at' => now()],
            ['id' => 2, 'email' => 'satria@corp.com', 'password' => Hash::make('password'), 'is_admin' => 0, 'created_at' => now(), 'updated_at' => now()],
            ['id' => 3, 'email' => 'renal@corp.com', 'password' => Hash::make('password'), 'is_admin' => 0, 'created_at' => now(), 'updated_at' => now()],
            ['id' => 4, 'email' => 'zaki@example.com', 'password' => Hash::make('password'), 'is_admin' => 0, 'created_at' => now(), 'updated_at' => now()],
            ['id' => 5, 'email' => 'rahmalia@corp.com', 'password' => Hash::make('password'), 'is_admin' => 0, 'created_at' => now(), 'updated_at' => now()],
            ['id' => 6, 'email' => 'arimbi@corp.com', 'password' => Hash::make('password'), 'is_admin' => 0, 'created_at' => now(), 'updated_at' => now()],
            ['id' => 7, 'email' => 'fasya@corp.com', 'password' => Hash::make('password'), 'is_admin' => 0, 'created_at' => now(), 'updated_at' => now()],
            ['id' => 8, 'email' => 'claudya@corp.com', 'password' => Hash::make('password'), 'is_admin' => 0, 'created_at' => now(), 'updated_at' => now()],
        ]);
    }
}