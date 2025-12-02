<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class CheckClock extends Model
{
    protected $table = 'check_clocks';

    public function employee()
    {
        return $this->belongsTo(Employee::class);
    }
}
