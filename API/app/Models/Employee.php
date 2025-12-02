<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Employee extends Model
{
    protected $table = 'employees'; 
    protected $guarded = [];

    public function user()
    {
        return $this->belongsTo(User::class);
    }
    public function department()
    {
        return $this->belongsTo(Department::class, 'department_id', 'id');
    }
    public function position()
    {
        return $this->belongsTo(Position::class);
   public function checkClocks()
    {
        return $this->hasMany(CheckClock::class);
    }
}
