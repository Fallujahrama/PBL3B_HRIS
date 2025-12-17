<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Builder;
use Carbon\Carbon;

class Schedule extends Model
{
    protected $fillable = ['date', 'name'];

    public static function isHoliday($date)
    {
        return self::where('date', $date)->exists();
    }
}
