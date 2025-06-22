// // wallet_ui.dart
// import 'package:bill_split/controllers/wallet_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class ConnectWalletScreen extends GetView<WalletController> {
//   const ConnectWalletScreen({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("Connect Wallet")),
//       body: Center(
//         child: Obx(() {
//           final walletAddress = controller.walletAddress.value;
//           return Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               walletAddress == null
//                   ? ElevatedButton(
//                     onPressed: controller.connectWallet,
//                     child: const Text("Connect Phantom Wallet"),
//                   )
//                   : Column(
//                     children: [
//                       const Icon(
//                         Icons.check_circle,
//                         color: Colors.green,
//                         size: 40,
//                       ),
//                       const SizedBox(height: 10),
//                       const Text("Connected Wallet:"),
//                       Text(
//                         walletAddress,
//                         style: const TextStyle(fontWeight: FontWeight.bold),
//                         textAlign: TextAlign.center,
//                       ),
//                       const SizedBox(height: 10),
//                       ElevatedButton(
//                         onPressed: controller.signMessage,
//                         child: const Text("Sign Message"),
//                       ),
//                       const SizedBox(height: 10),
//                       ElevatedButton(
//                         onPressed: controller.signAndSendTransaction,
//                         child: const Text("Send Transaction"),
//                       ),
//                       const SizedBox(height: 10),
//                       ElevatedButton(
//                         onPressed: controller.disconnectWallet,
//                         child: const Text("Disconnect Phantom Wallet"),
//                       ),
//                     ],
//                   ),
//             ],
//           );
//         }),
//       ),
//     );
//   }
// }
