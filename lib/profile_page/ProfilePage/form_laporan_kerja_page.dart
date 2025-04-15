import 'package:flutter/material.dart';
import '../widget/custom_date_picker_field.dart';
import '../widget/custom_input_field.dart';

class FormLaporanKerjaPage extends StatefulWidget {
  @override
  _FormLaporanKerjaPageState createState() => _FormLaporanKerjaPageState();
}

class _FormLaporanKerjaPageState extends State<FormLaporanKerjaPage> {
  final TextEditingController _namaController = TextEditingController();
  final TextEditingController _keteranganController = TextEditingController();
  DateTime? _tanggalDipilih;

  void _submitForm() {
    final nama = _namaController.text;
    final ket = _keteranganController.text;
    final tanggal = _tanggalDipilih;

    if (nama.isNotEmpty && ket.isNotEmpty && tanggal != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data berhasil disubmit')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Harap lengkapi semua data')),
      );
    }
  }

  void _cancelForm() {
    _namaController.clear();
    _keteranganController.clear();
    setState(() => _tanggalDipilih = null);
  }

  void _onDateSelected(DateTime? date) {
    setState(() {
      _tanggalDipilih = date;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFF8E2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Form Laporan Kerja',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            CustomInputField(
              label: 'Nama',
              controller: _namaController,
              hintText: 'Masukkan nama',
            ),
            const SizedBox(height: 16),
            CustomInputField(
              label: 'Keterangan',
              controller: _keteranganController,
              hintText: 'Masukkan keterangan',
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            CustomDatePickerField(
              selectedDate: _tanggalDipilih,
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2101),
                );
                _onDateSelected(picked);
              },
            ),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('Submit'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _cancelForm,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      side: const BorderSide(color: Colors.black),
                    ),
                    child: const Text('Cancel', style: TextStyle(color: Colors.black)),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
