import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';
import '../models/transaction_model.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource _remoteDataSource;

  TransactionRepositoryImpl({TransactionRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? TransactionRemoteDataSourceImpl();

  @override
  Stream<List<TransactionEntity>> getTransactionsStream(String userId) {
    return _remoteDataSource.getTransactionsStream(userId);
  }

  @override
  Future<List<CategoryEntity>> getCategories(String userId) async {
    return await _remoteDataSource.getCategories(userId);
  }

  @override
  Future<void> addTransaction(String userId, TransactionEntity transaction) async {
    await _remoteDataSource.addTransaction(
      userId,
      TransactionModel.fromEntity(transaction),
    );
  }

  @override
  Future<void> updateTransaction(String userId, TransactionEntity transaction) async {
    await _remoteDataSource.updateTransaction(
      userId,
      TransactionModel.fromEntity(transaction),
    );
  }

  @override
  Future<void> deleteTransaction(String userId, String transactionId) async {
    await _remoteDataSource.deleteTransaction(userId, transactionId);
  }
}
