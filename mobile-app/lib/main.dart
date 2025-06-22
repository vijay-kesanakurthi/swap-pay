// lib/main.dart
import 'package:bill_split/controllers/auth_controller.dart';
import 'package:bill_split/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const BillSplitApp());
}

class BillSplitApp extends StatelessWidget {
  const BillSplitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Token Splitter',
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController());
      }),
      initialRoute: AppRoutes.login,
      getPages: AppPages.routes,
    );
  }
}
