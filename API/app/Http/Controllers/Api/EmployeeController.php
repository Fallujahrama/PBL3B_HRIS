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
     * Simpan data karyawan baru (Create).
     */
    public function store(Request $request) // Ganti dengan StoreEmployeeRequest $request jika sudah dibuat
    {

        
        // Contoh sederhana validasi (sebaiknya pindahkan ke Form Request)
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|exists:users,id',
            'first_name' => 'required|string|max:100',
            'last_name' => 'required|string|max:100',
            'gender' => 'required|in:M,F', // Laki-laki atau Perempuan
            'position_id' => 'nullable|exists:positions,id',
            'department_id' => 'nullable|exists:departments,id',
            'address' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal.',
                'errors' => $validator->errors()
            ], Response::HTTP_UNPROCESSABLE_ENTITY); // 422 Unprocessable Entity
        }

        try {
            $employee = Employee::create($request->validated()); // Gunakan $request->validated() jika pakai Form Request

            // Ambil data lengkap karyawan yang baru disimpan untuk respons
            $employee->load(['user', 'position', 'department']);

            return response()->json([
                'success' => true,
                'message' => 'Data karyawan berhasil ditambahkan.',
                'data' => $employee
            ], Response::HTTP_CREATED); // 201 Created
        } catch (\Exception $e) {
            Log::error('Error creating employee: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal menyimpan data karyawan.',
                'error' => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR); // 500 Internal Server Error
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
    public function update(Request $request, $id) // Ganti dengan UpdateEmployeeRequest $request jika sudah dibuat
    {
        $employee = Employee::find($id);

        if (!$employee) {
            return response()->json([
                'success' => false,
                'message' => 'Karyawan tidak ditemukan.'
            ], Response::HTTP_NOT_FOUND); // 404 Not Found
        }

        // Contoh sederhana validasi (sebaiknya pindahkan ke Form Request)
        $validator = Validator::make($request->all(), [
            'user_id' => 'required|exists:users,id',
            'first_name' => 'required|string|max:100',
            'last_name' => 'required|string|max:100',
            'gender' => 'required|in:L,P',
            'position_id' => 'nullable|exists:positions,id',
            'department_id' => 'nullable|exists:departments,id',
            'address' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal.',
                'errors' => $validator->errors()
            ], Response::HTTP_UNPROCESSABLE_ENTITY); // 422 Unprocessable Entity
        }

        try {
            $employee->update($request->validated()); // Gunakan $request->validated() jika pakai Form Request

            // Muat ulang (reload) relasi setelah update
            $employee->load(['user', 'position', 'department']);

            return response()->json([
                'success' => true,
                'message' => 'Data karyawan berhasil diperbarui.',
                'data' => $employee
            ], Response::HTTP_OK); // 200 OK
        } catch (\Exception $e) {
            Log::error('Error updating employee: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal memperbarui data karyawan.',
                'error' => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR); // 500 Internal Server Error
        }
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