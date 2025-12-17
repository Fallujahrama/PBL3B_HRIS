<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Schedule;
use App\Services\HolidaySyncService;
use Carbon\Carbon;

class ScheduleController extends Controller
{
    public function index(Request $request)
    {
        $year = (int) $request->query('year', now()->year);

        // Query berdasarkan kolom date
        $schedules = Schedule::whereYear('date', $year)
            ->orderBy('date')
            ->get(['id', 'date', 'name']);

        return response()->json($schedules);
    }

    public function sync(Request $req, HolidaySyncService $sync)
    {
        $year = (int)($req->input('year') ?? now()->year);
        $count = $sync->syncYear($year);
        return response()->json(['year' => $year, 'synced' => $count]);
    }

    public function byMonth(Request $request, $month)
    {
        $year = (int)($request->query('year') ?? now()->year);

        $schedules = Schedule::whereYear('date', $year)
            ->whereMonth('date', $month)
            ->orderBy('date')
            ->get(['id', 'date', 'name']);

        return response()->json($schedules);
    }

    public function store(Request $request)
    {
        $validated = $request->validate([
            'date' => 'required|date',
            'name' => 'required|string|max:255',
        ]);

        $schedule = Schedule::create([
            'date' => $validated['date'],
            'name' => $validated['name'],
        ]);

        return response()->json([
            'message' => 'Schedule berhasil ditambahkan',
            'schedule' => $schedule
        ], 201);
    }

    public function destroy($id)
    {
        $schedule = Schedule::findOrFail($id);
        $schedule->delete();

        return response()->json([
            'message' => 'Schedule berhasil dihapus'
        ]);
    }

    public function isHoliday($date)
    {
        $isHoliday = Schedule::isHoliday($date);
        return response()->json(['date' => $date, 'is_holiday' => $isHoliday]);
    }
}
