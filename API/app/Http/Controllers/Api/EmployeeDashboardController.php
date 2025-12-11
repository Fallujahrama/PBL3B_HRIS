<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Employee;
use App\Models\Absensi;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class EmployeeDashboardController extends Controller
{
    // ===========================================
    // DASHBOARD SUMMARY
    // ===========================================
    public function getDashboardSummary(Request $request)
    {
        try {
            $user = Auth::user();
            
            // Ambil data employee dengan relasi
            $employee = Employee::with(['position', 'department'])
                ->where('user_id', $user->id)
                ->first();
            
            if (!$employee) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data karyawan tidak ditemukan'
                ], 404);
            }

            // Hitung bulan ini
            $currentMonth = Carbon::now()->month;
            $currentYear = Carbon::now()->year;

            // Kehadiran bulanan (jumlah hari hadir)
            $monthlyAttendance = Absensi::where('employee_id', $employee->id)
                ->whereYear('tanggal', $currentYear)
                ->whereMonth('tanggal', $currentMonth)
                ->whereIn('status', ['hadir', 'present', 'H'])
                ->count();

            // Hitung total jam lembur bulanan (dari jam_pulang > 16:00)
            $monthlyOvertimeHours = $this->calculateMonthlyOvertime($employee->id, $currentYear, $currentMonth);

            return response()->json([
                'success' => true,
                'message' => 'Data dashboard berhasil diambil',
                'data' => [
                    'employee' => [
                        'id' => $employee->id,
                        'name' => trim($employee->first_name . ' ' . $employee->last_name),
                        'email' => $user->email,
                        'position' => $employee->position->name ?? '-',
                        'department' => $employee->department->name ?? '-',
                    ],
                    'monthly_attendance' => $monthlyAttendance,
                    'monthly_overtime' => $monthlyOvertimeHours,
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data dashboard',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // ===========================================
    // GRAFIK KEHADIRAN MINGGUAN
    // ===========================================
    public function getWeeklyAttendance(Request $request)
    {
        try {
            $user = Auth::user();
            $employee = Employee::where('user_id', $user->id)->first();
            
            if (!$employee) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data karyawan tidak ditemukan'
                ], 404);
            }

            // 7 hari terakhir
            $startDate = Carbon::now()->subDays(6)->startOfDay();
            $endDate = Carbon::now()->endOfDay();

            // Ambil data absensi
            $absensiList = Absensi::where('employee_id', $employee->id)
                ->whereBetween('tanggal', [$startDate, $endDate])
                ->orderBy('tanggal', 'asc')
                ->get()
                ->keyBy(function ($item) {
                    return Carbon::parse($item->tanggal)->format('Y-m-d');
                });

            // Format data untuk chart (7 hari)
            $chartData = [];
            for ($i = 6; $i >= 0; $i--) {
                $date = Carbon::now()->subDays($i);
                $dateStr = $date->format('Y-m-d');
                $dayName = $date->locale('id')->isoFormat('ddd');
                
                $absensi = $absensiList->get($dateStr);
                
                // 1 = hadir, 0 = tidak hadir/izin/alpha
                $value = 0;
                $status = 'alpha';
                
                if ($absensi) {
                    $status = $absensi->status;
                    if (in_array(strtolower($absensi->status), ['hadir', 'present', 'h'])) {
                        $value = 1;
                    }
                }

                $chartData[] = [
                    'date' => $dateStr,
                    'day' => $dayName,
                    'value' => $value,
                    'status' => $status,
                    'jam_masuk' => $absensi->jam_masuk ?? null,
                    'jam_pulang' => $absensi->jam_pulang ?? null,
                ];
            }

            return response()->json([
                'success' => true,
                'message' => 'Data kehadiran mingguan berhasil diambil',
                'data' => $chartData
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data kehadiran',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // ===========================================
    // RIWAYAT ABSENSI
    // ===========================================
    public function getAttendanceHistory(Request $request)
    {
        try {
            $user = Auth::user();
            $employee = Employee::where('user_id', $user->id)->first();
            
            if (!$employee) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data karyawan tidak ditemukan'
                ], 404);
            }

            // Parameter filter
            $month = $request->input('month', Carbon::now()->month);
            $year = $request->input('year', Carbon::now()->year);
            $perPage = $request->input('per_page', 31);

            // Query riwayat absensi
            $query = Absensi::where('employee_id', $employee->id)
                ->whereYear('tanggal', $year)
                ->whereMonth('tanggal', $month)
                ->orderBy('tanggal', 'desc');

            $absensiList = $query->paginate($perPage);

            // Format data
            $formattedData = $absensiList->map(function ($absensi) {
                return [
                    'id' => $absensi->id,
                    'tanggal' => $absensi->tanggal,
                    'tanggal_formatted' => Carbon::parse($absensi->tanggal)->locale('id')->isoFormat('dddd, D MMMM YYYY'),
                    'status' => $absensi->status,
                    'jam_masuk' => $absensi->jam_masuk,
                    'jam_pulang' => $absensi->jam_pulang,
                ];
            });

            // Hitung ringkasan
            $summary = Absensi::where('employee_id', $employee->id)
                ->whereYear('tanggal', $year)
                ->whereMonth('tanggal', $month)
                ->select('status', DB::raw('count(*) as total'))
                ->groupBy('status')
                ->pluck('total', 'status');

            return response()->json([
                'success' => true,
                'message' => 'Data riwayat absensi berhasil diambil',
                'data' => $formattedData,
                'summary' => [
                    'hadir' => $summary['hadir'] ?? $summary['H'] ?? 0,
                    'izin' => $summary['izin'] ?? $summary['I'] ?? 0,
                    'sakit' => $summary['sakit'] ?? $summary['S'] ?? 0,
                    'alpha' => $summary['alpha'] ?? $summary['A'] ?? 0,
                ],
                'pagination' => [
                    'current_page' => $absensiList->currentPage(),
                    'last_page' => $absensiList->lastPage(),
                    'per_page' => $absensiList->perPage(),
                    'total' => $absensiList->total(),
                ],
                'filter' => [
                    'month' => (int)$month,
                    'year' => (int)$year,
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data absensi',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // ===========================================
    // RIWAYAT LEMBUR (dari jam_pulang > 16:00)
    // ===========================================
    public function getOvertimeHistory(Request $request)
    {
        try {
            $user = Auth::user();
            $employee = Employee::where('user_id', $user->id)->first();
            
            if (!$employee) {
                return response()->json([
                    'success' => false,
                    'message' => 'Data karyawan tidak ditemukan'
                ], 404);
            }

            // Ambil parameter
            $perPage = $request->input('per_page', 10);
            $month = $request->input('month', Carbon::now()->month);
            $year = $request->input('year', Carbon::now()->year);

            // Query absensi yang ada lembur (jam_pulang > 16:00)
            $query = Absensi::where('employee_id', $employee->id)
                ->whereNotNull('jam_pulang')
                ->whereYear('tanggal', $year)
                ->whereMonth('tanggal', $month)
                ->orderBy('tanggal', 'desc');

            $absensiList = $query->paginate($perPage);

            // Filter dan format data yang benar-benar lembur
            $overtimeData = [];
            foreach ($absensiList as $absensi) {
                $overtimeHours = $this->calculateOvertimeHours($absensi->jam_pulang);
                
                if ($overtimeHours > 0) {
                    $overtimeData[] = [
                        'id' => $absensi->id,
                        'date' => $absensi->tanggal,
                        'jam_pulang' => $absensi->jam_pulang,
                        'hours' => $overtimeHours . 'h',
                        'hours_value' => $overtimeHours,
                        'description' => 'Pulang jam ' . $absensi->jam_pulang,
                    ];
                }
            }

            return response()->json([
                'success' => true,
                'message' => 'Data riwayat lembur berhasil diambil',
                'data' => $overtimeData,
                'pagination' => [
                    'current_page' => $absensiList->currentPage(),
                    'last_page' => $absensiList->lastPage(),
                    'per_page' => $absensiList->perPage(),
                    'total' => count($overtimeData),
                ]
            ], 200);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data lembur',
                'error' => $e->getMessage()
            ], 500);
        }
    }

    // ===========================================
    // PROFIL KARYAWAN
    // ===========================================
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

    // ===========================================
    // HELPER METHODS
    // ===========================================
    
    /**
     * Hitung jam lembur dari jam pulang
     * Jika pulang > 16:00, selisihnya adalah lembur
     */
    private function calculateOvertimeHours($jamPulang)
    {
        if (!$jamPulang) return 0;

        try {
            // Parse jam pulang
            $checkout = Carbon::createFromFormat('H:i:s', $jamPulang);
            $cutoffTime = Carbon::createFromFormat('H:i:s', '16:00:00');

            // Kalau pulang setelah jam 4 sore
            if ($checkout->greaterThan($cutoffTime)) {
                $diffInMinutes = $checkout->diffInMinutes($cutoffTime);
                return round($diffInMinutes / 60, 1); // Konversi ke jam (1 desimal)
            }

            return 0;
        } catch (\Exception $e) {
            return 0;
        }
    }

    /**
     * Hitung total jam lembur dalam sebulan
     */
    private function calculateMonthlyOvertime($employeeId, $year, $month)
    {
        $absensiList = Absensi::where('employee_id', $employeeId)
            ->whereYear('tanggal', $year)
            ->whereMonth('tanggal', $month)
            ->whereNotNull('jam_pulang')
            ->get();

        $totalOvertime = 0;
        foreach ($absensiList as $absensi) {
            $totalOvertime += $this->calculateOvertimeHours($absensi->jam_pulang);
        }

        return round($totalOvertime, 1);
    }
}