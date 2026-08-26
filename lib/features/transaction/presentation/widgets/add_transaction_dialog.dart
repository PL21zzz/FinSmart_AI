import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bloc/transaction_bloc.dart';
import '../bloc/transaction_event.dart';

class AddTransactionDialog extends StatefulWidget {
  final TransactionEntity? initialTransaction;

  const AddTransactionDialog({
    super.key,
    this.initialTransaction,
  });

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  String _type = 'expense';
  String _category = 'Ăn uống';
  DateTime _selectedDate = DateTime.now();

  final List<String> _expenseCategories = [
    'Ăn uống',
    'Mua sắm',
    'Hóa đơn & Điện nước',
    'Giải trí',
    'Di chuyển',
    'Khác',
  ];

  final List<String> _incomeCategories = [
    'Lương tháng',
    'Thưởng & Thu nhập khác',
    'Đầu tư',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialTransaction != null) {
      final t = widget.initialTransaction!;
      _titleController.text = t.title;
      _amountController.text = t.amount.toInt().toString();
      _noteController.text = t.note ?? '';
      _type = t.type;
      _category = t.category;
      _selectedDate = t.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onSave() {
    if (_formKey.currentState?.validate() ?? false) {
      final authState = context.read<AuthBloc>().state;
      if (authState is Authenticated) {
        final amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

        final transaction = TransactionEntity(
          id: widget.initialTransaction?.id ?? const Uuid().v4(),
          title: _titleController.text.trim(),
          amount: amount,
          type: _type,
          category: _category,
          date: _selectedDate,
          note: _noteController.text.trim().isNotEmpty
              ? _noteController.text.trim()
              : null,
          createdAt: DateTime.now(),
        );

        context.read<TransactionBloc>().add(
              AddTransactionRequested(
                userId: authState.user.uid,
                transaction: transaction,
              ),
            );

        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = _type == 'expense' ? _expenseCategories : _incomeCategories;

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Thêm Giao Dịch Mới',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Segmented Button: Expense vs Income
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _type = 'expense';
                            _category = _expenseCategories.first;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _type == 'expense'
                                ? AppColors.expense
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Khoản Chi (-)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _type = 'income';
                            _category = _incomeCategories.first;
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _type == 'income'
                                ? AppColors.income
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              'Khoản Thu (+)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              CustomTextField(
                controller: _titleController,
                labelText: 'Tên giao dịch',
                hintText: 'VD: Ăn sáng Phở Bò, Tiền lương...',
                prefixIcon: Icons.edit_note_outlined,
                validator: (val) => val == null || val.trim().isEmpty ? 'Nhập tên giao dịch' : null,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                controller: _amountController,
                labelText: 'Số tiền (VNĐ)',
                hintText: 'VD: 50000',
                prefixIcon: Icons.attach_money_outlined,
                keyboardType: TextInputType.number,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Nhập số tiền';
                  if (double.tryParse(val.trim()) == null) return 'Số tiền không hợp lệ';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Category Selector
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Danh mục',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _category,
                    dropdownColor: AppColors.cardDark,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppColors.cardDark.withValues(alpha: 0.6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                      ),
                    ),
                    items: categories.map((cat) {
                      return DropdownMenuItem(
                        value: cat,
                        child: Text(cat),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _category = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              CustomButton(
                text: 'Lưu Giao Dịch',
                gradient: _type == 'income'
                    ? AppColors.incomeGradient
                    : AppColors.expenseGradient,
                onPressed: _onSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
