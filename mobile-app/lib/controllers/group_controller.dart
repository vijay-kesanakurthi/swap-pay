import 'package:bill_split/controllers/auth_controller.dart';
import 'package:bill_split/models/coins_data.dart';
import 'package:bill_split/models/expense_model.dart';
import 'package:bill_split/models/group_model.dart';
import 'package:bill_split/models/member_model.dart';
import 'package:bill_split/screens/payment_success_screen.dart';
import 'package:bill_split/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

class GroupController extends GetxController {
  final RxList<Group> groups = <Group>[].obs;
  final expenses = <Expense>[].obs;
  final members = <Member>[].obs;
  final isFetchingExpenses = false.obs;
  final isCreatingGroup = false.obs;
  final uuid = const Uuid();
  final isGettingGroups = false.obs;
  final isFetchingGroupMembers = false.obs;
  final isCreatingExpense = false.obs;
  final selectedToken = Rxn<Token>();

  final RxMap<String, dynamic> currentQuote = <String, dynamic>{}.obs;

  @override
  onInit() {
    super.onInit();
    selectedToken.value = getLocalTokens.firstWhereOrNull(
      (t) => t.symbol == 'USDT',
    );
    getAllGroups();
  }

  Future<void> createGroup(String name) async {
    try {
      isCreatingGroup.value = true;

      final wallet = Get.find<AuthController>().walletAddress.value;
      if (wallet == null) return;

      final response = await HttpService.post(
        "/groups",
        body: {"name": name, "creator_wallet": wallet},
      );

      final group = Group.fromJson(response["group"]);

      groups.insert(0, group);
    } catch (e) {
      print("Error creating group: $e");
      rethrow;
    } finally {
      isCreatingGroup.value = false;
    }
  }

  getAllGroups() async {
    try {
      final wallet = Get.find<AuthController>().walletAddress.value;
      if (wallet == null) return;
      isGettingGroups.value = true;
      final response = await HttpService.get('/groups/$wallet');
      groups.clear();
      for (var group in response["groups"]) {
        groups.add(Group.fromJson(group));
      }
    } catch (e) {
      print("Getting groups Error: $e");
    } finally {
      isGettingGroups.value = false;
    }
  }

  Group? getGroupById(String id) {
    return groups.firstWhereOrNull((g) => g.id == id);
  }

  Future<void> getGroupExpenses(String groupId) async {
    try {
      isFetchingExpenses.value = true;
      final response = await HttpService.get('/expenses/$groupId');
      print(response);
      expenses.value =
          (response as List).map((e) => Expense.fromJson(e)).toList();
    } catch (e) {
      print("Error fetching expenses: $e");
      expenses.clear();
    } finally {
      isFetchingExpenses.value = false;
    }
  }

  Future<void> getGroupMembers(String groupId) async {
    try {
      isFetchingGroupMembers.value = true;
      final response = await HttpService.get('/groups/members/$groupId');
      final rawMembers = response['members'] as List;
      members.value = rawMembers.map((e) => Member.fromJson(e)).toList();
      print(rawMembers);
    } finally {
      isFetchingGroupMembers.value = false;
    }
  }

  Future<void> createExpense({
    required String groupId,
    required String title,
    required double amount,
    required String currency,
  }) async {
    try {
      isCreatingExpense.value = true;
      final wallet = Get.find<AuthController>().walletAddress.value;
      if (wallet == null) return;
      Map body = {
        "group_id": groupId,
        "title": title,
        "total_amount": amount,
        "currency": currency,
        "paid_by_wallet": wallet,
      };
      print(body);
      final response = await HttpService.post('/expenses', body: body);
      Expense expense = Expense.fromJson(response);
      expenses.insert(0, expense);
    } catch (e) {
      print("Error creating expense: $e");
      rethrow;
    } finally {
      isCreatingExpense.value = false;
    }
  }

  Future<void> joinGroup({
    required String inviteCode,
    required String name,
  }) async {
    try {
      final wallet = Get.find<AuthController>().walletAddress.value;
      if (wallet == null) return;
      final response = await HttpService.post(
        '/groups/$inviteCode/join',
        body: {'name': name, 'wallet_address': wallet},
      );
      print("Joined group: $response");
      groups.insert(0, Group.fromJson(response["group"]));
      Get.back();
      Get.snackbar(
        "Joined",
        "Successfully joined the group!",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print("Error joining group: $e");
      Get.snackbar(
        "Error",
        "Failed to join group: $e",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<double> getQuote({
    required double amount,
    required String inputmint,
    required String outputMint,
  }) async {
    if (inputmint == outputMint) {
      return amount;
    }
    Map body = {
      "input_mint": inputmint,
      "output_mint": outputMint,
      "output_amount": amount.toInt(),
    };
    print(body);
    final response = await HttpService.post('/payments/quote', body: body);
    print(response);
    currentQuote.value = response;
    return double.tryParse(response["inAmount"]) ?? 0;
  }

  Future<void> getPaymentTransaction(
    String destWallet,
    String mintAddress, {
    required String expenseId,
  }) async {
    final wallet = Get.find<AuthController>().walletAddress.value;
    if (wallet == null) return;
    final Map<String, dynamic> quote = Map<String, dynamic>.from(currentQuote);
    Map body = {
      "mintAddress": mintAddress,
      "userPublicKey": wallet,
      "destPublicKey": destWallet,
      "quoteResponse": quote,
    };
    print(body);
    final transaction = await HttpService.post(
      '/payments/swap-and-pay',
      body: body,
    );

    print(transaction);

    Get.find<AuthController>().signAndSendTransaction(
      transaction["swapTransaction"],
      expenseId: expenseId,
    );
  }

  Future<void> sendPaymentSuccess({
    required String expenseId,
    required String signature,
  }) async {
    final wallet = Get.find<AuthController>().walletAddress.value;
    if (wallet == null) return;
    final body = {
      "wallet_address": wallet,
      "expense_id": expenseId,
      "payment_tx_hash": signature,
    };

    final response = await HttpService.post('/payment/paid', body: body);

    print(response);

    Get.off(() => const PaymentSuccessScreen());
  }
}
