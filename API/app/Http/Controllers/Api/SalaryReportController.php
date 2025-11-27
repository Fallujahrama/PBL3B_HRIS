<?php

namespace App\Http\Controllers;

use App\Models\CheckClock;
use App\Models\Employee;
use App\Models\Departement;
use Illuminate\Http\Request;
use Illuminate\Support\Collection;
use Carbon\Carbon;

class SalaryReportController extends Controller
{
    /**
     * Optional combined entry point (calls other methods)
     */
    public function index(Request $request)
    {
        $filters = $this->resolveFilters($request);

        return response()->json([
            'status' => 'success',
            'message' => 'Salary report overview',
            'data' => [
                'summary' => $this->summaryData($filters),
                'charts' => [
                    'salary_by_department' => $this->salaryByDepartment($filters),
                    'overtime_by_department' => $this->overtimeByDepartment($filters),
                ],
                'table' => $this->salaryTable($filters, $paginate = true),
            ],
        ], 200);
    }

    /**
     * KPI Summary (cards)
     */
    public function summary(Request $request)
    {
        $filters = $this->resolveFilters($request);

        return response()->json([
            'status' => 'success',
            'message' => 'Salary KPI summary fetched',
            'data' => $this->summaryData($filters),
        ], 200);
    }

    /**
     * Chart: total salary grouped by department
     */
    public function chartSalary(Request $request)
    {
        $filters = $this->resolveFilters($request);

        $data = $this->salaryByDepartment($filters);

        return response()->json([
            'status' => 'success',
            'message' => 'Salary by department fetched',
            'data' => $data,
        ], 200);
    }

    /**
     * Chart: overtime grouped by department (or monthly trend if requested)
     */
    public function chartOvertime(Request $request)
    {
        $filters = $this->resolveFilters($request);

        $data = $this->overtimeByDepartment($filters);

        return response()->json([
            'status' => 'success',
            'message' => 'Overtime by department fetched',
            'data' => $data,
        ], 200);
    }

    /**
     * Salary table (detailed). Supports pagination & filters.
     */
    public function table(Request $request)
    {
        $filters = $this->resolveFilters($request);
        $perPage = (int) $request->get('per_page', 15);

        $result = $this->salaryTable($filters, $paginate = true, $perPage);

        return response()->json([
            'status' => 'success',
            'message' => 'Salary table fetched',
            'data' => $result,
        ], 200);
    }

    /**
     * Export placeholder (implement Excel/PDF here)
     */
    public function export(Request $request)
    {
        // implement export logic (Maatwebsite\Excel or PDF) as needed
        $filters = $this->resolveFilters($request);

        return response()->json([
            'status' => 'success',
            'message' => 'Export endpoint placeholder. Implement Excel/PDF generation here.',
            'filters' => $filters,
        ], 200);
    }

    /* ============================
       Helper / Protected methods
       ============================ */

    /**
     * Normalize filters from request
     */
    protected function resolveFilters(Request $request): array
    {
        return [
            'month' => (int) $request->input('month', now()->month),
            'year'  => (int) $request->input('year', now()->year),
            // department accepts 'all' or department id
            'department' => $request->filled('department') ? $request->input('department') : 'all',
            'position' => $request->input('position', null),
            'employee_name' => $request->input('employee_name', null),
        ];
    }

    /**
     * Build Eloquent base query for check_clocks within filters
     * returns Collection of CheckClock models (with employee + position + departement loaded)
     */
    protected function getCheckClocksCollection(array $filters): Collection
    {
        $q = CheckClock::with(['employee.position', 'employee.departement']);

        $q->whereMonth('date', $filters['month'])
          ->whereYear('date', $filters['year']);

        if ($filters['department'] !== 'all') {
            $q->whereHas('employee', function ($qq) use ($filters) {
                $qq->where('department_id', $filters['department']);
            });
        }

        if ($filters['position']) {
            $q->whereHas('employee', function ($qq) use ($filters) {
                $qq->where('position_id', $filters['position']);
            });
        }

        if ($filters['employee_name']) {
            $name = $filters['employee_name'];
            $q->whereHas('employee', function ($qq) use ($name) {
                $qq->whereRaw("CONCAT(first_name, ' ', last_name) LIKE ?", ["%{$name}%"]);
            });
        }

        return $q->get();
    }

    /**
     * Summary data computed from check_clocks collection
     */
    protected function summaryData(array $filters): array
    {
        $clocks = $this->getCheckClocksCollection($filters);

        $totalHours = 0.0;
        $totalOvertime = 0.0;
        $totalSalary = 0.0;

        foreach ($clocks as $c) {
            $regularHours = $this->calcRegularHours($c);
            $overtimeHours = $this->calcOvertimeHours($c);

            $rateRegular = optional($c->employee->position)->rate_regular ?? 0;
            $rateOvertime = optional($c->employee->position)->rate_overtime ?? 0;

            $totalHours += $regularHours;
            $totalOvertime += $overtimeHours;
            $totalSalary += ($regularHours * $rateRegular) + ($overtimeHours * $rateOvertime);
        }

        $employeeCount = $clocks->pluck('employee_id')->unique()->count();

        return [
            'month' => $filters['month'],
            'year'  => $filters['year'],
            'total_salary' => round($totalSalary, 2),
            'total_hours'  => round($totalHours, 2),
            'total_overtime'=> round($totalOvertime, 2),
            'employee_count'=> $employeeCount,
        ];
    }

    /**
     * Salary by department (array of ['department'=>..., 'total_salary'=>...])
     */
    protected function salaryByDepartment(array $filters): array
    {
        $departments = Departement::all();

        $result = [];
        foreach ($departments as $d) {
            $filtersLocal = $filters;
            $filtersLocal['department'] = $d->id;

            $summary = $this->summaryData($filtersLocal);
            $result[] = [
                'department' => $d->name,
                'total_salary' => $summary['total_salary'],
            ];
        }

        return $result;
    }

    /**
     * Overtime by department (array of ['department'=>..., 'total_overtime'=>...])
     */
    protected function overtimeByDepartment(array $filters): array
    {
        $departments = Departement::all();

        $result = [];
        foreach ($departments as $d) {
            $filtersLocal = $filters;
            $filtersLocal['department'] = $d->id;

            $summary = $this->summaryData($filtersLocal);
            $result[] = [
                'department' => $d->name,
                'total_overtime' => $summary['total_overtime'],
            ];
        }

        return $result;
    }

    /**
     * Salary table (detailed) — returns paginated employees with computed totals
     * If $paginate = true returns Laravel paginator, otherwise returns Collection
     */
    protected function salaryTable(array $filters, bool $paginate = true, int $perPage = 15)
    {
        // base employee query (apply department/position/name filters)
        $empQ = Employee::with(['position', 'departement']);

        if ($filters['department'] !== 'all') {
            $empQ->where('department_id', $filters['department']);
        }

        if ($filters['position']) {
            $empQ->where('position_id', $filters['position']);
        }

        if ($filters['employee_name']) {
            $name = $filters['employee_name'];
            $empQ->whereRaw("CONCAT(first_name, ' ', last_name) LIKE ?", ["%{$name}%"]);
        }

        if ($paginate) {
            $pageResult = $empQ->paginate($perPage);
            // compute totals per employee on current page
            $pageResult->getCollection()->transform(function ($emp) use ($filters) {
                $clocks = $emp->checkClocks()
                    ->whereMonth('date', $filters['month'])
                    ->whereYear('date', $filters['year'])
                    ->get();

                $regular = 0.0;
                $overtime = 0.0;
                foreach ($clocks as $c) {
                    $regular += $this->calcRegularHours($c);
                    $overtime += $this->calcOvertimeHours($c);
                }

                $rateReg = $emp->position->rate_regular ?? 0;
                $rateOver = $emp->position->rate_overtime ?? 0;

                $totalSalary = ($regular * $rateReg) + ($overtime * $rateOver);

                return [
                    'employee_id' => $emp->id,
                    'employee_name' => $emp->first_name . ' ' . $emp->last_name,
                    'position' => optional($emp->position)->name,
                    'department' => optional($emp->departement)->name,
                    'regular_hours' => round($regular, 2),
                    'overtime_hours' => round($overtime, 2),
                    'regular_income' => round($regular * $rateReg, 2),
                    'overtime_income' => round($overtime * $rateOver, 2),
                    'total_salary' => round($totalSalary, 2),
                ];
            });

            return $pageResult;
        }

        // no paginate -> compute for all employees
        $emps = $empQ->get();
        return $emps->map(function ($emp) use ($filters) {
            $clocks = $emp->checkClocks()
                ->whereMonth('date', $filters['month'])
                ->whereYear('date', $filters['year'])
                ->get();

            $regular = 0.0;
            $overtime = 0.0;
            foreach ($clocks as $c) {
                $regular += $this->calcRegularHours($c);
                $overtime += $this->calcOvertimeHours($c);
            }

            $rateReg = $emp->position->rate_regular ?? 0;
            $rateOver = $emp->position->rate_overtime ?? 0;

            $totalSalary = ($regular * $rateReg) + ($overtime * $rateOver);

            return [
                'employee_id' => $emp->id,
                'employee_name' => $emp->first_name . ' ' . $emp->last_name,
                'position' => optional($emp->position)->name,
                'department' => optional($emp->departement)->name,
                'regular_hours' => round($regular, 2),
                'overtime_hours' => round($overtime, 2),
                'regular_income' => round($regular * $rateReg, 2),
                'overtime_income' => round($overtime * $rateOver, 2),
                'total_salary' => round($totalSalary, 2),
            ];
        });
    }

    /**
     * Calculate regular hours for a check_clock record (fractional hours allowed)
     */
    protected function calcRegularHours(CheckClock $c): float
    {
        if (!$c->clock_in || !$c->clock_out) return 0.0;

        try {
            $in = Carbon::parse($c->clock_in);
            $out = Carbon::parse($c->clock_out);
            $hours = $out->floatDiffInHours($in); // fractional hours
            return max(0.0, $hours);
        } catch (\Throwable $e) {
            return 0.0;
        }
    }

    /**
     * Calculate overtime hours for a check_clock record
     */
    protected function calcOvertimeHours(CheckClock $c): float
    {
        if (!$c->overtime_start || !$c->overtime_end) return 0.0;

        try {
            $start = Carbon::parse($c->overtime_start);
            $end = Carbon::parse($c->overtime_end);
            $hours = $end->floatDiffInHours($start);
            return max(0.0, $hours);
        } catch (\Throwable $e) {
            return 0.0;
        }
    }
}
