<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CheckClock;
use Illuminate\Http\Request;
use App\Exports\AttendanceReportExport;
use Maatwebsite\Excel\Facades\Excel;

class AttendanceReportController extends Controller
{
    public function index(Request $request)
    {
        $query = CheckClock::query()->with('employee');

        // Filter: employee_name (bisa partial, diketik)
        if ($request->has('employee_name') && !empty($request->employee_name)) {
            $name = $request->employee_name;
            $query->whereHas('employee', function($q) use ($name) {
                $q->where('first_name', 'like', "%{$name}%")
                  ->orWhere('last_name', 'like', "%{$name}%");
            });
        }

        // Filter: department_id
        if ($request->has('department_id')) {
            $query->whereHas('employee', function($q) use ($request) {
                $q->where('department_id', $request->department_id);
            });
        }

        // Filter: date range
        if ($request->has('start_date') && $request->has('end_date')) {
            $query->whereBetween('date', [$request->start_date, $request->end_date]);
        }

        $records = $query->orderBy('date', 'DESC')->get();

        $data = $records->map(function ($record) {
            return [
                'employee_name' => $record->employee->first_name . ' ' . $record->employee->last_name,
                'department' => $record->employee->department->name ?? '-',
                'date' => $record->date,
                'clock_in' => $record->clock_in,
                'clock_out' => $record->clock_out,
                'overtime_start' => $record->overtime_start,
                'overtime_end' => $record->overtime_end,
            ];
        });

        return response()->json([
            'success' => true,
            'data' => $data,
            'message' => 'Laporan absensi berhasil diambil'
        ]);
    }
    // Export to Excel
    public function export(Request $request)
    {
        $startDate = $request->start_date;
        $endDate   = $request->end_date;
        $employeeName = $request->employee_name;

        return Excel::download(
            new AttendanceReportExport($startDate, $endDate, $employeeName),
            'attendance-report.xlsx'
        );
    }
}
