import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_entity.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactionsRequested extends TransactionEvent {
  final String userId;

  const LoadTransactionsRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

class AddTransactionRequested extends TransactionEvent {
  final String userId;
  final TransactionEntity transaction;

  const AddTransactionRequested({
    required this.userId,
    required this.transaction,
  });

  @override
  List<Object?> get props => [userId, transaction];
}

class DeleteTransactionRequested extends TransactionEvent {
  final String userId;
  final String transactionId;

  const DeleteTransactionRequested({
    required this.userId,
    required this.transactionId,
  });

  @override
  List<Object?> get props => [userId, transactionId];
}

class TransactionsUpdated extends TransactionEvent {
  final List<TransactionEntity> transactions;

  const TransactionsUpdated(this.transactions);

  @override
  List<Object?> get props => [transactions];
}
