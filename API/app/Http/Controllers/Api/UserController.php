<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Absensi;
use App\Models\SalaryReport;

class UserController extends Controller
{
    public function profile(Request $request)
    {
        $user = $request->user();

        // Pastikan employee relation ada
        $employee = $user->employee;
        if (!$employee) {
            return response()->json([
                'success' => false,
                'message' => 'Employee data tidak ditemukan',
                'user_id' => $user->id,
                'email' => $user->email
            ], 404);
        }

        $today = now()->toDateString();
        $month = now()->format('Y-m');

        $absensiToday = Absensi::where('employee_id', $employee->id)
            ->whereDate('tanggal', $today)
            ->first();

        $absensiMonth = Absensi::where('employee_id', $employee->id)
            ->whereMonth('tanggal', now()->month)
            ->get();

        $salary = SalaryReport::where('employee_id', $employee->id)
            ->where('month', $month)
            ->first();

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $user->id,
                'email' => $user->email,
                'role' => $user->is_admin ? 'admin' : 'employee',
                'name' => $employee->first_name . ' ' . $employee->last_name,
                'position' => $employee->position?->name ?? null,
                'departement' => $employee->departement?->name ?? null,
                'status_today' => $absensiToday->status ?? '-',
                'jam_masuk' => $absensiToday->jam_masuk ?? '-', // ← FIX: hapus spasi
                'jam_pulang' => $absensiToday->jam_pulang ?? '-',
                'hadir_month' => $absensiMonth->where('status', 'hadir')->count(),
                'telat_month' => $absensiMonth->where('status', 'telat')->count(),
                'izin_month' => $absensiMonth->where('status', 'izin')->count(),
                'lembur_month' => $absensiMonth->where('status', 'lembur')->count(),
                'gaji_month' => $salary?->amount ?? 0,
                'gaji_status' => $salary?->status ?? 'Unpaid',
                'activity_list' => $absensiMonth->map(fn($a) => [
                    'title' => ucfirst($a->status),
                    'date' => $a->tanggal . ' ' . ($a->jam_masuk ?? '')
                ]),
            ]
        ]);
    }
}