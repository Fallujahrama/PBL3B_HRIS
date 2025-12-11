<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Absensi extends Model
{
    use HasFactory;

    protected $table = 'absensi';

    protected $fillable = [
        'employee_id',
        'tanggal',
        'status',
        'jam_masuk',
        'jam_pulang',
    ];

    public function employee()
    {
        return $this->belongsTo(Employee::class);
    }
}
