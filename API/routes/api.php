<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\LetterFormatController;
use App\Http\Controllers\Api\LetterController;
use App\Http\Controllers\SalaryReportController;

Route::apiResource('letter-formats', LetterFormatController::class);
Route::apiResource('letters', LetterController::class);


Route::prefix('reports/salary')->group(function () {
    Route::get('/', [SalaryReportController::class, 'index']);
    Route::get('/summary', [SalaryReportController::class, 'summary']);
    Route::get('/chart-salary', [SalaryReportController::class, 'chartSalary']);
    Route::get('/chart-overtime', [SalaryReportController::class, 'chartOvertime']);
    Route::get('/table', [SalaryReportController::class, 'table']);
    Route::get('/export', [SalaryReportController::class, 'export']);
});

