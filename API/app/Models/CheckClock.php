<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CheckClock extends Model
{
    // Laravel otomatis menganggap tabelnya bernama 'check_clocks'
    // Jadi tidak perlu mendefinisikan protected $table = 'check_clocks'; 
    // kecuali nama tabelnya berbeda.

    protected $fillable = [
        'employee_id',
        'check_clock_type', // 0 = Reguler, 1 = Lembur
        'status',           // hadir, sakit, dinas, cuti
        'date',
        'clock_in',
        'clock_out',
        'overtime_start',
        'overtime_end',
    ];

    // Casting tipe data agar output JSON lebih rapi (opsional)
    protected $casts = [
        'date' => 'datetime:Y-m-d', // Format output tanggal saja
        'check_clock_type' => 'boolean',
    ];

    // Relasi ke Employee
    public function employee()
    {
        return $this->belongsTo(Employee::class);
    }
}