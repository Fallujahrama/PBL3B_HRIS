<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Employee;
use App\Models\Letter;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Auth;

class LetterSubmissionController extends Controller
{
    /**
     * Get employee info
     */
    public function employeeInfo(Request $request)
    {
        try {

$user = session()->get('user_login');


            dd($user);
            if (!$user) {
                // Testing mode: ambil employee pertama
                $employee = Employee::with(['position', 'department'])->where('user_id', $user->id)->first();

                if (!$employee) {
                    return response()->json([
                        'success' => false,
                        'message' => 'No employee found'
                    ], 404);
                }
            } else {
                $employee = Employee::with(['position', 'department'])
                    ->where('user_id', $user->id)
                    ->first();

                if (!$employee) {
                    return response()->json([
                        'success' => false,
                        'message' => 'Employee not found for this user'
                    ], 404);
                }
            }

            return response()->json([
                'success' => true,
                'employee' => [
                    'id' => $employee->id,
                    'first_name' => $employee->first_name,
                    'last_name' => $employee->last_name,
                    'position_id' => $employee->position_id,
                    'department_id' => $employee->department_id,
                    'position' => $employee->position ? [
                        'id' => $employee->position->id,
                        'name' => $employee->position->name,
                    ] : null,
                    'department' => $employee->department ? [
                        'id' => $employee->department->id,
                        'name' => $employee->department->name,
                    ] : null,
                ]
            ], 200);

        } catch (\Exception $e) {
            Log::error('employeeInfo error: ' . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }

    /**
     * Submit new letter (Karyawan mengajukan surat)
     */
    public function submit(Request $request)
    {
        try {
            Log::info('Letter submission request:', $request->all());

            // Validation
            $validated = $request->validate([
                'letter_format_id' => 'required|exists:letter_formats,id',
                'tanggal_mulai' => 'required|date',
                'tanggal_selesai' => 'required|date|after_or_equal:tanggal_mulai',
                'user_id' => 'required',
            ]);

            // Get employee (dengan atau tanpa auth)
            // $user = $request->user();

            // if (!$user) {
                // Testing mode: pakai employee pertama
                // $employee = Employee::with(['position', 'department'])->first();

                $employee = Employee::with('position', 'department')->where('user_id', $request->user_id)->first();
                Log::info('Using first employee for testing: ' . $employee->id);
            // } else {
            //     $employee = Employee::with(['position', 'department'])
            //         ->where('user_id', $user->id)
            //         ->first();
            //     Log::info('Using authenticated employee: ' . $employee->id);
            // }

            if (!$employee) {
                return response()->json([
                    'success' => false,
                    'message' => 'Employee not found'
                ], 404);
            }

            // Create letter
            $letter = Letter::create([
                'letter_format_id' => $validated['letter_format_id'],
                'employee_id' => $employee->id,
                'name' => trim($employee->first_name . ' ' . $employee->last_name),
                'jabatan' => $employee->position->name ?? '-',
                'departemen' => $employee->department->name ?? '-',
                'tanggal_mulai' => $validated['tanggal_mulai'],
                'tanggal_selesai' => $validated['tanggal_selesai'],
                'status' => 'pending',
            ]);
            

            Log::info('Letter created successfully', [
                'id' => $letter->id,
                'employee_id' => $employee->id,
                'status' => $letter->status
            ]);

            return response()->json([
                'success' => true,
                'message' => 'Letter submitted successfully',
                'data' => $letter
            ], 201);

        } catch (\Illuminate\Validation\ValidationException $e) {
            Log::error('Validation error:', $e->errors());

            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'errors' => $e->errors()
            ], 422);

        } catch (\Exception $e) {
            Log::error('Letter submission error: ' . $e->getMessage());
            Log::error('Stack trace: ' . $e->getTraceAsString());

            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }
}
