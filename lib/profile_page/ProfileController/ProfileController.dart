import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kliktoko/profile_page/ProfilePage/HistoryKerjaPage.dart';
import 'package:kliktoko/profile_page/ProfilePage/form_laporan_kerja_page.dart';
import 'package:kliktoko/APIService/ApiService.dart';
import 'package:kliktoko/storage/storage_service.dart';

class ProfileController extends GetxController {
  final ApiService _apiService = ApiService();
  final StorageService _storageService = StorageService();
  var username = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _storageService.init().then((_) => loadUserData());
  }

  var isLoading = false.obs;
  var errorMessage = ''.obs;

  Future<void> loadUserData() async {
    if (isLoading.value) return;

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final token = await _storageService.getToken();
      if (token == null) {
        errorMessage.value = 'Sesi login telah berakhir';
        Get.offAllNamed('/login');
        return;
      }

      final userData = await _apiService.getUserData(token);
      if (userData.containsKey('name')) {
        username.value = userData['name'];
        await _storageService.saveUserData(userData); // Update cached user data
      } else {
        errorMessage.value = 'Data pengguna tidak lengkap';
      }
    } catch (e) {
      errorMessage.value = 'Gagal memuat data pengguna';
      print('Error loading user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

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
