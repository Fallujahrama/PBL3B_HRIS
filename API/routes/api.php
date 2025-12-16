<?php

use App\Http\Controllers\Api\EmployeeController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\LetterFormatController;
use App\Http\Controllers\Api\LetterController;
use App\Http\Controllers\Api\DepartmentController;
use App\Http\Controllers\Api\PositionController;
use App\Http\Controllers\Api\SalaryReportController;
use App\Http\Controllers\Api\AttendanceController;
use App\Http\Controllers\Api\LetterSubmissionController;
use App\Http\Controllers\Api\EmployeeRecapController;
use App\Http\Controllers\Api\UserController;
use App\Http\Controllers\Api\SalaryController;
use App\Http\Controllers\Api\EmployeeDashboardController;
use App\Http\Controllers\Api\AbsensiController;
use App\Http\Controllers\Api\ScheduleController;
use App\Models\Absensi;

Route::apiResource('departments', DepartmentController::class);

Route::apiResource('employees', EmployeeController::class);
Route::get('/employee/department', [EmployeeController::class, 'getDepartments']);
Route::get('/employee/position', [EmployeeController::class, 'getPositions']);
Route::apiResource('positions', PositionController::class);

Route::prefix('summary-salary')->group(function () {
    Route::get('departments', [SalaryReportController::class, 'getDepartments']);
    Route::get('monthly-history', [SalaryReportController::class, 'monthlyHistory']);
    Route::get('/', [SalaryReportController::class, 'index']);
});

// ============================
// LETTER FORMATS (Template Management)
// ============================
Route::get('/letter-formats', [LetterFormatController::class, 'index']);
Route::post('/letter-formats', [LetterFormatController::class, 'store']);
Route::get('/letter-formats/{id}', [LetterFormatController::class, 'show']);
Route::put('/letter-formats/{id}', [LetterFormatController::class, 'update']);
Route::delete('/letter-formats/{id}', [LetterFormatController::class, 'destroy']);

// ============================
// LETTERS MANAGEMENT (HRD)
// ============================
Route::get('/letters', [LetterController::class, 'index']);
Route::get('/letters/{id}', [LetterController::class, 'show']);
Route::put('/letters/{id}/status', [LetterController::class, 'updateStatus']);
Route::get('/letters/{id}/download', [LetterController::class, 'download']);

// ============================
// LETTER SUBMISSION (Karyawan mengajukan surat)
// ============================
// Route::middleware('auth:sanctum')->group(function () {
Route::get('/letter/employee', [LetterSubmissionController::class, 'employeeInfo']);
Route::post('/letters/submit', [LetterSubmissionController::class, 'submit']);
// });

// ============================
// EMPLOYEE RECAP LETTERS
// ============================
Route::get('/employee-recap', [EmployeeRecapController::class, 'index']);
Route::get('/employee-recap/download', [EmployeeRecapController::class, 'download']);
Route::get('/employee-recap/pdf', [EmployeeRecapController::class, 'downloadPdf']);

// ============================
// Absensi Routes
// ============================
// 1. Submit Attendance (clock_in / clock_out / overtime_start / overtime_end)
Route::post('/attendance/submit', [AttendanceController::class, 'store']);
// 2. Get Department Location (untuk inisialisasi frontend)
Route::get('/department/location/{employeeId}', [AttendanceController::class, 'getDepartmentLocation']);
// 3. Get Attendance History (untuk tampilkan riwayat)
Route::get('/attendance/history/{employeeId}', [AttendanceController::class, 'getHistory']);

Route::prefix('employee')->middleware('auth:api')->group(function () {

    // Dashboard & Attendance
    Route::get('/dashboard/summary', [EmployeeDashboardController::class, 'getDashboardSummary']);
    Route::get('/dashboard/weekly-attendance', [EmployeeDashboardController::class, 'getWeeklyAttendance']);
    Route::get('/attendance/history', [EmployeeDashboardController::class, 'getAttendanceHistory']);
    Route::get('/overtime/history', [EmployeeDashboardController::class, 'getOvertimeHistory']);

    // Profile
    Route::get('/profile', [EmployeeDashboardController::class, 'getProfile']);
    Route::get('/user/profile', [UserController::class, 'profile']);
    Route::put('/profile', [UserController::class, 'editprofile']);

    // Absensi Report
    Route::get('/absensi/report', [AbsensiController::class, 'report']);

    // ==========================================
    // SLIP GAJI (Route Baru)
    // Endpoint: /api/employee/salary-slip
    // ==========================================
    Route::get('/salary-slip', [SalaryController::class, 'getSalarySlip']);
});

Route::prefix('schedules')->group(function () {
    Route::get('/', [ScheduleController::class, 'index']);                   // GET /api/schedules?year=YYYY
    Route::get('/sync', [ScheduleController::class, 'sync']);               // GET /api/schedules/sync?year=YYYY
    Route::get('/month/{month}', [ScheduleController::class, 'byMonth']);   // GET /api/schedules/month/12?year=2025
    Route::get('/is-holiday/{date}', [ScheduleController::class, 'isHoliday']); // GET /api/schedules/is-holiday/2025-12-25
    Route::post('/', [ScheduleController::class, 'store']);                 // POST /api/schedules
    Route::delete('/{id}', [ScheduleController::class, 'destroy']);         // DELETE /api/schedules/{id}
});