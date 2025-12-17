<?php

namespace App\Exports;

use App\Models\CheckClock;
use Maatwebsite\Excel\Concerns\FromCollection;
use Maatwebsite\Excel\Concerns\WithHeadings;
use Maatwebsite\Excel\Concerns\WithMapping;

class AttendanceReportExport implements FromCollection, WithHeadings, WithMapping
{
    protected $startDate;
    protected $endDate;
    protected $employeeName;

    public function __construct($startDate = null, $endDate = null, $employeeName = null)
    {
        $this->startDate = $startDate;
        $this->endDate   = $endDate;
        $this->employeeName = $employeeName;
    }

    public function collection()
    {
        $query = CheckClock::with(['employee.department']);

        if ($this->startDate && $this->endDate) {
            $query->whereBetween('date', [$this->startDate, $this->endDate]);
        }

        if ($this->employeeName) {
            $query->whereHas('employee', function($q) {
                $q->where('first_name', 'like', "%{$this->employeeName}%")
                  ->orWhere('last_name', 'like', "%{$this->employeeName}%");
            });
        }

        return $query->orderBy('date', 'desc')->get();
    }

    public function map($row): array
    {
        return [
            optional($row->employee)->first_name . ' ' . optional($row->employee)->last_name,
            optional(optional($row->employee)->department)->name ?? '-',
            $row->date,
            $row->clock_in,
            $row->clock_out,
            $row->overtime_start,
            $row->overtime_end,
        ];
    }

    public function headings(): array
    {
        return [
            'Employee Name',
            'Department',
            'Date',
            'Clock In',
            'Clock Out',
            'Overtime Start',
            'Overtime End',
        ];
    }
}
