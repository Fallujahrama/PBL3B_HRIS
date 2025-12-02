<?php

use App\Http\Controllers\Api\EmployeeController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\LetterFormatController;
use App\Http\Controllers\Api\LetterController;
use App\Http\Controllers\Api\DepartmentController;
use App\Http\Controllers\Api\PositionController;
use App\Http\Controllers\Api\SalaryReportController;

Route::apiResource('departments', DepartmentController::class);
Route::apiResource('letter-formats', LetterFormatController::class);
Route::apiResource('letters', LetterController::class);

Route::apiResource('employees', EmployeeController::class);
Route::apiResource('positions', PositionController::class);

Route::prefix('summary-salary')->group(function () {
    Route::get('departments', [SalaryReportController::class, 'getDepartments']);
    Route::get('monthly-history', [SalaryReportController::class, 'monthlyHistory']);
    Route::get('/', [SalaryReportController::class, 'index']);
});
