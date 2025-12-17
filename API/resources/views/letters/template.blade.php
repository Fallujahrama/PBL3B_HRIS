<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>{{ $jenis_surat }}</title>
    <style>
        body {
            font-family: 'Times New Roman', Times, serif;
            font-size: 12pt;
            line-height: 1.6;
            margin: 40px;
        }
        .header {
            text-align: right;
            margin-bottom: 30px;
        }
        .content {
            text-align: justify;
        }
        .signature {
            margin-top: 50px;
            text-align: right;
        }
        .employee-info {
            margin: 20px 0;
        }
        .employee-info table {
            margin-left: 40px;
        }
        .employee-info td {
            padding: 3px 0;
        }
    </style>
</head>
<body>
    <div class="header">
        <p>Malang, {{ date('d F Y') }}</p>
    </div>

    <div class="content">
        <p><strong>Perihal: {{ $jenis_surat }}</strong></p>

        <p style="margin-top: 20px;">
            Yth. HRD Perusahaan<br>
            Di tempat
        </p>

        <p style="margin-top: 20px;">Dengan hormat,</p>

        <p>Saya yang bertanda tangan di bawah ini:</p>

        <div class="employee-info">
            <table>
                <tr>
                    <td width="120">Nama</td>
                    <td width="20">:</td>
                    <td>{{ $name }}</td>
                </tr>
                <tr>
                    <td>Jabatan</td>
                    <td>:</td>
                    <td>{{ $jabatan }}</td>
                </tr>
                <tr>
                    <td>Departemen</td>
                    <td>:</td>
                    <td>{{ $departemen }}</td>
                </tr>
            </table>
        </div>

        <p>
            Dengan ini mengajukan permohonan {{ strtolower($jenis_surat) }}
            terhitung dari tanggal
            <strong>{{ date('d F Y', strtotime($tanggal_mulai)) }}</strong>
            sampai dengan
            <strong>{{ date('d F Y', strtotime($tanggal_selesai)) }}</strong>.
        </p>

        <p>
            Demikian surat permohonan ini saya buat dengan sebenarnya.
            Atas perhatian dan persetujuannya, saya ucapkan terima kasih.
        </p>
    </div>

    <div class="signature">
        <p>Hormat saya,</p>
        <br><br><br>
        <p><strong>{{ $name }}</strong></p>
    </div>
</body>
</html>
