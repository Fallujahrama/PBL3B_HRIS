<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Absensi;
use App\Models\SalaryReport;

class ProfileController extends Controller
{
    // Endpoint profile user sesuai token
    public function profile(Request $request)
    {
        $user = $request->user(); // ambil user dari token
        $employee = $user->employee;

        if (!$employee) {
            return response()->json([
                'message' => 'Employee data tidak ditemukan'
            ], 404);
        }

        $today = now()->toDateString();
        $month = now()->format('Y-m');

        // Ambil absensi hari ini (jika ada)
        $absensiToday = Absensi::where('employee_id', $employee->id)
            ->whereDate('tanggal', $today)
            ->first();

        // Ambil semua absensi bulan ini
        $absensiMonth = Absensi::where('employee_id', $employee->id)
            ->whereMonth('tanggal', now()->month)
            ->get();

        // Hitung ringkasan
        $hadirMonth = $absensiMonth->where('status', 'hadir')->count();
        $telatMonth = $absensiMonth->where('status', 'telat')->count();
        $izinMonth = $absensiMonth->where('status', 'izin')->count();
        $lemburMonth = $absensiMonth->where('status', 'lembur')->count();

        // Ambil gaji bulan ini
        $salary = SalaryReport::where('employee_id', $employee->id)
            ->where('month', $month)
            ->first();

        return response()->json([
            'id' => $user->id,
            'email' => $user->email,
            'role' => $user->is_admin ? 'admin' : 'employee',
            'name' => $employee->first_name . ' ' . $employee->last_name,
            'position' => $employee->position?->name ?? null,
            'departement' => $employee->departement?->name ?? null,
            'status_today' => $absensiToday->status ?? '-',
            'jam_masuk' => $absensiToday->jam_masuk ?? '-',
            'jam_pulang' => $absensiToday->jam_pulang ?? '-',
            'hadir_month' => $hadirMonth,
            'telat_month' => $telatMonth,
            'izin_month' => $izinMonth,
            'lembur_month' => $lemburMonth,
            'gaji_month' => $salary?->amount ?? 0,
            'gaji_status' => $salary?->status ?? 'Unpaid',
            'activity_list' => $absensiMonth->map(function($a) {
                return [
                    'title' => ucfirst($a->status),
                    'date' => $a->tanggal . ' ' . ($a->jam_masuk ?? ''),
                ];
            }),
        ]);
    }
}
