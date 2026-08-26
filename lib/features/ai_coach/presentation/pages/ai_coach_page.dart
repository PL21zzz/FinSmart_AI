import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/presentation/bloc/transaction_bloc.dart';
import '../../../transaction/presentation/bloc/transaction_state.dart';
import '../../data/datasources/ai_coach_datasource.dart';

class AiCoachPage extends StatefulWidget {
  const AiCoachPage({super.key});

  @override
  State<AiCoachPage> createState() => _AiCoachPageState();
}

class _AiCoachPageState extends State<AiCoachPage> {
  final _textController = TextEditingController();
  final _scrollController = ScrollController();
  final _dataSource = AiCoachDataSource();

  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  final List<String> _quickPrompts = [
    'Tôi nên tiết kiệm thế nào tháng này?',
    'Phân tích chi tiêu tuần này giúp tôi',
    'Tôi có đủ tiền mua laptop 15 triệu không?',
  ];

  @override
  void initState() {
    super.initState();
    _messages.add(
      ChatMessage(
        sender: 'ai',
        text: 'Xin chào! Tôi là **FinSmart AI Coach** 🤖.\nTôi đã nắm rõ thông tin chi tiêu tháng này của bạn. Bạn muốn tư vấn hoặc giải đáp thắc mắc gì nào?',
        timestamp: DateTime.now(),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    final userMessageText = text.trim();
    _textController.clear();

    setState(() {
      _messages.add(
        ChatMessage(
          sender: 'user',
          text: userMessageText,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });

    _scrollToBottom();

    final authState = context.read<AuthBloc>().state;
    final transactionState = context.read<TransactionBloc>().state;

    final currentTransactions = transactionState is TransactionLoaded
        ? transactionState.transactions
        : <TransactionEntity>[];

    final monthlyBudget = authState is Authenticated
        ? authState.user.monthlyBudget
        : 10000000.0;

    try {
      final aiResponse = await _dataSource.sendMessage(
        message: userMessageText,
        currentTransactions: currentTransactions,
        monthlyBudget: monthlyBudget,
      );

      setState(() {
        _messages.add(
          ChatMessage(
            sender: 'ai',
            text: aiResponse,
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _messages.add(
          ChatMessage(
            sender: 'ai',
            text: 'Rất tiếc, đã xảy ra lỗi kết nối AI: $e',
            timestamp: DateTime.now(),
          ),
        );
        _isLoading = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.smart_toy_outlined, color: AppColors.accent),
            SizedBox(width: 10),
            Text(
              'FinSmart AI Coach',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Quick Prompts Horizontal List
          SizedBox(
            height: 44,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickPrompts.length,
              itemBuilder: (context, index) {
                final prompt = _quickPrompts[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    label: Text(
                      prompt,
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                    backgroundColor: AppColors.cardDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    onPressed: () => _sendMessage(prompt),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // Chat Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.sender == 'user';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    mainAxisAlignment:
                        isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isUser) ...[
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.smart_toy,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: GlassCard(
                          opacity: isUser ? 0.25 : 0.1,
                          padding: const EdgeInsets.all(14),
                          borderRadius: BorderRadius.circular(16),
                          child: Text(
                            msg.text,
                            style: TextStyle(
                              fontSize: 14,
                              color: isUser ? Colors.white : AppColors.textPrimaryDark,
                            ),
                          ),
                        ),
                      ),
                      if (isUser) ...[
                        const SizedBox(width: 10),
                        const CircleAvatar(
                          radius: 16,
                          backgroundColor: AppColors.accent,
                          child: Icon(Icons.person, size: 18, color: Colors.white),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),

          if (_isLoading) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.accent,
                    ),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'AI đang suy nghĩ...',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
                  ),
                ],
              ),
            ),
          ],

          // Input Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: 'Hỏi AI Coach về tài chính...',
                      hintStyle: const TextStyle(fontSize: 14, color: AppColors.textSecondaryDark),
                      filled: true,
                      fillColor: AppColors.cardDark,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: _sendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.send_rounded, color: AppColors.accent),
                  onPressed: () => _sendMessage(_textController.text),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
