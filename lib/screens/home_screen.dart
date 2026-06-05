import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/jadwal_provider.dart';
import '../notification_service.dart'; 
import 'login_screen.dart';
import '../models/jadwal_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; 
  String _currentUsername = 'User'; 
  String _hariTerpilihLocal = 'Senin';

  @override
  void initState() {
    super.initState();
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<JadwalProvider>(context, listen: false).fetchJadwal();
      }
    });
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _currentUsername = prefs.getString('username') ?? 'User';
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildDashboardPage(), 
      _buildProfilePage(),   
    ];

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
      body: pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        selectedItemColor: const Color(0xFFF48FB1), 
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: _currentIndex == 0 
          ? FloatingActionButton(
              backgroundColor: const Color(0xFFB2EBF2),
              child: const Icon(Icons.add, color: Color(0xFFF48FB1), size: 36),
              onPressed: () => _showFormForm(context),
            )
          : null, 
    );
  }

  Widget _buildDashboardPage() {
    final jadwalProvider = Provider.of<JadwalProvider>(context);
    final List<String> listHari = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    
    final jadwalHariIni = jadwalProvider.listJadwal
        .where((j) => j.hari.toLowerCase() == _hariTerpilihLocal.toLowerCase())
        .toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Hai $_currentUsername, apa jadwalmu hari ini?',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
          ),
        ),
        Container(
          height: 65,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: listHari.map((hari) {
              bool isSelected = hari == _hariTerpilihLocal;
              return GestureDetector(
                onTap: () => setState(() => _hariTerpilihLocal = hari),
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
                    child: Text(hari, style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        Expanded(
          child: jadwalProvider.isLoading
              ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF48FB1))))
              : jadwalHariIni.isEmpty
                  ? const Center(child: Text('TIDAK ADA JADWAL SKINCARE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black38)))
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
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 8, offset: const Offset(0, 4))], // FIX
                          ),
                          child: Column(
                            children: [
                              Text(data.aktivitas, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white, decoration: isCompleted ? TextDecoration.lineThrough : TextDecoration.none)),
                              const SizedBox(height: 6),
                              Text('Jam: ${data.waktu}', style: const TextStyle(color: Colors.white70, fontSize: 14)),
                              Text(data.keterangan, style: const TextStyle(color: Colors.white70, fontStyle: FontStyle.italic, fontSize: 14), textAlign: TextAlign.center),
                              const SizedBox(height: 15),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: isCompleted ? Colors.greenAccent : Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                                    onPressed: () async {
                                      if (!isCompleted) {
                                        await jadwalProvider.setJadwalSelesai(data.id);
                                      }
                                    },
                                    child: Text(isCompleted ? 'COMPLETED' : 'SELESAI', style: TextStyle(color: isCompleted ? Colors.black87 : const Color(0xFFF48FB1), fontWeight: FontWeight.bold)),
                                  ),
                                  const SizedBox(width: 10),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.white, size: 24),
                                    onPressed: () => _showFormForm(context, data),
                                  ),
                                  const SizedBox(width: 5),
                                  IconButton(
                                    icon: const Icon(Icons.delete_sweep, color: Colors.white, size: 28),
                                    onPressed: () => _konfirmasiHapus(data.id, data.aktivitas),
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
    );
  }

  Widget _buildProfilePage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, 
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Color(0xFFF48FB1),
              child: Icon(Icons.person, size: 70, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              _currentUsername.toUpperCase(),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const Text(
              'Glow Up Fighter ✨',
              style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.black54),
            ),
            const SizedBox(height: 10),
            Divider(color: Colors.black.withValues(alpha: 0.25), thickness: 1, indent: 40, endIndent: 40), // FIX
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text('LOGOUT AKUN', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.clear(); 
                  
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFormForm(BuildContext context, [JadwalModel? item]) {
    final aktivitasController = TextEditingController(text: item != null ? item.aktivitas : '');
    final keteranganController = TextEditingController(text: item != null ? item.keterangan : '');
    String formHari = item != null ? item.hari : _hariTerpilihLocal;
    
    TimeOfDay formWaktu = const TimeOfDay(hour: 20, minute: 0);
    if (item != null) {
      final parts = item.waktu.split(':');
      if (parts.length >= 2) {
        formWaktu = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFF48FB1), 
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Padding(
              padding: EdgeInsets.only(top: 25, left: 25, right: 25, bottom: MediaQuery.of(ctx).viewInsets.bottom + 25),
              child: SingleChildScrollView( 
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Text(item != null ? 'Edit Jadwal Skincare' : 'Jadwal Skincare', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white))),
                    const SizedBox(height: 20),
                    const Text('Hari', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: formHari,
                          isExpanded: true,
                          items: ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'].map((String h) => DropdownMenuItem<String>(value: h, child: Text(h))).toList(),
                          onChanged: (val) { if (val != null) setModalState(() => formHari = val); },
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text('Aktivitas Skincare', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    TextField(
                      controller: aktivitasController,
                      decoration: InputDecoration(hintText: 'Misal: Eksfoliasi / Masker', fillColor: Colors.white, filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                    ),
                    const SizedBox(height: 15),
                    const Text('Keterangan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    TextField(
                      controller: keteranganController,
                      decoration: InputDecoration(hintText: 'Misal: Pakai Serum AHA BHA', fillColor: Colors.white, filled: true, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none)),
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Waktu: ${formWaktu.format(context)}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB2EBF2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
                        onPressed: () async {
                          if (aktivitasController.text.trim().isNotEmpty) {
                            final waktuString = '${formWaktu.hour.toString().padLeft(2, '0')}:${formWaktu.minute.toString().padLeft(2, '0')}:00';
                            
                            bool sukses = false;
                            final provider = Provider.of<JadwalProvider>(ctx, listen: false);
                            
                            if (item != null) {
                              sukses = await provider.kirimUpdateJadwal(item.id, formHari, waktuString, aktivitasController.text.trim(), keteranganController.text.trim());
                            } else {
                              sukses = await provider.addJadwal(formHari, waktuString, aktivitasController.text.trim(), keteranganController.text.trim());
                            }

                            if (sukses && ctx.mounted) {
                              Navigator.pop(ctx);
                              
                              await NotificationService.showInstantNotification(
                                id: DateTime.now().millisecondsSinceEpoch ~/ 1000,
                                title: 'WeeklySkin Reminder! ✨',
                                body: item != null 
                                  ? 'Jadwal "$_currentUsername" untuk aktivitas "${aktivitasController.text.trim()}" berhasil diubah!'
                                  : 'Jadwal baru "$_currentUsername" untuk aktivitas "${aktivitasController.text.trim()}" berhasil dipasang!',
                              );
                            }
                          }
                        },
                        child: Text(item != null ? 'SIMPAN PERUBAHAN' : 'SIMPAN', style: const TextStyle(color: Color(0xFFF48FB1), fontWeight: FontWeight.bold, fontSize: 16)),
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

  void _konfirmasiHapus(dynamic id, String aktivitas) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Aktivitas?'),
        content: Text('Apakah kamu yakin ingin menghapus "$aktivitas"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await Provider.of<JadwalProvider>(context, listen: false).deleteJadwal(id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}