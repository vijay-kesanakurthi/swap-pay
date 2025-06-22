// // lib/modules/wallet/wallet_service.dart
// import 'package:phantom_connect/phantom_connect.dart';
// import 'package:app_links/app_links.dart';
// import 'package:url_launcher/url_launcher.dart';

// class WalletService {
//   late final PhantomConnect _phantom;
//   Function(String)? _onConnected;

//   WalletService() {
//     _phantom = PhantomConnect(
//       appUrl: "https://token-splitter.app",
//       deepLink: "bill-split://phantom",
//     );
//   }

//   void listenForWalletConnections(Function(String) onConnected) {
//     _onConnected = onConnected;
//     final appLinks = AppLinks();

//     appLinks.getInitialLink().then((uri) {
//       if (uri != null) _handleUri(uri);
//     });

//     appLinks.uriLinkStream.listen(_handleUri);
//   }

//   void _handleUri(Uri uri) {
//     final params = uri.queryParameters;

//     if (uri.path == "/onConnect" && _phantom.createSession(params)) {
//       final userPublicKey = _phantom.userPublicKey;
//       if (_onConnected != null) {
//         _onConnected!(userPublicKey);
//       }
//     } else if (uri.path == "/onDisconnect") {
//       _onConnected?.call("");
//     }
//   }

//   Future<void> connect() async {
//     final uri = _phantom.generateConnectUri(
//       cluster: "mainnet-beta",
//       redirect: "/onConnect",
//     );
//     await launchUrl(uri, mode: LaunchMode.externalApplication);
//   }

//   Future<void> disconnect() async {
//     final uri = _phantom.generateDisconnectUri(redirect: "/onDisconnect");
//     await launchUrl(uri, mode: LaunchMode.externalApplication);
//   }
// }
