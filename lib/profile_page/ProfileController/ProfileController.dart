import 'package:flutter/material.dart';
import 'package:kliktoko/profile_page/ProfilePage/HistoryKerjaPage.dart';
import 'package:kliktoko/profile_page/ProfilePage/form_laporan_kerja_page.dart';

class ProfileController {
  void goToHistoryKerjaPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => HistoryKerjaPage()),
    );
  }

  void goToFormLaporanKerjaPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FormLaporanKerjaPage()),
    );
  }

  void goToThemeSettings(BuildContext context) {
    Navigator.pushNamed(context, '/theme');
  }

  void logout(BuildContext context) {
    Navigator.pushNamed(context, '/logout');
  }
}
