<?php

use App\Http\Controllers\Api\EmployeeController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\LetterFormatController;
use App\Http\Controllers\Api\LetterController;
use App\Http\Controllers\Api\PositionController;


Route::apiResource('letter-formats', LetterFormatController::class);
Route::apiResource('letters', LetterController::class);

Route::apiResource('employees', EmployeeController::class);
Route::apiResource('positions', PositionController::class);
