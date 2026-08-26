import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';
import '../models/transaction_model.dart';

abstract class TransactionRemoteDataSource {
  Stream<List<TransactionModel>> getTransactionsStream(String userId);
  Future<List<CategoryModel>> getCategories(String userId);
  Future<void> addTransaction(String userId, TransactionModel transaction);
  Future<void> updateTransaction(String userId, TransactionModel transaction);
  Future<void> deleteTransaction(String userId, String transactionId);
}

class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final FirebaseFirestore _firestore;

  TransactionRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<TransactionModel>> getTransactionsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TransactionModel.fromMap(doc.data(), doc.id);
      }).toList();
    });
  }

  @override
  Future<List<CategoryModel>> getCategories(String userId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('categories')
        .get();

    if (snapshot.docs.isEmpty) {
      // Fallback default categories if empty
      return [
        const CategoryModel(id: '1', name: 'Ăn uống', icon: 'utensils', color: 0xFF10B981, type: 'expense'),
        const CategoryModel(id: '2', name: 'Mua sắm', icon: 'shopping-bag', color: 0xFF3B82F6, type: 'expense'),
        const CategoryModel(id: '3', name: 'Hóa đơn', icon: 'file-invoice', color: 0xFFF59E0B, type: 'expense'),
        const CategoryModel(id: '4', name: 'Giải trí', icon: 'gamepad', color: 0xFF8B5CF6, type: 'expense'),
        const CategoryModel(id: '5', name: 'Lương', icon: 'wallet', color: 0xFF059669, type: 'income'),
      ];
    }

    return snapshot.docs
        .map((doc) => CategoryModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<void> addTransaction(String userId, TransactionModel transaction) async {
    final docRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transaction.id.isNotEmpty ? transaction.id : null);

    final finalTransaction = TransactionModel(
      id: docRef.id,
      title: transaction.title,
      amount: transaction.amount,
      type: transaction.type,
      category: transaction.category,
      date: transaction.date,
      note: transaction.note,
      receiptImageUrl: transaction.receiptImageUrl,
      isAiParsed: transaction.isAiParsed,
      createdAt: transaction.createdAt,
    );

    await docRef.set(finalTransaction.toMap());
  }

  @override
  Future<void> updateTransaction(String userId, TransactionModel transaction) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transaction.id)
        .update(transaction.toMap());
  }

  @override
  Future<void> deleteTransaction(String userId, String transactionId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('transactions')
        .doc(transactionId)
        .delete();
  }
}
