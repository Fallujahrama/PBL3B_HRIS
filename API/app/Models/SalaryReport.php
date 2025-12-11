<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SalaryReport extends Model
{
    use HasFactory;

    protected $table = 'salary_reports';

    protected $fillable = [
        'employee_id',
        'employee_code',
        'month',
        'base_salary',
        'allowance',
        'overtime',
        'deduction',
        'net_salary',
        'bank_name',
        'bank_account_number',
        'bank_account_holder',
    ];

    public function employee()
    {
        return $this->belongsTo(Employee::class);
    }
}