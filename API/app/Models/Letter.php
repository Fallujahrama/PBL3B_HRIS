<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Letter extends Model
{
    use HasFactory;

    protected $table = 'letters';

    protected $fillable = [
        'letter_format_id',
        'employee_id',
        'name',
        'jabatan',
        'departemen',
        'tanggal_mulai',
        'tanggal_selesai',
        'pdf_path',
        'status',
    ];

    /*
     * Relasi ke Employee
     */
    public function employee()
    {
        return $this->belongsTo(Employee::class);
    }

    /*
     * Relasi ke LetterFormat
     */
    public function letterFormat()
    {
        return $this->belongsTo(LetterFormat::class, 'letter_format_id');
    }
}
