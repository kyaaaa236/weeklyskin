import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/jadwal_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String hariTerpilih = 'Senin'; 

  void _showFormTambah(BuildContext context) {
    final aktivitasController = TextEditingController();
    final keteranganController = TextEditingController();
    String formHari = hariTerpilih;
    TimeOfDay formWaktu = const TimeOfDay(hour: 20, minute: 0); 

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF48FB1), 
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 25,
                left: 25,
                right: 25,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 25, 
              ),
              child: SingleChildScrollView( 
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Jadwal Skincare',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text('Tanggal/Hari', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: formHari,
                          isExpanded: true,
                          items: ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'].map((String h) {
                            return DropdownMenuItem<String>(value: h, child: Text(h));
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) setModalState(() => formHari = val);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text('Aktivitas Skincare', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: aktivitasController,
                      decoration: InputDecoration(
                        hintText: 'Misal: Eksfoliasi / Masker',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text('Keterangan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: keteranganController,
                      decoration: InputDecoration(
                        hintText: 'Misal: Pakai Serum AHA BHA',
                        fillColor: Colors.white,
                        filled: true,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Waktu: ${formWaktu.format(context)}',
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFFF48FB1)),
                          icon: const Icon(Icons.access_time),
                          label: const Text('Pilih Jam'),
                          onPressed: () async {
                            final TimeOfDay? picked = await showTimePicker(context: context, initialTime: formWaktu);
                            if (picked != null) setModalState(() => formWaktu = picked);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB2EBF2), 
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        onPressed: () async {
                          if (aktivitasController.text.trim().isNotEmpty) {
                            final waktuString = '${formWaktu.hour.toString().padLeft(2, '0')}:${formWaktu.minute.toString().padLeft(2, '0')}:00';
                            
                            final sukses = await Provider.of<JadwalProvider>(ctx, listen: false).addJadwal(
                              formHari,
                              waktuString,
                              aktivitasController.text.trim(),
                              keteranganController.text.trim(),
                            );

                            if (sukses && ctx.mounted) {
                              Navigator.pop(ctx); 
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                const SnackBar(content: Text('Jadwal skincare berhasil disimpan! 🎉')),
                              );
                            }
                          } else {
                            ScaffoldMessenger.of(ctx).showSnackBar(
                              const SnackBar(content: Text('Isi "Aktivitas Skincare" terlebih dahulu ya, Tia!')),
                            );
                          }
                        },
                        child: const Text(
                          'SIMPAN',
                          style: TextStyle(color: Color(0xFFF48FB1), fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<JadwalProvider>(context, listen: false).fetchJadwal();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final jadwalProvider = Provider.of<JadwalProvider>(context);
    
    final jadwalHariIni = jadwalProvider.listJadwal
        .where((j) => j.hari.toLowerCase() == hariTerpilih.toLowerCase())
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE0F7FA), 
      appBar: AppBar(
        title: const Column(
          children: [
            Text(
              'WeeklySkin',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87),
            ),
            Text(
              '"Ready for your skin glow today?"',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.black54),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFE0F7FA),
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: 65,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'].map((hari) {
                bool isSelected = hari == hariTerpilih;
                return GestureDetector(
                  onTap: () => setState(() => hariTerpilih = hari),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFFF48FB1) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Center(
                      child: Text(
                        hari,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: jadwalProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF48FB1)),
                    ),
                  )
                : jadwalHariIni.isEmpty
                    ? const Center(
                        child: Text(
                          'APA JADWALMU HARI INI?', 
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black38),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: jadwalHariIni.length,
                        itemBuilder: (context, index) {
                          final data = jadwalHariIni[index];
                          final bool isCompleted = data.isDone == 1;

                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 10),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF48FB1),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  data.aktivitas,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Jam Pelaksanaan: ${data.waktu}',
                                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data.keterangan,
                                  style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 14),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isCompleted ? Colors.greenAccent : Colors.white,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                      ),
                                      onPressed: () {
                                      },
                                      child: Text(
                                        isCompleted ? 'COMPLETED' : 'SELESAI',
                                        style: const TextStyle(color: Color(0xFFF48FB1), fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    IconButton(
                                      icon: const Icon(Icons.delete_sweep, color: Colors.white, size: 28),
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (ctx) => AlertDialog(
                                            title: const Text('Hapus Aktivitas?'),
                                            content: Text('Apakah kamu yakin ingin menghapus "${data.aktivitas}" dari hari $hariTerpilih?'),
                                            actions: [
                                              TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
                                              TextButton(
                                                onPressed: () async {
                                                  Navigator.pop(ctx);
                                                  await jadwalProvider.deleteJadwal(data.id);
                                                },
                                                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                                              ),
                                            ],
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFFB2EBF2), 
        child: const Icon(Icons.add, color: Color(0xFFF48FB1), size: 36),
        onPressed: () => _showFormTambah(context),
      ),
    );
  }
}