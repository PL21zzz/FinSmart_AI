import 'package:equatable/equatable.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {}

class TransactionLoading extends TransactionState {}

class TransactionLoaded extends TransactionState {
  final List<TransactionEntity> transactions;
  final List<CategoryEntity> categories;
  final double totalIncome;
  final double totalExpense;
  final double netBalance;

  const TransactionLoaded({
    required this.transactions,
    required this.categories,
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
  });

  @override
  List<Object?> get props => [
        transactions,
        categories,
        totalIncome,
        totalExpense,
        netBalance,
      ];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}
