import 'package:flutter/material.dart';

class HistoryKerjaPage extends StatelessWidget {
  final List<String> laporanList = List.generate(6, (index) => 'Laporan Kerja Senin');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF8E2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            // Go back to the ProfilePage
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'History Kerja',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SHORT BY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: 'Semua',
                  items: ['Semua', 'Senin', 'Selasa']
                      .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ))
                      .toList(),
                  onChanged: (value) {},
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: laporanList.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: index == 0 ? Colors.blue : Colors.black12,
                        width: index == 0 ? 2 : 1,
                      ),
                    ),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.black,
                        child: Icon(Icons.description, color: Colors.white),
                      ),
                      title: const Text(
                        'Laporan Kerja Senin',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: const Text('Tanggal : May, 05 2024'),
                      trailing: const Text(
                        'Total 2 Shift',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
