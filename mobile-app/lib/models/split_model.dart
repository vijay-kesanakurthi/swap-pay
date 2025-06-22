// lib/models/split_model.dart
class SplitModel {
  final String id;
  final String expenseId;
  final String walletAddress;
  final double amountOwed;
  final bool isPaid;
  final String? paymentTxHash;
  final DateTime createdAt;
  final DateTime? paidAt;

  SplitModel({
    required this.id,
    required this.expenseId,
    required this.walletAddress,
    required this.amountOwed,
    required this.isPaid,
    this.paymentTxHash,
    required this.createdAt,
    this.paidAt,
  });

  factory SplitModel.fromJson(Map<String, dynamic> json) {
    return SplitModel(
      id: json["id"],
      expenseId: json["expense_id"],
      walletAddress: json["wallet_address"],
      amountOwed: (json["amount_owed"] as num).toDouble(),
      isPaid: json["is_paid"],
      paymentTxHash: json["payment_tx_hash"],
      createdAt: DateTime.parse(json["created_at"]),
      paidAt:
          json["paid_at"] != null ? DateTime.tryParse(json["paid_at"]) : null,
    );
  }
}
