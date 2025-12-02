<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Position;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Validator;
use Symfony\Component\HttpFoundation\Response;

class PositionController extends Controller
{
    /**
     * Tampilkan daftar posisi (Read All).
     */
    public function index()
    {
        try {
            // muat data dengan pagination, terakhir muncul paling atas
            $positions = Position::latest()->paginate(10);

            return response()->json([
                'success' => true,
                'message' => 'Daftar posisi berhasil diambil.',
                'data' => $positions
            ], Response::HTTP_OK);
        } catch (\Exception $e) {
            Log::error('Error fetching positions: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil data posisi.',
                'error' => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Simpan posisi baru (Create).
     */
    public function store(Request $request)
    {
        // validasi (bisa dipindah ke FormRequest)
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:100',
            'rate_reguler' => 'nullable|numeric',
            'rate_overtime' => 'nullable|numeric',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal.',
                'errors' => $validator->errors()
            ], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            // gunakan validated data
            $data = $validator->validated();
            $position = Position::create($data);

            return response()->json([
                'success' => true,
                'message' => 'Posisi berhasil ditambahkan.',
                'data' => $position
            ], Response::HTTP_CREATED);
        } catch (\Exception $e) {
            Log::error('Error creating position: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal menyimpan posisi.',
                'error' => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Tampilkan detail posisi tertentu (Read Single).
     */
    public function show($id)
    {
        try {
            $position = Position::find($id);

            if (! $position) {
                return response()->json([
                    'success' => false,
                    'message' => 'Posisi tidak ditemukan.'
                ], Response::HTTP_NOT_FOUND);
            }

            return response()->json([
                'success' => true,
                'message' => 'Detail posisi berhasil diambil.',
                'data' => $position
            ], Response::HTTP_OK);
        } catch (\Exception $e) {
            Log::error('Error fetching position: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal mengambil detail posisi.',
                'error' => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Perbarui posisi (Update).
     */
    public function update(Request $request, $id)
    {
        $position = Position::find($id);

        if (! $position) {
            return response()->json([
                'success' => false,
                'message' => 'Posisi tidak ditemukan.'
            ], Response::HTTP_NOT_FOUND);
        }

        $validator = Validator::make($request->all(), [
            'name' => 'sometimes|required|string|max:100',
            'rate_reguler' => 'nullable|numeric',
            'rate_overtime' => 'nullable|numeric',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validasi gagal.',
                'errors' => $validator->errors()
            ], Response::HTTP_UNPROCESSABLE_ENTITY);
        }

        try {
            $data = $validator->validated();
            $position->update($data);

            return response()->json([
                'success' => true,
                'message' => 'Posisi berhasil diperbarui.',
                'data' => $position
            ], Response::HTTP_OK);
        } catch (\Exception $e) {
            Log::error('Error updating position: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal memperbarui posisi.',
                'error' => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }

    /**
     * Hapus posisi (Delete).
     */
    public function destroy($id)
    {
        $position = Position::find($id);

        if (! $position) {
            return response()->json([
                'success' => false,
                'message' => 'Posisi tidak ditemukan.'
            ], Response::HTTP_NOT_FOUND);
        }

        try {
            $position->delete();

            // mengikuti pola controller temanmu: mengembalikan pesan meskipun kode 204
            return response()->json([
                'success' => true,
                'message' => 'Posisi berhasil dihapus.'
            ], Response::HTTP_NO_CONTENT);
        } catch (\Exception $e) {
            Log::error('Error deleting position: ' . $e->getMessage());
            return response()->json([
                'success' => false,
                'message' => 'Gagal menghapus posisi.',
                'error' => $e->getMessage()
            ], Response::HTTP_INTERNAL_SERVER_ERROR);
        }
    }
}
