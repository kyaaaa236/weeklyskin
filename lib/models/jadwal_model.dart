class JadwalModel {
  final String id; 
  final String hari;
  final String waktu;
  final String aktivitas;
  final String keterangan;
  final int isDone;

  JadwalModel({
    required this.id,
    required this.hari,
    required this.waktu,
    required this.aktivitas,
    required this.keterangan,
    required this.isDone,
  });

  
  factory JadwalModel.fromJson(Map<String, dynamic> json) {
    return JadwalModel(
      id: json['id'] != null ? json['id'].toString() : '', 
      hari: json['hari'] ?? '',
      waktu: json['waktu'] ?? '',
      aktivitas: json['aktivitas'] ?? '',
      keterangan: json['keterangan'] ?? '',
      isDone: json['isDone'] != null ? int.parse(json['isDone'].toString()) : 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hari': hari,
      'waktu': waktu,
      'aktivitas': aktivitas,
      'keterangan': keterangan,
      'isDone': isDone,
    };
  }
}