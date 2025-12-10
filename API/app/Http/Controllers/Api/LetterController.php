<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Letter;
use Illuminate\Http\Request;
use Barryvdh\DomPDF\Facade\Pdf;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Log;

class LetterController extends Controller
{
    // GET all letters
    public function index()
    {
        try {
            // ✅ Load with relations
            $letters = Letter::with(['letterFormat', 'employee'])
                ->orderBy('created_at', 'desc')
                ->get();

            // ✅ Return langsung array (biar simple dulu)
            return response()->json($letters, 200);
        } catch (\Exception $e) {
            Log::error('LetterController index error: ' . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }

    // GET single letter
    public function show($id)
    {
        try {
            $letter = Letter::with(['letterFormat', 'employee'])->findOrFail($id);
            return response()->json($letter, 200);
        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => 'Letter not found'
            ], 404);
        }
    }

    // UPDATE status
    public function updateStatus(Request $request, $id)
    {
        try {
            $request->validate([
                'status' => 'required|in:pending,approved,rejected'
            ]);

            $letter = Letter::with(['letterFormat'])->findOrFail($id);
            $letter->status = $request->status;

            // ✅ Generate PDF saat approve (KEMBALIKAN SEPERTI KEMARIN)
            if ($request->status === 'approved') {
                $data = [
                    'name' => $letter->name,
                    'jabatan' => $letter->jabatan,
                    'departemen' => $letter->departemen,
                    'jenis_surat' => $letter->letterFormat->name,
                    'tanggal_mulai' => $letter->tanggal_mulai,
                    'tanggal_selesai' => $letter->tanggal_selesai,
                ];

                $pdf = Pdf::loadView('letters.template', $data);

                // ✅ Format file name seperti kemarin: surat_{id}_{timestamp}.pdf
                $fileName = 'surat_' . $letter->id . '_' . time() . '.pdf';

                // ✅ FIX: Jangan pakai 'public/' di path, langsung nama file
                // Storage akan otomatis save ke disk 'public'
                $path = 'letters/' . $fileName;

                // ✅ FIX: Explicitly gunakan disk 'public'
                Storage::disk('public')->put($path, $pdf->output());

                $letter->pdf_path = $path;
            }

            $letter->save();

            return response()->json([
                'success' => true,
                'message' => 'Status updated successfully',
                'data' => $letter
            ], 200);

        } catch (\Exception $e) {
            Log::error('Update status error: ' . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }

    // ✅ FIX: Download dengan file_get_contents (sama seperti kode Rizky)
    public function download($id)
    {
        try {
            $letter = Letter::findOrFail($id);

            if (!$letter->pdf_path) {
                return response()->json([
                    'success' => false,
                    'message' => 'PDF not available'
                ], 404);
            }

            // ✅ FIX: Ambil dari disk 'public'
            $fullPath = storage_path('app/public/' . $letter->pdf_path);

            if (!file_exists($fullPath)) {
                return response()->json([
                    'success' => false,
                    'message' => 'File not found: ' . $letter->pdf_path
                ], 404);
            }

            return response()->file($fullPath);

        } catch (\Exception $e) {
            Log::error('Download PDF error: ' . $e->getMessage());

            return response()->json([
                'success' => false,
                'message' => 'Error: ' . $e->getMessage()
            ], 500);
        }
    }
}
