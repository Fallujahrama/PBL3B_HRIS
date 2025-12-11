<?php

namespace App\Http\Controllers;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Absensi;

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

    $query = Absensi::where('employee_id', $employeeId);

    // Filter month (harus angka 1-12)
    if (is_numeric($month) && $month >= 1 && $month <= 12) {
        $query->whereMonth('tanggal', intval($month));
    }

    // Filter year (harus angka 4 digit)
    if (is_numeric($year) && strlen($year) == 4) {
        $query->whereYear('tanggal', intval($year));
    }

    $data = $query->orderBy('tanggal', 'asc')->get();

    return response()->json([
        'success' => true,
        'message' => 'Data absensi diambil',
        'data' => $data
    ]);
}
}
