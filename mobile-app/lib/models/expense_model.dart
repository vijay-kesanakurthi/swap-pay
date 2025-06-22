// lib/models/expense_model.dart
import 'split_model.dart';

class Expense {
  final String id;
  final String groupId;
  final String title;
  final double totalAmount;
  final String currency;
  final String paidByWallet;
  final DateTime createdAt;
  final List<SplitModel> splits;

  Expense({
    required this.id,
    required this.groupId,
    required this.title,
    required this.totalAmount,
    required this.currency,
    required this.paidByWallet,
    required this.createdAt,
    required this.splits,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json["id"],
      groupId: json["group_id"],
      title: json["title"],
      totalAmount: (json["total_amount"] as num).toDouble(),
      currency: json["currency"],
      paidByWallet: json["paid_by_wallet"],
      createdAt: DateTime.parse(json["created_at"]),
      splits:
          (json["splits"] as List).map((s) => SplitModel.fromJson(s)).toList(),
    );
  }
}
