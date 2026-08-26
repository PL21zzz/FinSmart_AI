import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../transaction/presentation/bloc/transaction_bloc.dart';
import '../../../transaction/presentation/bloc/transaction_state.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Báo Cáo Chi Tiêu & Ngân Sách',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransactionLoaded) {
            final authState = context.read<AuthBloc>().state;
            final monthlyBudget = authState is Authenticated
                ? authState.user.monthlyBudget
                : 10000000.0;

            final totalExpense = state.totalExpense;
            final budgetPercent = (totalExpense / monthlyBudget).clamp(0.0, 1.0);

            // Group expenses by category
            final categoryMap = <String, double>{};
            for (var t in state.transactions) {
              if (t.type == 'expense') {
                categoryMap[t.category] = (categoryMap[t.category] ?? 0) + t.amount;
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Budget Threshold Card
                  GlassCard(
                    opacity: 0.15,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Hạn Mức Ngân Sách Tháng',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${(budgetPercent * 100).toInt()}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: budgetPercent >= 0.9
                                    ? AppColors.expense
                                    : AppColors.income,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: budgetPercent,
                            minHeight: 10,
                            backgroundColor: Colors.white.withValues(alpha: 0.1),
                            color: budgetPercent >= 0.9
                                ? AppColors.expense
                                : AppColors.income,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Đã chi: ${CurrencyFormatter.formatVND(totalExpense)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondaryDark,
                              ),
                            ),
                            Text(
                              'Hạn mức: ${CurrencyFormatter.formatVND(monthlyBudget)}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondaryDark,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    'Phân Bổ Chi Tiêu Theo Danh Mục',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  if (categoryMap.isEmpty) ...[
                    const GlassCard(
                      opacity: 0.1,
                      child: Center(
                        child: Text(
                          'Chưa có dữ liệu khoản chi nào trong tháng này.',
                          style: TextStyle(color: AppColors.textSecondaryDark),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Pie Chart
                    GlassCard(
                      opacity: 0.1,
                      child: SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 40,
                            sections: categoryMap.entries.map((entry) {
                              final percentage = (entry.value / totalExpense * 100).toStringAsFixed(0);
                              return PieChartSectionData(
                                color: _getCategoryColor(entry.key),
                                value: entry.value,
                                title: '$percentage%',
                                radius: 50,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Category List breakdown
                    Column(
                      children: categoryMap.entries.map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: GlassCard(
                            opacity: 0.06,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: Row(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(entry.key),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    entry.key,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                Text(
                                  CurrencyFormatter.formatVND(entry.value),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.expense,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Ăn uống':
        return const Color(0xFF10B981);
      case 'Mua sắm':
        return const Color(0xFF3B82F6);
      case 'Hóa đơn & Điện nước':
        return const Color(0xFFF59E0B);
      case 'Giải trí':
        return const Color(0xFF8B5CF6);
      case 'Di chuyển':
        return const Color(0xFFEC4899);
      default:
        return const Color(0xFF64748B);
    }
  }
}
