// lib/models/absensi_model.dart

class AbsensiModel {
  final String tanggal;
  final String status;
  final String? jamMasuk;
  final String? jamPulang;
  final String? keterangan;

  AbsensiModel({
    required this.tanggal,
    required this.status,
    this.jamMasuk,
    this.jamPulang,
    this.keterangan,
  });

  factory AbsensiModel.fromJson(Map<String, dynamic> json) {
    return AbsensiModel(
      tanggal: json['tanggal'] ?? '',
      status: json['status'] ?? '-',
      jamMasuk: json['jam_masuk'],
      jamPulang: json['jam_pulang'],
      keterangan: json['keterangan'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tanggal': tanggal,
      'status': status,
      'jam_masuk': jamMasuk,
      'jam_pulang': jamPulang,
      'keterangan': keterangan,
    };
  }
}
