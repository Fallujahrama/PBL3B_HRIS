<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Employee;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use Symfony\Component\HttpFoundation\Response;

// Import Request Validation yang seharusnya sudah Anda buat
// use App\Http\Requests\StoreEmployeeRequest;
// use App\Http\Requests\UpdateEmployeeRequest;

class EmployeeController extends Controller
{
    /**
     * Tampilkan daftar semua karyawan (Read All).
     */
    public function index()
    {
        try {
            // Ambil semua data Employee, termasuk relasi User, Position, dan Department
            $employees = Employee::with(['user', 'position', 'department'])->latest()->paginate(10);
            // $employees = Employee::latest()->get(); // Jika tidak menggunakan pagination

            return response()->json([
                'success' => true,
                'message' => 'Daftar karyawan berhasil diambil.',
                'data' => $employees
            ], Response::HTTP_OK); // 200 OK
        } catch (\Exception $e) {
            Log::error('Error fetching employees: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data karyawan.',
                'error' => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR); // 500 Internal Server Error
        }
    }

        /**
     * Tambah karyawan baru + buat user terlebih dahulu.
     */
    public function store(Request $request)
    {
        // Validasi request
        $validator = Validator::make($request->all(), [
            // USER
            'email'         => 'required|email|unique:users,email',
            'password'      => 'required|min:6',
            'is_admin'      => 'boolean',

            // EMPLOYEE
            'first_name'        => 'required|string|max:100',
            'last_name'         => 'required|string|max:100',
            'gender'            => 'required|in:M,F',
            'position_id'       => 'required|integer',
            'department_id'     => 'required|integer',
            'address'           => 'nullable|string'
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal',
                'errors'  => $validator->errors()
            ], Response::HTTP_UNPROCESSABLE_ENTITY); // 422
        }

        DB::beginTransaction();

        try {
            // 1️⃣ Buat User terlebih dahulu
            $user = \App\Models\User::create([
                'email'     => $request->email,
                'password'  => bcrypt($request->password),
                'is_admin'  => $request->is_admin ?? false
            ]);

            // 2️⃣ Buat Employee memakai user_id
            $employee = Employee::create([
                'user_id'       => $user->id,
                'first_name'    => $request->first_name,
                'last_name'    => $request->last_name,
                'position_id'   => $request->position_id,
                'gender' => $request -> gender,
                'department_id' => $request->department_id,
                'address'       => $request->address
            ]);



            DB::commit();

            return response()->json([
                'success' => true,
                'message' => 'Karyawan berhasil ditambahkan',
                'data'    => [
                    'user'      => $user,
                    'employee'  => $employee
                ]
            ], Response::HTTP_CREATED); // 201

        } catch (\Exception $e) {

            DB::rollBack();
            Log::error('Error creating employee: '.$e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'Gagal menambah karyawan',
                'error'   => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Tampilkan detail karyawan tertentu (Read Single).
     */
    public function show($id)
    {
        try {
            // Cari Employee berdasarkan ID, termasuk relasi
            $employee = Employee::with(['user', 'position', 'department'])->find($id);

            if (!$employee) {
                return response()->json([
                    'success' => false,
                    'message' => 'Karyawan tidak ditemukan.'
                ], Response::HTTP_NOT_FOUND); // 404 Not Found
            }

            return response()->json([
                'success' => true,
                'message' => 'Detail karyawan berhasil diambil.',
                'data' => $employee
            ], Response::HTTP_OK); // 200 OK
        } catch (\Exception $e) {
            Log::error('Error fetching employee: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil detail karyawan.',
                'error' => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR); // 500 Internal Server Error
        }
    }

    /**
     * Perbarui data karyawan (Update).
     */
    public function update(Request $request, $id)
    {
        $employee = Employee::with('user')->find($id);
    
        if (!$employee) {
            return response()->json([
                'success' => false,
                'message' => 'Karyawan tidak ditemukan.'
            ], Response::HTTP_NOT_FOUND);
        }
    
        // Validasi UPDATE (disesuaikan dengan database kamu)
        $validator = Validator::make($request->all(), [
    
            // USER
            'email'     => 'required|email|unique:users,email,' . $employee->user->id,
            'password'  => 'nullable|min:6',
            'is_admin'  => 'boolean',
    
            // EMPLOYEE
            'first_name'    => 'required|string|max:100',
            'last_name'     => 'required|string|max:100',
            'gender'        => 'required|in:M,F',
            'position_id'   => 'required|exists:positions,id',
            'department_id' => 'required|exists:departments,id',
            'address'       => 'nullable|string',
        ]);
    
        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal.',
                'errors' => $validator->errors()
            ], Response::HTTP_UNPROCESSABLE_ENTITY); 
        }
    
        // === UPDATE USER ===
        $employee->user->email = $request->email;
        $employee->user->is_admin = $request->is_admin ?? $employee->user->is_admin;
    
        if ($request->filled('password')) {
            $employee->user->password = bcrypt($request->password);
        }
    
        $employee->user->save();
    
        // === UPDATE EMPLOYEE ===
        $employee->update([
            'first_name'    => $request->first_name,
            'last_name'     => $request->last_name,
            'gender'        => $request->gender,
            'position_id'   => $request->position_id,
            'department_id' => $request->department_id,
            'address'       => $request->address,
        ]);
    
        return response()->json([
            'success' => true,
            'message' => 'Data karyawan berhasil diperbarui.',
            'data' => $employee->load('user', 'position', 'department')
        ]);
    }
    
    /**
     * Hapus data karyawan (Delete).
     */
    public function destroy($id)
    {
        $employee = Employee::find($id);

        if (!$employee) {
            return response()->json([
                'success' => false,
                'message' => 'Karyawan tidak ditemukan.'
            ], Response::HTTP_NOT_FOUND); // 404 Not Found
        }

        try {
            $employee->delete();

            return response()->json([
                'success' => true,
                'message' => 'Data karyawan berhasil dihapus.'
            ], Response::HTTP_NO_CONTENT); // 204 No Content (Respons sukses tanpa konten)
        } catch (\Exception $e) {
            Log::error('Error deleting employee: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus data karyawan.',
                'error' => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR); // 500 Internal Server Error
        }
    }

    public function getDepartments()
    {
        try {
            $departments = \App\Models\Department::all();

            return response()->json([
                'success' => true,
                'message' => 'Daftar department berhasil diambil.',
                'data' => $departments
            ], Response::HTTP_OK);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data department.',
                'error' => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    public function getPositions()
    {
        try {
            $positions = \App\Models\Position::all();

            return response()->json([
                'success' => true,
                'message' => 'Daftar position berhasil diambil.',
                'data' => $positions
            ], Response::HTTP_OK);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data position.',
                'error' => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

}