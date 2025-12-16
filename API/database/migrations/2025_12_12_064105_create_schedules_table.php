<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        if (!Schema::hasTable('schedules')) {
            Schema::create('schedules', function (Blueprint $table) {
                $table->id();
                $table->date('date');
                $table->string('name');
                $table->timestamps();

                // cegah duplikasi tanggal + nama
                $table->unique(['date', 'name'], 'schedules_date_name_unique');
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('schedules');
    }
};
