<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\CheckClock;
use Carbon\Carbon;
use Illuminate\Support\Facades\Log;

class SalaryController extends Controller
{
    public function getSalarySlip(Request $request)
    {
        try {
            $user = $request->user();
            
            // Load relasi
            $employee = $user->employee; 

            if (!$employee) {
                return response()->json(['error' => 'Data Karyawan tidak ditemukan'], 404);
            }

            // Load position & departement dengan safe loading
            $employee->load(['position', 'department']);

            // --- 1. Filter Waktu ---
            $month = $request->input('month', now()->month);
            $year = $request->input('year', now()->year);

            // --- 2. Ambil Rate (HANYA REGULER & OVERTIME) ---
            $position = $employee->position;
            
            if (!$position) {
                $rateReguler = 0;
                $rateOvertime = 0;
                $positionName = 'Tanpa Jabatan';
            } else {
                // HANYA AMBIL 2 KOMPONEN INI
                $rateReguler = $position->rate_reguler ?? 0;
                $rateOvertime = $position->rate_overtime ?? 0;
                $positionName = $position->name;
            }

            // --- 3. Ambil Data Absensi ---
            $attendanceData = CheckClock::where('employee_id', $employee->id)
                ->whereMonth('date', $month)
                ->whereYear('date', $year)
                ->get();

            // --- 4. Hitung Hari Kerja (Untuk Rate Reguler) ---
            $workDays = $attendanceData
                ->whereIn('status', ['hadir', 'dinas'])
                ->where('check_clock_type', 0) // 0 = Reguler
                ->groupBy(function($date) {
                    return Carbon::parse($date->date)->format('Y-m-d');
                })
                ->count();

            // --- 5. Hitung Jam Lembur (Untuk Rate Overtime) ---
            $overtimeRecords = $attendanceData->where('check_clock_type', 1); // 1 = Lembur
            $overtimeHours = 0;

            foreach ($overtimeRecords as $ot) {
                if ($ot->clock_in && $ot->clock_out) {
                    try {
                        $start = Carbon::parse($ot->clock_in);
                        $end = Carbon::parse($ot->clock_out);
                        $overtimeHours += abs($end->floatDiffInHours($start));
                    } catch (\Exception $e) {
                        continue;
                    }
                }
            }
            $overtimeHours = round($overtimeHours, 2);

            // --- 6. Kalkulasi Total (HANYA 2 KOMPONEN) ---
            $totalAttendancePay = $workDays * $rateReguler;
            $totalOvertimePay = $overtimeHours * $rateOvertime;
            
            // Grand Total
            $grandTotal = $totalAttendancePay + $totalOvertimePay;

            // Handle Departement Name
            $deptName = $employee->department ? $employee->department->name : '-';

            return response()->json([
                'status' => 'success',
                'period' => Carbon::create($year, $month)->translatedFormat('F Y'),
                'employee' => [
                    'name' => trim($employee->first_name . ' ' . $employee->last_name),
                    'position' => $positionName,
                    'department' => $deptName,
                ],
                'details' => [
                    // Komponen 1: Reguler
                    'work_days' => (int) $workDays,
                    'rate_reguler' => (int) $rateReguler,
                    'total_attendance_pay' => (int) $totalAttendancePay,
                    
                    // Komponen 2: Lembur
                    'overtime_hours' => $overtimeHours,
                    'rate_overtime' => (int) $rateOvertime,
                    'total_overtime_pay' => (int) $totalOvertimePay,
                    
                    // Total Bersih
                    'grand_total' => (int) $grandTotal,
                ]
            ]);

        } catch (\Throwable $e) {
            return response()->json([
                'status' => 'error',
                'message' => $e->getMessage(),
                'line' => $e->getLine()
            ], 500);
        }
    }
}