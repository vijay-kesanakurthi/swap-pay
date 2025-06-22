// // wallet_controller.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:phantom_connect/phantom_connect.dart';
// import 'package:app_links/app_links.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:pinenacl/ed25519.dart' hide Signature;
// import 'package:solana/encoder.dart';
// import 'package:solana/solana.dart';

// class WalletController extends GetxController {
//   late final PhantomConnect phantom;
//   final walletAddress = RxnString();

//   @override
//   void onInit() {
//     super.onInit();
//     phantom = PhantomConnect(
//       appUrl: "https://solana.com",
//       deepLink: "bill-split://phantom",
//     );
//     _listenForDeepLinks();
//   }

//   Future<void> _listenForDeepLinks() async {
//     final appLinks = AppLinks();
//     final initialLink = await appLinks.getInitialLink();
//     if (initialLink != null) _handleWalletRedirect(initialLink);

//     appLinks.uriLinkStream.listen(_handleWalletRedirect);
//   }

//   void _handleWalletRedirect(Uri uri) {
//     final queryParams = uri.queryParameters;
//     customPrint("Payload uri: $uri");
//     customPrint("Query Params: $queryParams");

//     if (queryParams.containsKey("errorCode")) {
//       Get.snackbar(
//         "Error",
//         queryParams["errorMessage"] ?? "Something went wrong!",
//         backgroundColor: Colors.red,
//         colorText: Colors.white,
//       );
//       return;
//     }

//     switch (uri.path) {
//       case '/onConnect':
//         _handleOnConnect(queryParams);
//         break;

//       case '/onDisconnect':
//         _handleOnDisconnect();
//         break;

//       case '/onSignAndSendTransaction':
//         _handleOnsignAndSendTransaction(queryParams);
//         break;

//       case '/onSignTransaction':
//         _handleOnsignTransaction();
//         break;

//       case '/onSignMessage':
//         _handleOnSignMessage();
//         break;

//       default:
//         break;
//     }
//   }

//   _handleOnConnect(Map<String, String> queryParams) {
//     if (phantom.createSession(queryParams)) {
//       walletAddress.value = phantom.userPublicKey;
//     } else {
//       walletAddress.value = null;
//     }
//   }

//   _handleOnDisconnect() {
//     walletAddress.value = null;
//   }

//   _handleOnSignMessage() {}

//   _handleOnsignAndSendTransaction(Map<String, String> queryParams) {
//     Map<dynamic, dynamic> decriptedData = phantom.decryptPayload(
//       data: queryParams["data"]!,
//       nonce: queryParams["nonce"]!,
//     );

//     customPrint(decriptedData);

//     Get.snackbar(
//       "Transaction",
//       "${decriptedData["signature"]}",
//       backgroundColor: Colors.green,
//       colorText: Colors.white,
//     );
//   }

//   _handleOnsignTransaction() {}

//   Future<void> launchUri(Uri uri) async {
//     try {
//       await launchUrl(uri, mode: LaunchMode.externalApplication);
//     } catch (_) {
//       customPrint("Could not launch $uri");
//     }
//   }

//   Future<void> connectWallet() async {
//     final connectUrl = phantom.generateConnectUri(
//       cluster: 'devnet',
//       redirect: '/onConnect',
//     );
//     await launchUri(connectUrl);
//   }

//   Future<void> disconnectWallet() async {
//     final disconnectUrl = phantom.generateDisconnectUri(
//       redirect: '/onDisconnect',
//     );
//     await launchUri(disconnectUrl);
//   }

//   Future<void> signMessage() async {
//     final signMessageUri = phantom.generateSignMessageUri(
//       nonce: _nonce,
//       redirect: "/onSignMessage",
//     );
//     await launchUri(signMessageUri);
//   }

//   Future<void> signTransaction() async {
//     final signTransaction = phantom.generateSignTransactionUri(
//       transaction: "abcdabcdabcd",
//       redirect: '/onSignTransaction',
//     );
//     await launchUri(signTransaction);
//   }

//   // Future<void> signAndSendTransaction() async {
//   //   final signAndSendTransactionUri = phantom.generateSignAndSendTransactionUri(
//   //     transaction: "abcdabcdabcd",
//   //     redirect: '/onSignAndSendTransaction',
//   //   );
//   // }

//   signAndSendTransaction() async {
//     int amount = (0.05 * lamportsPerSol).toInt();
//     final transferIx = SystemInstruction.transfer(
//       fundingAccount: Ed25519HDPublicKey.fromBase58(phantom.userPublicKey),
//       recipientAccount: Ed25519HDPublicKey.fromBase58(
//         "3ypW2hd2e8zz4t7FRFK4nvshhP5BNJh777DD4FQ5ogHV",
//       ),
//       lamports: amount,
//     );
//     final message = Message.only(transferIx);
//     final blockhash =
//         await RpcClient('https://api.devnet.solana.com').getLatestBlockhash();
//     final compiled = message.compile(
//       recentBlockhash: blockhash.value.blockhash,
//       feePayer: Ed25519HDPublicKey.fromBase58(phantom.userPublicKey),
//     );

//     final tx =
//         SignedTx(
//           compiledMessage: compiled,
//           signatures: [
//             Signature(
//               List.filled(64, 0),
//               publicKey: Ed25519HDPublicKey.fromBase58(phantom.userPublicKey),
//             ),
//           ],
//         ).encode();

//     final uri = phantom.generateSignAndSendTransactionUri(
//       transaction: tx,
//       redirect: '/onSignAndSendTransaction',
//     );

//     await launchUri(uri);
//   }

//   Uint8List get _nonce => PineNaClUtils.randombytes(24);
// }

// customPrint(dynamic msg) {
//   print(msg);
// }

// import 'package:bill_split/services/wallet_service.dart';
// import 'package:get/get.dart';

// class WalletController extends GetxController {
//   final walletService = WalletService();

//   final RxString? userPublicKey = RxString("");
//   final RxBool isConnected = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     walletService.listenForWalletConnections(_onWalletConnected);
//   }

//   void connectWallet() {
//     walletService.connect();
//   }

//   void disconnectWallet() {
//     userPublicKey?.value = "";
//     isConnected.value = false;
//     walletService.disconnect();
//   }

//   void _onWalletConnected(String publicKey) {
//     userPublicKey?.value = publicKey;
//     isConnected.value = true;
//   }
// }
