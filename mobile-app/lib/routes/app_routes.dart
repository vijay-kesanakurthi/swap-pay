// lib/routes/app_pages.dart
import 'package:bill_split/screens/group_screen.dart';
import 'package:bill_split/screens/login_screen.dart';
import 'package:bill_split/screens/profile_screen.dart';
import 'package:get/get.dart';

class AppRoutes {
  static const login = '/login';
  static const group = '/group';
  static const profile = '/profile';
}

class AppPages {
  static final routes = [
    GetPage(name: AppRoutes.login, page: () => const LoginScreen()),
    GetPage(name: AppRoutes.group, page: () => const GroupScreen()),
    GetPage(name: AppRoutes.profile, page: () => const ProfileScreen()),
  ];
}
