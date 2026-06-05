import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/jadwal_model.dart';

class JadwalProvider with ChangeNotifier {
  List<JadwalModel> _listJadwal = [];
  bool _isLoading = false;

  List<JadwalModel> get listJadwal => _listJadwal;
  bool get isLoading => _isLoading;

  Future<void> fetchJadwal() async {
    final url = Uri.parse('http://192.168.1.105/api_weeklyskin/read.php'); 
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> extractedData = json.decode(response.body);
        _listJadwal = extractedData.map((item) => JadwalModel.fromJson(item)).toList();
      }
    } catch (error) {
      if (kDebugMode) debugPrint("Error read data: $error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  Future<bool> deleteJadwal(String id) async {
    final url = Uri.parse('http://192.168.1.105/api_weeklyskin/delete.php');
    try {
      final response = await http.post(url, body: {'id': id});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          _listJadwal.removeWhere((element) => element.id == id);
          notifyListeners();
          return true;
        }
      }
    } catch (error) {
      if (kDebugMode) debugPrint("Error delete data: $error");
    }
    return false;
  }
  Future<bool> addJadwal(String hari, String waktu, String aktivitas, String keterangan) async {
    final url = Uri.parse('http://192.168.1.105/api_weeklyskin/create.php');
    try {
      final response = await http.post(url, body: {
        'hari': hari,
        'waktu': waktu,
        'aktivitas': aktivitas,
        'keterangan': keterangan,
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          await fetchJadwal(); 
          return true;
        }
      }
    } catch (error) {
      if (kDebugMode) debugPrint("Error create data: $error");
    }
    return false;
  }
  Future<bool> updateJadwal(String id) async {
    final url = Uri.parse('http://192.168.1.105/api_weeklyskin/update.php');
    try {
      final response = await http.post(url, body: {'id': id});
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'success') {
          await fetchJadwal(); 
          return true;
        }
      }
    } catch (error) {
      if (kDebugMode) debugPrint("Error update data: $error");
    }
    return false;
  }
}