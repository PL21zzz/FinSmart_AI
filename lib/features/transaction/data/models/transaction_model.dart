import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/transaction_entity.dart';

class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.type,
    required super.category,
    required super.date,
    super.note,
    super.receiptImageUrl,
    super.isAiParsed = false,
    required super.createdAt,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map, String id) {
    return TransactionModel(
      id: id,
      title: map['title'] as String? ?? 'Giao dịch',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      type: map['type'] as String? ?? 'expense',
      category: map['category'] as String? ?? 'Ăn uống',
      date: map['date'] != null
          ? (map['date'] as Timestamp).toDate()
          : DateTime.now(),
      note: map['note'] as String?,
      receiptImageUrl: map['receiptImageUrl'] as String?,
      isAiParsed: map['isAiParsed'] as bool? ?? false,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'category': category,
      'date': Timestamp.fromDate(date),
      'note': note,
      'receiptImageUrl': receiptImageUrl,
      'isAiParsed': isAiParsed,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      type: entity.type,
      category: entity.category,
      date: entity.date,
      note: entity.note,
      receiptImageUrl: entity.receiptImageUrl,
      isAiParsed: entity.isAiParsed,
      createdAt: entity.createdAt,
    );
  }
}
