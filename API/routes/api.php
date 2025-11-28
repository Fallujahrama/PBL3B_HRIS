<?php

use App\Http\Controllers\Api\EmployeeController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\LetterFormatController;
use App\Http\Controllers\Api\LetterController;


Route::apiResource('letter-formats', LetterFormatController::class);
Route::apiResource('letters', LetterController::class);

Route::apiResource('employees', EmployeeController::class);
Route::get('/employee/department', [EmployeeController::class, 'getDepartments']);
Route::get('/employee/position', [EmployeeController::class, 'getPositions']);