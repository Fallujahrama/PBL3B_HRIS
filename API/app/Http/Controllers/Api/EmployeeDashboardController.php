<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Employee;
use App\Models\CheckClock;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class EmployeeDashboardController extends Controller
{
    // =============================
    // DASHBOARD SUMMARY
    // =============================
    public function getDashboardSummary(Request $request)
    {
        try {
            $user = Auth::user();

            $employee = Employee::with(['position', 'department'])
                ->where('user_id', $user->id)
                ->first();

            if (!$employee) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data karyawan tidak ditemukan'
                ], 404);
            }

            $month = Carbon::now()->month;
            $year = Carbon::now()->year;

            // Hanya status hadir
            $hadir = CheckClock::where('employee_id', $employee->id)
    ->whereYear('date', $year)
    ->whereMonth('date', $month)
    ->where('status', 'hadir')
    ->count();

    
// Dinas (mengganti posisi "telat")
$dinas = CheckClock::where('employee_id', $employee->id)
    ->whereYear('date', $year)
    ->whereMonth('date', $month)
    ->where('status', 'dinas')
    ->count();

// Izin = cuti
$cuti = CheckClock::where('employee_id', $employee->id)
    ->whereYear('date', $year)
    ->whereMonth('date', $month)
    ->where('status', 'cuti')
    ->count();

// Sakit
$sakit = CheckClock::where('employee_id', $employee->id)
    ->whereYear('date', $year)
    ->whereMonth('date', $month)
    ->where('status', 'sakit')
    ->count();

            // Hitung lembur
            $monthlyOvertime = $this->calculateMonthlyOvertime($employee->id, $year, $month);

            return response()->json([
                'success' => true,
                'message' => 'Data dashboard berhasil diambil',
                'data' => [
                    'employee' => [
                        'id'        => $employee->id,
                        'name'      => trim($employee->first_name . ' ' . $employee->last_name),
                        'email'     => $user->email,
                        'position'  => $employee->position->name ?? '-',
                        'department'=> $employee->department->name ?? '-',
                    ],
                    'monthly_attendance' => $hadir ,
                    'monthly_dinas'      => $dinas,
                    'monthly_cuti'       => $cuti,
                    'monthly_sakit'      => $sakit,
                    'monthly_overtime'   => $monthlyOvertime,
                ],
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data dashboard',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    // =============================
    // WEEKLY CHART
    // =============================
    public function getWeeklyAttendance(Request $request)
    {
        try {
            $user = Auth::user();
            $employee = Employee::where('user_id', $user->id)->first();

            if (!$employee) {
                return response()->json(['success' => false, 'message' => 'Data karyawan tidak ditemukan'], 404);
            }

            $start = Carbon::now()->subDays(6)->startOfDay();
            $end   = Carbon::now()->endOfDay();

            $records = CheckClock::where('employee_id', $employee->id)
                ->whereBetween('date', [$start, $end])
                ->orderBy('date')
                ->get()
                ->keyBy(fn($r) => Carbon::parse($r->date)->format('Y-m-d'));

            $chart = [];

            for ($i = 6; $i >= 0; $i--) {
                $day = Carbon::now()->subDays($i);
                $key = $day->format('Y-m-d');

                $rec = $records->get($key);

                $value = 0;
                $status = 'alpha';
                $clockIn = null;
                $clockOut = null;

                if ($rec) {
                    $status = $rec->status;
                    $clockIn = $rec->clock_in;
                    $clockOut = $rec->clock_out;

                    if ($rec->status === 'hadir') {
                        $value = 1;
                    }
                }

                $chart[] = [
                    'date'      => $key,
                    'day'       => $day->locale('id')->isoFormat('ddd'),
                    'value'     => $value,
                    'status'    => $status,
                    'clock_in'  => $clockIn,
                    'clock_out' => $clockOut,
                ];
            }

            return response()->json([
                'success' => true,
                'message' => 'Data kehadiran mingguan berhasil diambil',
                'data' => $chart,
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data kehadiran',
                'error' => $e->getMessage(),
            ], 500);
        }
    }

    // =============================
    // ABSENSI HISTORY
    // =============================
    public function getAttendanceHistory(Request $request)
    {
        try {
            $user = Auth::user();
            $employee = Employee::where('user_id', $user->id)->first();

            if (!$employee) {
                return response()->json(['success' => false, 'message' => 'Data karyawan tidak ditemukan'], 404);
            }

            $month = $request->input('month', Carbon::now()->month);
            $year  = $request->input('year', Carbon::now()->year);
            $perPage = $request->input('per_page', 31);

            $list = CheckClock::where('employee_id', $employee->id)
                ->whereYear('date', $year)
                ->whereMonth('date', $month)
                ->orderBy('date', 'desc')
                ->paginate($perPage);

            $formatted = $list->map(function ($c) {
                return [
                    'id'            => $c->id,
                    'date'          => $c->date,
                    'date_formatted'=> Carbon::parse($c->date)->locale('id')->isoFormat('dddd, D MMMM YYYY'),
                    'status'        => $c->status,
                    'clock_in'      => $c->clock_in,
                    'clock_out'     => $c->clock_out,
                ];
            });

            // Summary
            $summary = CheckClock::where('employee_id', $employee->id)
                ->whereYear('date', $year)
                ->whereMonth('date', $month)
                ->select('status', DB::raw('COUNT(*) as total'))
                ->groupBy('status')
                ->pluck('total', 'status');

            return response()->json([
                'success' => true,
                'message' => 'Data riwayat absensi berhasil diambil',
                'data' => $formatted,
                'summary' => [
                    'hadir' => $summary['hadir'] ?? 0,
                    'sakit' => $summary['sakit'] ?? 0,
                    'dinas' => $summary['dinas'] ?? 0,
                    'cuti'  => $summary['cuti'] ?? 0,
                ],
                'pagination' => [
                    'current_page' => $list->currentPage(),
                    'last_page'    => $list->lastPage(),
                    'per_page'     => $list->perPage(),
                    'total'        => $list->total(),
                ],
            ]);

        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Error', 'error' => $e->getMessage()], 500);
        }
    }

    // =============================
    // OVERTIME HISTORY
    // =============================
    public function getOvertimeHistory(Request $request)
    {
        try {
            $user = Auth::user();
            $employee = Employee::where('user_id', $user->id)->first();

            if (!$employee) {
                return response()->json(['success' => false, 'message' => 'Data karyawan tidak ditemukan'], 404);
            }

            $month = $request->month ?? Carbon::now()->month;
            $year  = $request->year ?? Carbon::now()->year;

            $records = CheckClock::where('employee_id', $employee->id)
                ->whereYear('date', $year)
                ->whereMonth('date', $month)
                ->orderBy('date', 'desc')
                ->get();

            $result = [];

            foreach ($records as $r) {
                $hours = $this->calculateOvertimeHours($r);
                if ($hours > 0) {
                    $result[] = [
                        'id'        => $r->id,
                        'date'      => $r->date,
                        'clock_out' => $r->clock_out,
                        'hours'     => $hours . 'h',
                        'hours_value' => $hours,
                    ];
                }
            }

            return response()->json([
                'success' => true,
                'message' => 'Data lembur berhasil diambil',
                'data' => $result,
            ]);

        } catch (\Exception $e) {
            return response()->json(['success' => false, 'message' => 'Error', 'error' => $e->getMessage()], 500);
        }
    }
     public function getProfile(Request $request)
    {
        try {
            $user = Auth::user();
            $employee = Employee::with(['position', 'department'])
                ->where('user_id', $user->id)
                ->first();
            
            if (!$employee) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data karyawan tidak ditemukan'
                ], 404);
            }

            return response()->json([
                'success' => true,
                'message' => 'Data profil berhasil diambil',
                'data' => [
                    'id' => $employee->id,
                    'user_id' => $user->id,
                    'first_name' => $employee->first_name,
                    'last_name' => $employee->last_name,
                    'full_name' => trim($employee->first_name . ' ' . $employee->last_name),
                    'email' => $user->email,
                    'gender' => $employee->gender,
                    'address' => $employee->address,
                    'position' => [
                        'id' => $employee->position_id,
                        'name' => $employee->position->name ?? '-',
                    ],
                    'department' => [
                        'id' => $employee->department_id,
                        'name' => $employee->department->name ?? '-',
                    ],
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data profil',
                'error' => $e->getMessage()
            ], 500);
        }
    }
    // =============================
    // HELPER
    // =============================
    private function calculateOvertimeHours($rec)
    {
        // Jika lembur berdasarkan tipe
        if ($rec->check_clock_type == 1 && $rec->overtime_start && $rec->overtime_end) {
            $start = Carbon::parse($rec->overtime_start);
            $end   = Carbon::parse($rec->overtime_end);
            return round($end->diffInMinutes($start) / 60, 1);
        }

        // Jika pulang lebih dari jam 16:00
        if ($rec->clock_out > '16:00:00') {
            $cutoff = Carbon::createFromTime(16, 0);
            $out    = Carbon::parse($rec->clock_out);
            return round($out->diffInMinutes($cutoff) / 60, 1);
        }

        return 0;
    }

    private function calculateMonthlyOvertime($employeeId, $year, $month)
    {
        $records = CheckClock::where('employee_id', $employeeId)
            ->whereYear('date', $year)
            ->whereMonth('date', $month)
            ->where('check_clock_type', 1)
            ->count();

        return $records;
    }
}
