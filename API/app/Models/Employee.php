<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Employee extends Model
{
    use HasFactory;
    
    protected $table = 'employees';
    protected $guarded = [];

    public function user()
    {
        return $this->belongsTo(User::class, 'user_id');
    }
    public function department()
    {
        return $this->belongsTo(Department::class, 'department_id', 'id');
    }
    public function position()
    {
        return $this->belongsTo(Position::class, 'position_id');
    }

   public function checkClocks()
    {
        return $this->hasMany(CheckClock::class);
    }

    public function letters()
    {
        return $this->hasMany(Letter::class, 'employee_id');
    }
}
