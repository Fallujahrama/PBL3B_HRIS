<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up()
    {
        Schema::create('positions', function (Blueprint $table) {
            $table->id();
            $table->string('name');

            // Gaji dasar
            $table->decimal('base_salary', 12, 2)->default(0);

            // Rate per jam / per hari
            $table->decimal('rate_reguler', 12, 2)->default(0);
            $table->decimal('rate_overtime', 12, 2)->default(0);

            // Tunjangan tetap
            $table->decimal('allowance', 12, 2)->default(0);

            $table->timestamps();
        });
    }


    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('positions');
    }
};