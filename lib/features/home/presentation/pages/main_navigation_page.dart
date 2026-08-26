import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../ai_coach/presentation/pages/ai_coach_page.dart';
import '../../../ai_scanner/presentation/pages/ai_scanner_page.dart';
import '../../../analytics/presentation/pages/analytics_page.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../transaction/presentation/bloc/transaction_bloc.dart';
import '../../../transaction/presentation/bloc/transaction_event.dart';
import '../../../transaction/presentation/bloc/transaction_state.dart';
import '../../../transaction/presentation/widgets/add_transaction_dialog.dart';
import '../../../transaction/presentation/widgets/transaction_card.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context
          .read<TransactionBloc>()
          .add(LoadTransactionsRequested(authState.user.uid));
    }
  }

  void _showAddTransactionModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AddTransactionDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final user = authState is Authenticated ? authState.user : null;

    final pages = [
      _buildDashboardHome(context, user?.displayName ?? 'Người dùng'),
      const AnalyticsPage(),
      const AiScannerPage(),
      const AiCoachPage(),
    ];

    return Scaffold(
      body: pages[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _showAddTransactionModal,
              backgroundColor: AppColors.accent,
              icon: const Icon(Icons.add, color: Colors.white),
              label: const Text(
                'Thêm Thu Chi',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.accent,
        unselectedItemColor: AppColors.textSecondaryDark,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Trang Chủ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.pie_chart_outline),
            activeIcon: Icon(Icons.pie_chart),
            label: 'Báo Cáo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner_outlined),
            activeIcon: Icon(Icons.qr_code_scanner),
            label: 'AI Scanner',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.smart_toy_outlined),
            activeIcon: Icon(Icons.smart_toy),
            label: 'AI Coach',
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardHome(BuildContext context, String displayName) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () {
            final authState = context.read<AuthBloc>().state;
            if (authState is Authenticated) {
              context.push('/profile');
            } else {
              context.go('/login');
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.accent,
                  child: Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Xin chào,',
                      style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                    ),
                    Text(
                      displayName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            tooltip: 'Tài khoản',
            onPressed: () {
              final authState = context.read<AuthBloc>().state;
              if (authState is Authenticated) {
                context.push('/profile');
              } else {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          if (state is TransactionLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is TransactionLoaded) {
            final transactions = state.transactions;

            return RefreshIndicator(
              onRefresh: () async {
                final authState = context.read<AuthBloc>().state;
                if (authState is Authenticated) {
                  context
                      .read<TransactionBloc>()
                      .add(LoadTransactionsRequested(authState.user.uid));
                }
              },
              child: CustomScrollView(
                slivers: [
                  // Total Balance Overview Card
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Số Dư Ròng (Net Balance)',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              CurrencyFormatter.formatVND(state.netBalance),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Sub-card Income & Expense
                            Row(
                              children: [
                                Expanded(
                                  child: Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.2),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.arrow_downward,
                                          color: Colors.greenAccent,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Tổng Thu',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          ),
                                          Text(
                                            CurrencyFormatter.formatVND(state.totalIncome),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 30,
                                  width: 1,
                                  color: Colors.white24,
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withValues(alpha: 0.2),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.arrow_upward,
                                            color: Colors.redAccent,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              'Tổng Chi',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 12,
                                              ),
                                            ),
                                            Text(
                                              CurrencyFormatter.formatVND(state.totalExpense),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Section Title
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      child: Text(
                        'Lịch Sử Giao Dịch Mới Nhất',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Empty State
                  if (transactions.isEmpty) ...[
                    const SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'Chưa có giao dịch nào. Bấm "+ Thêm Thu Chi" để bắt đầu!',
                          style: TextStyle(color: AppColors.textSecondaryDark),
                        ),
                      ),
                    ),
                  ] else ...[
                    // Transaction List
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final transaction = transactions[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: TransactionCard(
                                transaction: transaction,
                                onDelete: () {
                                  final authState = context.read<AuthBloc>().state;
                                  if (authState is Authenticated) {
                                    context.read<TransactionBloc>().add(
                                          DeleteTransactionRequested(
                                            userId: authState.user.uid,
                                            transactionId: transaction.id,
                                          ),
                                        );
                                  }
                                },
                              ),
                            );
                          },
                          childCount: transactions.length,
                        ),
                      ),
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
}
