import 'package:bill_split/controllers/group_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

class JoinGroupScannerScreen extends StatefulWidget {
  const JoinGroupScannerScreen({super.key});

  @override
  State<JoinGroupScannerScreen> createState() => _JoinGroupScannerScreenState();
}

class _JoinGroupScannerScreenState extends State<JoinGroupScannerScreen> {
  final isScanning = true.obs;
  final hasPermission = false.obs;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      hasPermission.value = true;
    } else {
      Get.snackbar(
        "Permission Denied",
        "Camera permission is required to scan QR code.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      Get.back();
    }
  }

  void _onScan(String inviteCode) async {
    if (!isScanning.value) return;

    isScanning.value = false;
    print("Scanned Invite Code: $inviteCode");

    try {
      await Get.find<GroupController>().joinGroup(
        inviteCode: inviteCode,
        name: "Rakesh",
      );
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to join group: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      isScanning.value = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Scan QR to Join Group"),
        centerTitle: true,
      ),
      body: Obx(() {
        if (!hasPermission.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Stack(
          children: [
            MobileScanner(
              onDetect: (capture) {
                final barcode = capture.barcodes.first;
                final rawValue = barcode.rawValue;
                if (rawValue != null) {
                  _onScan(rawValue);
                }
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: Colors.black54,
                child: const Text(
                  "Scan a group QR to join",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
