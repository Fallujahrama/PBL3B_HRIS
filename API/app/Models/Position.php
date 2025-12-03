<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Position extends Model
{
    use HasFactory;

    protected $table = 'positions';

    // WAJIB ADA: Agar bisa create/update data dari Controller
    protected $fillable = [
        'name',
        'rate_reguler',
        'rate_overtime',
    ];
}