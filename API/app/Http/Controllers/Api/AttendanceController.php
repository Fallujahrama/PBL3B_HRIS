<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Employee;
use App\Models\CheckClock;
use Carbon\Carbon;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Validator;

class AttendanceController extends Controller
{
    /**
     * Submit attendance (clock_in / clock_out / overtime_start / overtime_end)
     */
    public function store(Request $request)
    {
        // FIX: Change format from Y-m-d\TH:i:s to Y-m-d H:i:s (space instead of T)
        $validator = Validator::make($request->all(), [
            'employee_id' => 'required|exists:employees,id',
            'time' => 'required|date_format:Y-m-d H:i:s',
            // DB kolom lat/long bertipe VARCHAR, jadi jangan pakai rule numeric.
            // Kita parse manual supaya format "106,8123" atau "106.8123" tetap diterima.
            'latitude' => 'required',
            'longitude' => 'required',
            'check_type' => 'required|in:clock_in,clock_out,overtime_start,overtime_end',
        ]);

        if ($validator->fails()) {
            return $this->error($validator->errors()->first(), 422);
        }

        $validated = $validator->validated();

        // Parse koordinat ke float (mendukung string / angka / koma)
        $userLat = $this->parseCoordinate($validated['latitude']);
        $userLng = $this->parseCoordinate($validated['longitude']);

        if (is_null($userLat) || is_null($userLng)) {
            return $this->error('Format koordinat tidak valid!', 422);
        }
        $employee = Employee::with('department')->find($validated['employee_id']);

        if (!$employee || !$employee->department) {
            return $this->error('Karyawan atau departemen tidak ditemukan!', 400);
        }

        $department = $employee->department;

        // Validasi lokasi - cek apakah ada koordinat departemen
        // Ini HANYA mengecek jarak, tidak menyimpan koordinat user ke DB
        $deptLat = $this->parseCoordinate($department->latitude);
        $deptLng = $this->parseCoordinate($department->longitude);

        if (!is_null($deptLat) && !is_null($deptLng)) {
            $distance = $this->calculateDistance(
                $userLat,
                $userLng,
                $deptLat,
                $deptLng
            );

            $radius = $department->radius ?? 0.5;
            if ($distance > $radius) {
                return $this->error("Anda berada di luar area departemen {$department->name}! Jarak: {$distance}km", 400);
            }
        }

        $today = Carbon::parse($validated['time'])->format('Y-m-d');
        $checkType = $validated['check_type'];
        $time = $validated['time'];

        // Cari record untuk hari ini
        $existing = CheckClock::where('employee_id', $validated['employee_id'])
            ->whereDate('date', $today)
            ->first();

        try {
            // Logika berdasarkan tipe punch
            switch ($checkType) {
                case 'clock_in':
                    return $this->handleClockIn($validated, $existing, $today, $time);

                case 'clock_out':
                    return $this->handleClockOut($validated, $existing, $time);

                case 'overtime_start':
                    return $this->handleOvertimeStart($validated, $existing, $time);

                case 'overtime_end':
                    return $this->handleOvertimeEnd($validated, $existing, $time);

                default:
                    return $this->error('Tipe absensi tidak valid!', 400);
            }
        } catch (\Exception $e) {
            return $this->error('Error: ' . $e->getMessage(), 500);
        }
    }

    /**
     * Handle Clock In
     */
    private function handleClockIn($validated, $existing, $today, $time)
    {
        // Validasi: tidak boleh clock in 2x
        if ($existing && $existing->clock_in) {
            return $this->error('Anda sudah clock in hari ini!', 400);
        }

        $checkClock = $existing ?? new CheckClock();
        $checkClock->employee_id = $validated['employee_id'];
        $checkClock->date = $today;

        // FIX: Konversi string ke TINYINT ID
        $checkClock->check_clock_type = $this->getCheckTypeId($validated['check_type']);

        // Extract hanya waktu (HH:MM:SS) dari datetime (Y-m-d H:i:s)
        $checkClock->clock_in = $this->extractTime($time);
        
        // HAPUS SIMPAN LAT/LONG
        // $checkClock->latitude = $validated['latitude'];
        // $checkClock->longitude = $validated['longitude'];

        $checkClock->save();

        return $this->success($checkClock, 'Absen masuk berhasil!', 200);
    }

    /**
     * Handle Clock Out
     */
    private function handleClockOut($validated, $existing, $time)
    {
        // Validasi: harus sudah clock in
        if (!$existing || !$existing->clock_in) {
            return $this->error('Anda belum clock in hari ini!', 400);
        }

        // Validasi: tidak boleh clock out 2x
        if ($existing->clock_out) {
            return $this->error('Anda sudah clock out hari ini!', 400);
        }

        // Extract hanya waktu (HH:MM:SS) dari datetime (Y-m-d H:i:s)
        $existing->clock_out = $this->extractTime($time);
        
        // HAPUS SIMPAN LAT/LONG
        // $existing->latitude = $validated['latitude'];
        // $existing->longitude = $validated['longitude'];

        // FIX: Konversi string ke TINYINT ID
        $existing->check_clock_type = $this->getCheckTypeId($validated['check_type']);

        $existing->save();

        return $this->success($existing, 'Absen keluar berhasil!', 200);
    }

    /**
     * Handle Overtime Start
     */
    private function handleOvertimeStart($validated, $existing, $time)
    {
        // Validasi: harus sudah clock in dan clock out
        if (!$existing || !$existing->clock_in || !$existing->clock_out) {
            return $this->error('Anda harus clock in dan clock out terlebih dahulu!', 400);
        }

        // Validasi: overtime tidak boleh dimulai 2x
        if ($existing->overtime_start) {
            return $this->error('Overtime sudah dimulai hari ini!', 400);
        }

        // Extract hanya waktu (HH:MM:SS) dari datetime (Y-m-d H:i:s)
        $existing->overtime_start = $this->extractTime($time);
        
        // HAPUS SIMPAN LAT/LONG
        // $existing->latitude = $validated['latitude'];
        // $existing->longitude = $validated['longitude'];

        // FIX: Konversi string ke TINYINT ID
        $existing->check_clock_type = $this->getCheckTypeId($validated['check_type']);

        $existing->save();

        return $this->success($existing, 'Overtime mulai berhasil!', 200);
    }

    /**
     * Handle Overtime End
     */
    private function handleOvertimeEnd($validated, $existing, $time)
    {
        // Validasi: harus sudah overtime start
        if (!$existing || !$existing->overtime_start) {
            return $this->error('Anda belum memulai overtime!', 400);
        }

        // Validasi: overtime tidak boleh diakhiri 2x
        if ($existing->overtime_end) {
            return $this->error('Overtime sudah diakhiri hari ini!', 400);
        }

        // Extract hanya waktu (HH:MM:SS) dari datetime (Y-m-d H:i:s)
        $existing->overtime_end = $this->extractTime($time);
        
        // HAPUS SIMPAN LAT/LONG
        // $existing->latitude = $validated['latitude'];
        // $existing->longitude = $validated['longitude'];

        // FIX: Konversi string ke TINYINT ID
        $existing->check_clock_type = $this->getCheckTypeId($validated['check_type']);

        $existing->save();

        return $this->success($existing, 'Overtime selesai berhasil!', 200);
    }

    // --- FUNGSI KRITIS UNTUK KONVERSI STRING KE ID TINYINT ---
    /**
     * Converts check type string (e.g., 'clock_in') to its corresponding TINYINT ID.
     * @return int
     */
    private function getCheckTypeId(string $checkType): int
    {
        // Asumsi mapping ID TINYINT: 1: clock_in, 2: clock_out, 3: overtime_start, 4: overtime_end
        switch ($checkType) {
            case 'clock_in':
                return 1;
            case 'clock_out':
                return 2;
            case 'overtime_start':
                return 3;
            case 'overtime_end':
                return 4;
            default:
                throw new \InvalidArgumentException("Tipe absensi '{$checkType}' tidak valid untuk konversi ID.");
        }
    }
    // --- AKHIR FUNGSI KRITIS ---

    /**
     * Get Department Location untuk Frontend
     */
    public function getDepartmentLocation($employeeId)
    {
        try {
            $employee = Employee::with('department')->find($employeeId);

            if (!$employee || !$employee->department) {
                return $this->error('Karyawan atau departemen tidak ditemukan!', 404);
            }

            $department = $employee->department;
            $deptLat = $this->parseCoordinate($department->latitude) ?? 0.0;
            $deptLng = $this->parseCoordinate($department->longitude) ?? 0.0;
            $deptRadius = $this->parseCoordinate($department->radius) ?? 0.5;

            return $this->success([
                'id' => $department->id,
                'name' => $department->name,
                'latitude' => $deptLat,
                'longitude' => $deptLng,
                'radius' => $deptRadius,
            ], 'Department location retrieved successfully', 200);
        } catch (\Exception $e) {
            return $this->error('Error: ' . $e->getMessage(), 500);
        }
    }

    /**
     * Get Attendance History untuk Frontend
     */
    public function getHistory($employeeId)
    {
        try {
            $history = CheckClock::where('employee_id', $employeeId)
                ->orderBy('date', 'DESC')
                ->get()
                ->map(function ($record) {
                    return [
                        'id' => $record->id,
                        'date' => $record->date,
                        'clock_in' => $record->clock_in,
                        'clock_out' => $record->clock_out,
                        'overtime_start' => $record->overtime_start,
                        'overtime_end' => $record->overtime_end,
                    ];
                });

            return $this->success($history, 'Attendance history retrieved successfully', 200);
        } catch (\Exception $e) {
            return $this->error('Error: ' . $e->getMessage(), 500);
        }
    }

    /**
     * Extract time (HH:MM:SS) from datetime string
     * * Input:  2025-12-05 16:30:00
     * Output: 16:30:00
     */
    private function extractTime($datetime)
    {
        try {
            $dt = Carbon::parse($datetime);
            return $dt->format('H:i:s');
        } catch (\Exception $e) {
            throw new \Exception('Error parsing time: ' . $e->getMessage());
        }
    }

    /**
     * Calculate distance between two coordinates using Haversine formula
     * @return distance in kilometers
     */
    private function calculateDistance($lat1, $lng1, $lat2, $lng2)
    {
        $earthRadius = 6371; // Radius in KM
        $dLat = deg2rad($lat2 - $lat1);
        $dLng = deg2rad($lng2 - $lng1);

        $a = sin($dLat / 2) * sin($dLat / 2) +
            cos(deg2rad($lat1)) * cos(deg2rad($lat2)) *
            sin($dLng / 2) * sin($dLng / 2);

        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
        $distance = $earthRadius * $c;

        return round($distance, 2);
    }

    /**
     * Parse koordinat dari string/angka (mendukung koma sebagai pemisah desimal).
     * Return float|null bila gagal.
     */
    private function parseCoordinate($value): ?float
    {
        if (is_null($value)) {
            return null;
        }

        // Jika sudah numeric (int/double), langsung kembalikan sebagai float
        if (is_numeric($value)) {
            return floatval($value);
        }

        if (is_string($value)) {
            // Hilangkan spasi, ganti koma jadi titik
            $cleaned = str_replace(',', '.', trim($value));
            if (is_numeric($cleaned)) {
                return floatval($cleaned);
            }
        }

        return null;
    }

    /**
     * Success response helper
     */
    protected function success($data = null, $message = 'Success', $code = 200): JsonResponse
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'data' => $data
        ], $code);
    }

    /**
     * Error response helper
     */
    protected function error($message = 'Error', $code = 400): JsonResponse
    {
        return response()->json([
            'success' => false,
            'message' => $message
        ], $code);
    }
}