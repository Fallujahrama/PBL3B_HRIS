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

    /**
     * Scope: Get attendance for a specific date
     */
    public function scopeByDate($query, $date)
    {
        return $query->whereDate('date', $date);
    }

    /**
     * Scope: Get attendance for a specific employee
     */
    public function scopeByEmployee($query, $employeeId)
    {
        return $query->where('employee_id', $employeeId);
    }

    /**
     * Scope: Get attendance for a date range
     */
    public function scopeBetweenDates($query, $startDate, $endDate)
    {
        return $query->whereBetween('date', [$startDate, $endDate]);
    }

    /**
     * Scope: Get today attendance
     */
    public function scopeToday($query)
    {
        return $query->whereDate('date', now()->format('Y-m-d'));
    }

    /**
     * Check if employee has clocked in today
     */
    public function getHasClockedInAttribute(): bool
    {
        return !is_null($this->clock_in);
    }

    /**
     * Check if employee has clocked out today
     */
    public function getHasClockedOutAttribute(): bool
    {
        return !is_null($this->clock_out);
    }

    /**
     * Check if employee has started overtime
     */
    public function getHasOvertimeStartAttribute(): bool
    {
        return !is_null($this->overtime_start);
    }

    /**
     * Check if employee has ended overtime
     */
    public function getHasOvertimeEndAttribute(): bool
    {
        return !is_null($this->overtime_end);
    }

    /**
     * Get attendance status
     */
    public function getAttendanceStatusAttribute(): string
    {
        if ($this->clock_in && $this->clock_out) {
            return 'LENGKAP';
        } elseif ($this->clock_in && !$this->clock_out) {
            return 'CLOCK_IN_ONLY';
        } else {
            return 'BELUM_ABSEN';
        }
    }

    /**
     * Get overtime status
     */
    public function getOvertimeStatusAttribute(): string
    {
        if ($this->overtime_start && $this->overtime_end) {
            return 'LENGKAP';
        } elseif ($this->overtime_start && !$this->overtime_end) {
            return 'IN_PROGRESS';
        } else {
            return 'TIDAK_ADA';
        }
    }

    /**
     * Get working hours as string
     * Returns: "8h 30m" or null
     */
    public function getWorkingHoursAttribute(): ?string
    {
        if (!$this->clock_in || !$this->clock_out) {
            return null;
        }

        $checkIn = strtotime($this->clock_in);
        $checkOut = strtotime($this->clock_out);
        $diffSeconds = $checkOut - $checkIn;

        if ($diffSeconds <= 0) return null;

        $hours = intval($diffSeconds / 3600);
        $minutes = intval(($diffSeconds % 3600) / 60);

        return "{$hours}h {$minutes}m";
    }

    /**
     * Get overtime hours as string
     * Returns: "2h 15m" or null
     */
    public function getOvertimeHoursAttribute(): ?string
    {
        if (!$this->overtime_start || !$this->overtime_end) {
            return null;
        }

        $overtimeStart = strtotime($this->overtime_start);
        $overtimeEnd = strtotime($this->overtime_end);
        $diffSeconds = $overtimeEnd - $overtimeStart;

        if ($diffSeconds <= 0) return null;

        $hours = intval($diffSeconds / 3600);
        $minutes = intval(($diffSeconds % 3600) / 60);

        return "{$hours}h {$minutes}m";
    }
}