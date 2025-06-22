import 'dart:math';

import 'package:bill_split/controllers/group_controller.dart';
import 'package:bill_split/models/coins_data.dart';
import 'package:bill_split/models/expense_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PayExpenseScreen extends StatefulWidget {
  final Expense expense;

  const PayExpenseScreen({super.key, required this.expense});

  @override
  State<PayExpenseScreen> createState() => _PayExpenseScreenState();
}

class _PayExpenseScreenState extends State<PayExpenseScreen> {
  final groupController = Get.find<GroupController>();

  Token? selectedToken;
  String? quotedAmount;
  bool isFetchingQuote = false;

  @override
  void initState() {
    super.initState();
    selectedToken = getLocalTokens.firstWhereOrNull((t) => t.symbol == 'SOL');
    _getQuote();
  }

  Future<void> _getQuote() async {
    if (selectedToken == null) return;

    setState(() => isFetchingQuote = true);
    try {
      Token token = getLocalTokens.firstWhere(
        (t) => t.symbol == widget.expense.currency,
      );
      setState(() => quotedAmount = null);

      final quote = await groupController.getQuote(
        amount:
            (widget.expense.totalAmount / widget.expense.splits.length) *
            pow(10, token.decimals),
        inputmint: selectedToken!.address,
        outputMint: token.address,
      );

      setState(() {
        quotedAmount = (quote / pow(10, selectedToken!.decimals))
            .toStringAsPrecision(4);
      });
    } catch (e) {
      Get.snackbar("Quote Error", "Unable to fetch quote: $e");
    } finally {
      setState(() => isFetchingQuote = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final owedAmount = (widget.expense.totalAmount /
            (widget.expense.splits.length))
        .toStringAsPrecision(4);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pay Your Share"),
        centerTitle: true,
        elevation: 2,
      ),
      body: SafeArea(
        child: Center(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildInfoTile("Expense Title", widget.expense.title),
                          const Divider(height: 20),
                          _buildInfoTile(
                            "You Owe",
                            "$owedAmount ${widget.expense.currency}",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Choose Token to Pay With",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<Token>(
                      value: selectedToken,
                      isExpanded: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items:
                          getLocalTokens.map((token) {
                            return DropdownMenuItem<Token>(
                              value: token,
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: Image.network(
                                      token.logoURI,
                                      height: 24,
                                      width: 24,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (_, __, ___) =>
                                              const Icon(Icons.token, size: 20),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(token.symbol),
                                ],
                              ),
                            );
                          }).toList(),
                      onChanged: (val) {
                        selectedToken = val;
                        _getQuote();
                      },
                    ),
                    const SizedBox(height: 24),
                    if (isFetchingQuote)
                      const Center(child: CircularProgressIndicator())
                    else if (quotedAmount != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.swap_horiz, color: Colors.green),
                          const SizedBox(width: 6),
                          Text(
                            "~ $quotedAmount ${selectedToken!.symbol}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.send_rounded),
                        label: const Text("Pay Now"),
                        onPressed:
                            quotedAmount != null
                                ? () async {
                                  await groupController.getPaymentTransaction(
                                    widget.expense.paidByWallet,
                                    getLocalTokens
                                        .firstWhere(
                                          (t) =>
                                              t.symbol ==
                                              widget.expense.currency,
                                        )
                                        .address,
                                    expenseId: widget.expense.id,
                                  );
                                }
                                : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
