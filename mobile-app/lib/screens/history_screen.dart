import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Attendance history', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
              const SizedBox(height: 8),
              const Text('Monthly view and daily summaries', style: TextStyle(color: Color(0xFF64748B))),
              const SizedBox(height: 24),
              Container(
                height: 220,
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(24)),
                child: const Center(child: Text('Calendar placeholder', style: TextStyle(color: Color(0xFF94A3B8)))),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  children: [
                    _historyTile('Monday, 6 May 2025', '09:02 AM', '06:15 PM', '9h 13m', ['Pune Office', 'Client XYZ']),
                    _historyTile('Tuesday, 7 May 2025', '09:15 AM', '06:10 PM', '8h 55m', ['Pune Office']),
                    _historyTile('Wednesday, 8 May 2025', '09:05 AM', '06:00 PM', '8h 55m', ['Pune Office', 'Client ABC']),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _historyTile(String date, String inTime, String outTime, String total, List<String> zones) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 16, offset: Offset(0, 8))]),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(date, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text('Punch In: $inTime', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('Punch Out: $outTime', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('Total: $total', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text('Zones Visited:', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          ...zones.map((zone) => Text('• $zone', style: const TextStyle(fontSize: 15))).toList(),
        ],
      ),
    );
  }
}
