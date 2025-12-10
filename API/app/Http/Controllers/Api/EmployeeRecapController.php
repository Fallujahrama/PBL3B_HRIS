<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use PDF;
use App\Models\Employee;
use App\Models\Departement;
use App\Models\Position;
use Illuminate\Support\Facades\Log;

class EmployeeRecapController extends Controller
{
    public function index()
    {
        try {
            Log::info('📊 Employee Recap API called');

            $employees = Employee::with([
                'user:id,email',
                'position:id,name',
                'department:id,name',
                'letters' => function($query) {
                    $query->with('letterFormat:id,name')
                          ->orderBy('created_at', 'desc');
                }
            ])
            ->whereHas('letters')
            ->get()
            ->map(function($employee) {
                $letters = [];

                if ($employee->letters) {
                    foreach ($employee->letters as $letter) {
                        $letters[] = [
                            'id' => $letter->id,
                            'name' => $letter->name ?? '-',
                            'status' => $letter->status ?? 'pending',
                            'letterFormat' => $letter->letterFormat ? [
                                'id' => $letter->letterFormat->id,
                                'name' => $letter->letterFormat->name,
                            ] : null,
                            'createdAt' => $letter->created_at ? $letter->created_at->format('Y-m-d H:i') : '-',
                        ];
                    }
                }

                return [
                    'id' => $employee->id,
                    'name' => trim(($employee->first_name ?? '') . ' ' . ($employee->last_name ?? '')),
                    'email' => $employee->user ? $employee->user->email : '-',
                    'position' => $employee->position ? $employee->position->name : '-',
                    'departement' => $employee->department ? $employee->department->name : '-',
                    'gender' => strtoupper($employee->gender ?? 'M') === 'M' ? 'Male' : 'Female',
                    'createdAt' => $employee->created_at ? $employee->created_at->format('Y-m-d') : '-',
                    'letters' => $letters
                ];
            })
            ->values()
            ->toArray();

            Log::info('✅ Returning ' . count($employees) . ' employees');

            return response()->json([
                'success' => true,
                'data' => $employees
            ], 200);

        } catch (\Exception $e) {
            Log::error('❌ Error: ' . $e->getMessage());
            Log::error('File: ' . $e->getFile() . ':' . $e->getLine());

            return response()->json([
                'success' => false,
                'message' => $e->getMessage(),
                'file' => $e->getFile(),
                'line' => $e->getLine(),
            ], 500);
        }
    }

    /**
     * Download recap as CSV. Supports same filters: month=YYYY-MM and user_id
     */
    public function download(Request $request)
    {
        $month = $request->query('month');
        $userId = $request->query('user_id');

        $query = Employee::with(['department', 'position', 'user', 'letters' => function ($q) use ($month) {
            $q->with('letterFormat'); // ✅ Load letterFormat
            if ($month) {
                [$y, $m] = array_pad(explode('-', $month), 2, null);
                if ($y && $m) {
                    $q->whereYear('created_at', $y)->whereMonth('created_at', $m);
                }
            }
        }]);

        if ($userId) {
            $query->where('id', $userId);
        }

        if ($month) {
            [$y, $m] = array_pad(explode('-', $month), 2, null);
            if ($y && $m) {
                $query->whereHas('letters', function ($q) use ($y, $m) {
                    $q->whereYear('created_at', $y)->whereMonth('created_at', $m);
                });
            }
        } else {
            $query->whereHas('letters');
        }

        $employees = $query->get();

        $filename = 'employee_recap' . ($month ? "_{$month}" : '') . '.csv';

        $callback = function () use ($employees) {
            $output = fopen('php://output', 'w');
            // ✅ Update header - Ganti Email jadi Periode
            fputcsv($output, ['employee_id','employee_name','department','position','letter_type','letter_status','period','submission_date']);

            foreach ($employees as $emp) {
                foreach ($emp->letters as $letter) {
                    // ✅ Hitung periode (tanggal_mulai - tanggal_selesai)
                    $period = '-';
                    if ($letter->tanggal_mulai && $letter->tanggal_selesai) {
                        $period = date('d/m/Y', strtotime($letter->tanggal_mulai)) . ' - ' . date('d/m/Y', strtotime($letter->tanggal_selesai));
                    }

                    fputcsv($output, [
                        $emp->id,
                        $emp->first_name . ' ' . $emp->last_name,
                        $emp->department ? $emp->department->name : '-',
                        $emp->position ? $emp->position->name : '-',
                        $letter->letterFormat ? $letter->letterFormat->name : '-', // ✅ Jenis surat
                        $letter->status,
                        $period, // ✅ Periode cuti/izin
                        $letter->created_at ? $letter->created_at->format('d/m/Y H:i') : '-', // ✅ Tanggal pengajuan
                    ]);
                }
            }

            fclose($output);
        };

        return response()->streamDownload($callback, $filename, [
            'Content-Type' => 'text/csv; charset=UTF-8',
        ]);
    }

    /**
     * Download recap as PDF. Supports same filters: month=YYYY-MM and user_id
     */
    public function downloadPdf(Request $request)
    {
        $month = $request->query('month');
        $userId = $request->query('user_id');

        $query = Employee::with(['department', 'position', 'user', 'letters' => function ($q) use ($month) {
            $q->with('letterFormat'); // ✅ Load letterFormat
            if ($month) {
                [$y, $m] = array_pad(explode('-', $month), 2, null);
                if ($y && $m) {
                    $q->whereYear('created_at', $y)->whereMonth('created_at', $m);
                }
            }
        }]);

        if ($userId) {
            $query->where('id', $userId);
        }

        if ($month) {
            [$y, $m] = array_pad(explode('-', $month), 2, null);
            if ($y && $m) {
                $query->whereHas('letters', function ($q) use ($y, $m) {
                    $q->whereYear('created_at', $y)->whereMonth('created_at', $m);
                });
            }
        } else {
            $query->whereHas('letters');
        }

        $employees = $query->get();

        $html = $this->generatePdfHtml($employees, $month);
        $pdf = PDF::loadHTML($html);

        $filename = 'employee_recap' . ($month ? "_{$month}" : '') . '.pdf';
        return $pdf->download($filename);
    }

    private function generatePdfHtml($employees, $month = null)
    {
        $periodText = $month ? 'Periode: ' . date('F Y', strtotime($month . '-01')) : 'Semua Periode';
        $printDate = date('d F Y H:i');

        $html = '<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Laporan Rekap Pengajuan Surat Karyawan</title>
    <style>
        body { font-family: Arial, sans-serif; font-size: 11px; margin: 20px; }
        h2 { text-align: center; margin-bottom: 5px; }
        .subtitle { text-align: center; margin-bottom: 20px; color: #666; }
        table { width: 100%; border-collapse: collapse; margin-top: 20px; }
        th, td { border: 1px solid #333; padding: 6px; text-align: left; }
        th { background-color: #e8e8e8; font-weight: bold; font-size: 10px; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        .footer { margin-top: 30px; text-align: right; font-size: 9px; color: #999; }
    </style>
</head>
<body>
    <h2>Laporan Rekap Pengajuan Surat Karyawan</h2>
    <div class="subtitle">' . $periodText . '</div>
    <table>
        <thead>
            <tr>
                <th style="width: 4%;">No</th>
                <th style="width: 16%;">Nama Karyawan</th>
                <th style="width: 12%;">Departemen</th>
                <th style="width: 10%;">Posisi</th>
                <th style="width: 18%;">Jenis Surat</th>
                <th style="width: 8%;">Status</th>
                <th style="width: 18%;">Periode</th>
                <th style="width: 14%;">Tgl Pengajuan</th>
            </tr>
        </thead>
        <tbody>';

        $no = 1;
        $hasData = false;

        foreach ($employees as $emp) {
            foreach ($emp->letters as $letter) {
                $hasData = true;

                // ✅ Hitung periode
                $period = '-';
                if ($letter->tanggal_mulai && $letter->tanggal_selesai) {
                    $period = date('d/m/y', strtotime($letter->tanggal_mulai)) . ' - ' . date('d/m/y', strtotime($letter->tanggal_selesai));
                }

                $html .= '<tr>
                    <td style="text-align: center;">' . $no++ . '</td>
                    <td>' . htmlspecialchars($emp->first_name . ' ' . $emp->last_name) . '</td>
                    <td>' . htmlspecialchars($emp->department ? $emp->department->name : '-') . '</td>
                    <td>' . htmlspecialchars($emp->position ? $emp->position->name : '-') . '</td>
                    <td>' . htmlspecialchars($letter->letterFormat ? $letter->letterFormat->name : '-') . '</td>
                    <td style="text-align: center;">' . ucfirst($letter->status) . '</td>
                    <td style="text-align: center; font-size: 9px;">' . $period . '</td>
                    <td style="text-align: center; font-size: 9px;">' . ($letter->created_at ? $letter->created_at->format('d/m/Y H:i') : '-') . '</td>
                </tr>';
            }
        }

        if (!$hasData) {
            $html .= '<tr><td colspan="8" style="text-align: center;">Tidak ada data</td></tr>';
        }

        $html .= '</tbody></table>
    <div class="footer">Dicetak: ' . $printDate . '</div>
</body>
</html>';

        return $html;
    }
}
