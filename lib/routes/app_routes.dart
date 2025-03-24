import 'package:get/get.dart';
import 'package:kliktoko/gudang_page/GudangPage/GudangPage.dart';
import 'package:kliktoko/home_page/Homepage/HomePage.dart';
import 'package:kliktoko/navigation/NavBindings.dart';
import 'package:kliktoko/profile_page/ProfilePage/ProfilePage.dart';
import 'package:kliktoko/start.dart';
import 'package:kliktoko/navigation/BottomNavBar.dart';
import 'package:kliktoko/gudang_page/GudangBindings/GudangBindings.dart';
import 'package:kliktoko/home_page/HomeBindings/HomeBindings.dart';
import 'package:kliktoko/profile_page/ProfileBindings/ProfileBindings.dart';

class AppRoutes {
  static const String start = '/start';
  static const String bottomNav = '/bottomNav';
  static const String home = '/home';
  static const String gudang = '/gudang';
  static const String profile = '/profile';

  static final List<GetPage> routes = [
    GetPage(
      name: start,
      page: () => const StartPage(),
    ),
    GetPage(
  name: '/bottomNav',
    page: () => const FloatingBottomNavBar(),
    binding: NavBindings(),
    ),
    GetPage(
      name: home,
      page: () => const HomePage(),
      binding: HomeBindings(),
    ),
    GetPage(
      name: gudang,
      page: () => const GudangPage(),
      binding: GudangBindings(),
    ),
    GetPage(
      name: '/profile',
      page: () => const ProfilePage(),
      binding: ProfileBindings(), // Menghubungkan ProfileBindings ke rute ini
    ),
  ];
}
