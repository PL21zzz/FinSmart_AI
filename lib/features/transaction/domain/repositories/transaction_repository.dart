import '../entities/category_entity.dart';
import '../entities/transaction_entity.dart';

abstract class TransactionRepository {
  Stream<List<TransactionEntity>> getTransactionsStream(String userId);
  Future<List<CategoryEntity>> getCategories(String userId);
  Future<void> addTransaction(String userId, TransactionEntity transaction);
  Future<void> updateTransaction(String userId, TransactionEntity transaction);
  Future<void> deleteTransaction(String userId, String transactionId);
}
