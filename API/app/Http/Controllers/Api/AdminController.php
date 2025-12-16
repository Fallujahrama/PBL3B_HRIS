<?php

namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\Employee;
use App\Models\CheckClock;
use Carbon\Carbon;
use Illuminate\Http\Request;

class AdminController extends Controller
{
    public function stats(Request $request)
    {
        // ========================
        // BASIC STATS
        // ========================
        $totalEmployees = Employee::count();

        // ========================
        // FILTER BULAN & TAHUN
        // ========================
        $month = (int) $request->query('month', Carbon::now()->month);
        $year  = Carbon::now()->year;

        // ========================
        // AMBIL DATA CHECK CLOCK
        // ========================
        $checkClocks = CheckClock::whereYear('date', $year)
            ->whereMonth('date', $month)
            ->get();

        // ========================
        // HITUNG STATUS
        // ========================
        $hadir = $checkClocks->whereIn('status', ['hadir', 'dinas'])->count();
        $izin  = $checkClocks->where('status', 'cuti')->count();
        $alpha = $checkClocks->where('status', 'sakit')->count();
        $telat = 0; // Tidak ada kolom telat di check_clocks

        return response()->json([
            'success' => true,
            'data' => [
                'total_employees' => $totalEmployees,
                'month' => $month,
                'absensi_bulanan' => [
                    'hadir' => $hadir,
                    'izin'  => $izin,
                    'telat' => $telat,
                    'alpha' => $alpha,
                ],
            ]
        ]);
    }
}
