<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\CheckClock;
use App\Models\Employee;
use App\Models\Department;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Carbon\Carbon;

class SalaryReportController extends Controller
{
    /**
     * Mengambil daftar Departemen untuk filter dropdown.
     */
    public function getDepartments()
    {
        $departments = Department::select('id', 'name')->get();

        $departments->prepend([
            'id' => 'all',
            'name' => 'All Departments'
        ]);

        return response()->json([
            'status' => 'success',
            'message' => 'Departments fetched for filter.',
            'data' => $departments,
        ], 200);
    }

    /**
     * Mengembalikan data lengkap (Summary, Charts, Table) dalam satu request.
     */
    public function index(Request $request)
    {
        $filters = $this->resolveFilters($request);

        $clocks = $this->getCheckClocksCollection($filters);

        return response()->json([
            'status' => 'success',
            'message' => 'Salary report overview fetched successfully.',
            'data' => [
                'summary' => $this->summaryData($filters, $clocks),
                'charts' => [
                    'salary_by_department' => $this->salaryByDepartment($filters, $clocks),
                    'overtime_by_department' => $this->overtimeByDepartment($filters, $clocks),
                ],
                'table' => $this->salaryTable($filters, $clocks),
            ],
        ], 200);
    }

    /**
     * Endpoint BARU: Mengambil data total gaji historis 4 bulan terakhir.
     * Digunakan untuk sparkline di frontend.
     */
    public function monthlyHistory(Request $request)
    {
        $data = [];
        $today = Carbon::now();

        // Mengambil data 4 bulan terakhir (termasuk bulan saat ini)
        for ($i = 3; $i >= 0; $i--) {
            $date = $today->copy()->subMonths($i);
            $month = $date->month;
            $year = $date->year;

            $filters = ['month' => $month, 'year' => $year, 'department' => 'all'];

            // Ambil clocks, hitung total gaji
            $clocks = $this->getCheckClocksCollection($filters);
            $totals = $this->calculateTotalsFromClocks($clocks);

            $data[] = [
                'month' => $month,
                'year' => $year,
                'label' => $date->format('M'),
                'total_salary' => $totals['total_salary']
            ];
        }

        return response()->json([
            'status' => 'success',
            'message' => 'Monthly salary history fetched successfully.',
            'data' => $data,
        ], 200);
    }
    
    // --- Helper / Protected methods (Logika utama tidak berubah, hanya penamaan rate) ---

    protected function resolveFilters(Request $request): array
    {
        return [
            'month' => (int) $request->input('month', now()->month),
            'year'  => (int) $request->input('year', now()->year),
            'department' => $request->filled('department') ? $request->input('department') : 'all',
            'position' => $request->input('position', null),
            'employee_name' => $request->input('employee_name', null),
        ];
    }

    protected function getPreviousMonthFilters(array $currentFilters): array
    {
        $date = Carbon::create($currentFilters['year'], $currentFilters['month'], 1);
        $previousDate = $date->subMonth();

        $prevFilters = $currentFilters;
        $prevFilters['month'] = $previousDate->month;
        $prevFilters['year'] = $previousDate->year;

        return $prevFilters;
    }

    protected function getCheckClocksCollection(array $filters): Collection
    {
        $q = CheckClock::with(['employee.position', 'employee.department']);

        $q->whereMonth('date', $filters['month'])
          ->whereYear('date', $filters['year']);

        if ($filters['department'] !== 'all') {
            $q->whereHas('employee', function ($qq) use ($filters) {
                $qq->where('department_id', $filters['department']);
            });
        }
        if (isset($filters['position'])) {
            $q->whereHas('employee', fn($qq) => $qq->where('position_id', $filters['position']));
        }
        if (isset($filters['employee_name'])) {
            $name = $filters['employee_name'];
            $q->whereHas('employee', fn($qq) => $qq->whereRaw("CONCAT(first_name, ' ', last_name) LIKE ?", ["%{$name}%"]));
        }

        return $q->get();
    }

    protected function calculateTotalsFromClocks(Collection $clocks): array
    {
        $totalHours = 0.0;
        $totalOvertime = 0.0;
        $totalSalary = 0.0;

        foreach ($clocks as $c) {
            $regularHours = $this->calcRegularHours($c);
            $overtimeHours = $this->calcOvertimeHours($c);

            // FIX: Menggunakan rate_regular (asumsi ini nama kolom yang benar)
            $rateRegular = optional($c->employee->position)->rate_regular ?? 0;
            $rateOvertime = optional($c->employee->position)->rate_overtime ?? 0;

            $totalHours += $regularHours;
            $totalOvertime += $overtimeHours;
            $totalSalary += ($regularHours * $rateRegular) + ($overtimeHours * $rateOvertime);
        }

        return [
            'total_salary' => round($totalSalary, 2),
            'total_hours' => round($totalHours, 2),
            'total_overtime' => round($totalOvertime, 2),
            'employee_count' => $clocks->pluck('employee_id')->unique()->count(),
        ];
    }

    protected function summaryData(array $filters, Collection $currentClocks): array
    {
        $currentTotals = $this->calculateTotalsFromClocks($currentClocks);
        $totalSalary = $currentTotals['total_salary'];

        $prevFilters = $this->getPreviousMonthFilters($filters);
        $prevClocks = $this->getCheckClocksCollection($prevFilters);
        $prevTotals = $this->calculateTotalsFromClocks($prevClocks);
        $prevTotalSalary = $prevTotals['total_salary'];

        $changePercentage = 0.0;
        if ($prevTotalSalary > 0) {
            $changePercentage = (($totalSalary - $prevTotalSalary) / $prevTotalSalary) * 100;
        } elseif ($totalSalary > 0) {
            $changePercentage = 100.0;
        }

        return array_merge($currentTotals, [
            'month' => $filters['month'],
            'year'  => $filters['year'],
            'salary_change_percentage' => round($changePercentage, 1),
        ]);
    }

    protected function salaryByDepartment(array $filters, Collection $clocks): array
    {
        $departments = Department::all();
        $result = [];

        foreach ($departments as $d) {
            $departmentClocks = $clocks->filter(fn($c) => optional($c->employee)->department_id == $d->id);

            $totals = $this->calculateTotalsFromClocks($departmentClocks);

            $result[] = [
                'department' => $d->name,
                'total_salary' => $totals['total_salary'],
            ];
        }

        return $result;
    }

    protected function overtimeByDepartment(array $filters, Collection $clocks): array
    {
        $departments = Department::all();
        $result = [];

        foreach ($departments as $d) {
            $departmentClocks = $clocks->filter(fn($c) => optional($c->employee)->department_id == $d->id);

            $totals = $this->calculateTotalsFromClocks($departmentClocks);

            $result[] = [
                'department' => $d->name,
                'total_overtime' => $totals['total_overtime'],
            ];
        }

        return $result;
    }

    protected function salaryTable(array $filters, Collection $clocks, int $perPage = 15)
    {
        $employeeIds = $clocks->pluck('employee_id')->unique()->toArray();

        // Query Employee yang hadir
        $empQ = Employee::query()->whereIn('id', $employeeIds)->with(['position', 'department']);

        if ($filters['position']) {
            $empQ->where('position_id', $filters['position']);
        }
        if ($filters['employee_name']) {
            $name = $filters['employee_name'];
            $empQ->whereRaw("CONCAT(first_name, ' ', last_name) LIKE ?", ["%{$name}%"]);
        }

        $pageResult = $empQ->paginate($perPage);

        $pageResult->getCollection()->transform(function ($emp) use ($clocks) {
            $employeeClocks = $clocks->filter(fn($c) => $c->employee_id == $emp->id);

            $regular = 0.0;
            $overtime = 0.0;

            foreach ($employeeClocks as $c) {
                $regular += $this->calcRegularHours($c);
                $overtime += $this->calcOvertimeHours($c);
            }

            $rateReg = optional($emp->position)->rate_regular ?? 0;
            $rateOver = optional($emp->position)->rate_overtime ?? 0;
            $totalSalary = ($regular * $rateReg) + ($overtime * $rateOver);

            return [
                'employee_id' => $emp->id,
                'employee_name' => $emp->first_name . ' ' . $emp->last_name,
                'position' => optional($emp->position)->name,
                'department' => optional($emp->department)->name,
                'regular_hours' => round($regular, 2),
                'overtime_hours' => round($overtime, 2),
                'regular_income' => round($regular * $rateReg, 2),
                'overtime_income' => round($overtime * $rateOver, 2),
                'total_salary' => round($totalSalary, 2),
            ];
        });

        return $pageResult;
    }

    protected function calcRegularHours(CheckClock $c): float
    {
        if (!$c->clock_in || !$c->clock_out) return 0.0;
        try {
            $in = Carbon::parse($c->clock_in);
            $out = Carbon::parse($c->clock_out);
            $hours = $in->floatDiffInHours($out);
            return max(0.0, $hours);
        } catch (\Throwable $e) { return 0.0; }
    }

    protected function calcOvertimeHours(CheckClock $c): float
    {
        if (!$c->overtime_start || !$c->overtime_end) return 0.0;
        try {
            $start = Carbon::parse($c->overtime_start);
            $end = Carbon::parse($c->overtime_end);
            $hours = $start->floatDiffInHours($end);
            return max(0.0, $hours);
        } catch (\Throwable $e) { return 0.0; }
    }
}