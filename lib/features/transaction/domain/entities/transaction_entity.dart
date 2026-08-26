import 'package:equatable/equatable.dart';

class TransactionEntity extends Equatable {
  final String id;
  final String title;
  final double amount;
  final String type; // 'expense' | 'income'
  final String category;
  final DateTime date;
  final String? note;
  final String? receiptImageUrl;
  final bool isAiParsed;
  final DateTime createdAt;

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
    this.receiptImageUrl,
    this.isAiParsed = false,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        amount,
        type,
        category,
        date,
        note,
        receiptImageUrl,
        isAiParsed,
        createdAt,
      ];
}
