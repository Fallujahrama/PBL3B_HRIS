<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Employee extends Model
{
    protected $table = 'employees';

    public function position()
    {
        return $this->belongsTo(Position::class);
    }
    public function departement()
    {
        return $this->belongsTo(Departement::class);
    }
    public function checkClocks()
    {
        return $this->hasMany(CheckClock::class);
    }
}
