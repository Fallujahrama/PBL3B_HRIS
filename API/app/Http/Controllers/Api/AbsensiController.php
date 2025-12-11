<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\CheckClock; // Gunakan Model CheckClock

class AbsensiController extends Controller
{
    public function report(Request $request)
    {
        $user = $request->user();

        if (!$user || !$user->employee) {
            return response()->json(['error' => 'Employee tidak ditemukan'], 404);
        }

        $employeeId = $user->employee->id;

        // Ambil parameter
        $month = $request->input('month');
        $year  = $request->input('year');

        // Query menggunakan Model CheckClock
        $query = CheckClock::where('employee_id', $employeeId);

        // Filter month (Gunakan kolom 'date' sesuai migration)
        if (is_numeric($month) && $month >= 1 && $month <= 12) {
            $query->whereMonth('date', intval($month));
        }

        // Filter year (Gunakan kolom 'date' sesuai migration)
        if (is_numeric($year) && strlen($year) == 4) {
            $query->whereYear('date', intval($year));
        }

        // Order by 'date'
        $data = $query->orderBy('date', 'asc')->get();

        return response()->json([
            'success' => true,
            'message' => 'Data absensi berhasil diambil',
            'data' => $data
        ]);
    }
}
