import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/jadwal_provider.dart';

class RiwayatScreen extends StatefulWidget {
  const RiwayatScreen({super.key});

  @override
  State<RiwayatScreen> createState() => _RiwayatScreenState();
}

class _RiwayatScreenState extends State<RiwayatScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () {
      if (mounted) {
        Provider.of<JadwalProvider>(context, listen: false).fetchJadwal();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E), 
      appBar: AppBar(
        title: const Text('Daftar Riwayat Sederhana', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.cyan,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Consumer<JadwalProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.cyan));
          }

          if (provider.listJadwal.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada riwayat kegiatan.',
                style: TextStyle(color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.listJadwal.length,
            itemBuilder: (context, index) {
              final jadwal = provider.listJadwal[index];
              final bool statusSelesai = jadwal.isDone == 1;

              return Card(
                color: const Color(0xFF2D2D2D),
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    jadwal.aktivitas,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      '${jadwal.hari}, ${jadwal.waktu}\nKet: ${jadwal.keterangan}',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ),

                  trailing: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusSelesai ? Colors.green.withAlpha(51) : Colors.transparent, 
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: statusSelesai ? Colors.green : Colors.white24,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      statusSelesai ? 'Completed' : 'Selesai',
                      style: TextStyle(
                        color: statusSelesai ? Colors.green : Colors.white, 
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}