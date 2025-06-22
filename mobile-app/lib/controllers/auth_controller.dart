// lib/modules/auth/auth_controller.dart
import 'package:bill_split/controllers/group_controller.dart';
import 'package:bill_split/routes/app_routes.dart';
import 'package:get/get.dart';
import 'package:phantom_connect/phantom_connect.dart';
import 'package:app_links/app_links.dart';
import 'package:url_launcher/url_launcher.dart';

class AuthController extends GetxController {
  late final PhantomConnect phantom;
  final walletAddress = RxnString();

  @override
  void onInit() {
    super.onInit();
    phantom = PhantomConnect(
      appUrl: "https://token-splitter.app",
      deepLink: "bill-split://phantom",
    );
    _listenForDeepLinks();
  }

  Future<void> _listenForDeepLinks() async {
    final appLinks = AppLinks();
    final initialLink = await appLinks.getInitialLink();
    if (initialLink != null) _handleWalletRedirect(initialLink);
    appLinks.uriLinkStream.listen(_handleWalletRedirect);
  }

  void _handleWalletRedirect(Uri uri) {
    final queryParams = uri.queryParameters;

    if (queryParams.containsKey("errorCode")) {
      Get.snackbar(
        "Wallet Error",
        queryParams["errorMessage"] ?? "Unknown error",
      );
      return;
    }

    final path = uri.path;

    if (path == '/onConnect') {
      if (phantom.createSession(queryParams)) {
        walletAddress.value = phantom.userPublicKey;
        Get.offAllNamed('/group');
      } else {
        walletAddress.value = null;
      }
    } else if (path == '/onDisconnect') {
      walletAddress.value = null;
      Get.offAllNamed(AppRoutes.login);
    } else if (path.startsWith('/onSignAndSendTransaction')) {
      final decryptedData = phantom.decryptPayload(
        data: queryParams["data"]!,
        nonce: queryParams["nonce"]!,
      );
      print(decryptedData);

      final segments = path.split('/');
      if (segments.length > 2) {
        final expenseId = segments[2];
        print('Expense ID from path: $expenseId');

        Get.find<GroupController>().sendPaymentSuccess(
          expenseId: expenseId,
          signature: decryptedData["signature"],
        );
      }
    }
  }

  Future<void> connectWallet() async {
    final uri = phantom.generateConnectUri(
      cluster: 'mainnet-beta',
      redirect: '/onConnect',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> disconnectWallet() async {
    final uri = phantom.generateDisconnectUri(redirect: '/onDisconnect');
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> signAndSendTransaction(
    String trans, {
    required String expenseId,
  }) async {
    final uri = phantom.generateSignAndSendTransactionUri(
      transaction: trans,
      redirect: '/onSignAndSendTransaction/$expenseId',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  bool get isLoggedIn => walletAddress.value != null;
}
