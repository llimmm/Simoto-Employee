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
      // First try to get user data from local storage
      final localUserData = await _storageService.getUserData();
      if (localUserData != null && localUserData.containsKey('name')) {
        username.value = localUserData['name'];
        print('Loaded username from storage: ${username.value}');
      }
      
      // Then try to refresh from API if we have a token
      final token = await _storageService.getToken();
      if (token == null) {
        if (localUserData == null) {
          // Only redirect if we couldn't get data from storage either
          errorMessage.value = 'Sesi login telah berakhir';
          Get.offAllNamed('/login');
        }
        return;
      }

      final userData = await _apiService.getUserData(token);
      if (userData.containsKey('name')) {
        username.value = userData['name'];
        await _storageService.saveUserData(userData); // Update cached user data
        print('Updated username from API: ${username.value}');
      } else {
        errorMessage.value = 'Data pengguna tidak lengkap';
      }
    } catch (e) {
      // If we have a username from storage, don't show an error
      if (username.value.isEmpty) {
        errorMessage.value = 'Gagal memuat data pengguna';
      }
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