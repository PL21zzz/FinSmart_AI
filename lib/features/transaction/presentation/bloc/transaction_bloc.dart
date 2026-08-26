import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final TransactionRepository _repository;
  StreamSubscription<List<TransactionEntity>>? _streamSubscription;
  List<CategoryEntity> _cachedCategories = [];

  TransactionBloc({required TransactionRepository repository})
      : _repository = repository,
        super(TransactionInitial()) {
    on<LoadTransactionsRequested>(_onLoadTransactionsRequested);
    on<TransactionsUpdated>(_onTransactionsUpdated);
    on<AddTransactionRequested>(_onAddTransactionRequested);
    on<DeleteTransactionRequested>(_onDeleteTransactionRequested);
  }

  Future<void> _onLoadTransactionsRequested(
    LoadTransactionsRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(TransactionLoading());
    await _streamSubscription?.cancel();

    try {
      _cachedCategories = await _repository.getCategories(event.userId);

      _streamSubscription = _repository
          .getTransactionsStream(event.userId)
          .listen((transactions) {
        add(TransactionsUpdated(transactions));
      });
    } catch (e) {
      emit(TransactionError('Không thể tải dữ liệu giao dịch: ${e.toString()}'));
    }
  }

  void _onTransactionsUpdated(
    TransactionsUpdated event,
    Emitter<TransactionState> emit,
  ) {
    double income = 0;
    double expense = 0;

    for (var t in event.transactions) {
      if (t.type == 'income') {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    emit(
      TransactionLoaded(
        transactions: event.transactions,
        categories: _cachedCategories,
        totalIncome: income,
        totalExpense: expense,
        netBalance: income - expense,
      ),
    );
  }

  Future<void> _onAddTransactionRequested(
    AddTransactionRequested event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _repository.addTransaction(event.userId, event.transaction);
    } catch (e) {
      emit(TransactionError('Thêm giao dịch thất bại: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteTransactionRequested(
    DeleteTransactionRequested event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _repository.deleteTransaction(event.userId, event.transactionId);
    } catch (e) {
      emit(TransactionError('Xóa giao dịch thất bại: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    return super.close();
  }
}
