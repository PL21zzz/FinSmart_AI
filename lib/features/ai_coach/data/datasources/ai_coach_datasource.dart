import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../app/config/env_config.dart';
import '../../../../core/errors/failures.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';

class ChatMessage {
  final String sender; // 'user' | 'ai'
  final String text;
  final DateTime timestamp;

  ChatMessage({
    required this.sender,
    required this.text,
    required this.timestamp,
  });
}

class AiCoachDataSource {
  ChatSession? _chatSession;

  Future<String> sendMessage({
    required String message,
    required List<TransactionEntity> currentTransactions,
    required double monthlyBudget,
  }) async {
    final apiKey = EnvConfig.geminiApiKey;
    if (apiKey.isEmpty) {
      throw const AiProcessingFailure('Chưa cấu hình Gemini API Key.');
    }

    try {
      if (_chatSession == null) {
        final model = GenerativeModel(
          model: 'gemini-1.5-flash',
          apiKey: apiKey,
        );

        // Calculate summary for context
        double totalExpense = 0;
        double totalIncome = 0;
        final categoryTotals = <String, double>{};

        for (var t in currentTransactions) {
          if (t.type == 'expense') {
            totalExpense += t.amount;
            categoryTotals[t.category] = (categoryTotals[t.category] ?? 0) + t.amount;
          } else {
            totalIncome += t.amount;
          }
        }

        final systemPrompt = '''
Bạn là "FinSmart AI Coach" - Trợ lý cố vấn tài chính cá nhân thông minh, thân thiện, chuyên nghiệp.
Dưới đây là thông tin tài chính thực tế của người dùng tháng này:
- Ngân sách tháng: ${monthlyBudget.toInt()} VNĐ
- Tổng thu nhập: ${totalIncome.toInt()} VNĐ
- Tổng chi tiêu: ${totalExpense.toInt()} VNĐ
- Dư còn lại: ${(totalIncome - totalExpense).toInt()} VNĐ
- Phân bổ chi tiêu theo danh mục: $categoryTotals

Nhiệm vụ của bạn:
1. Trả lời câu hỏi của người dùng ngắn gọn, hữu ích bằng tiếng Việt.
2. Đưa ra lời khuyên quản lý tài chính thực tế dựa trên số liệu trên.
3. Luôn giữ thái độ tích cực, khích lệ người dùng tiết kiệm thông minh.
''';

        _chatSession = model.startChat(
          history: [
            Content.text(systemPrompt),
            Content.model([TextPart('Chào bạn! Tôi là FinSmart AI Coach. Tôi sẵn sàng hỗ trợ bạn quản lý tài chính hôm nay!')]),
          ],
        );
      }

      final response = await _chatSession!.sendMessage(Content.text(message));
      return response.text?.trim() ?? 'Tôi không thể trả lời ngay bây giờ, vui lòng thử lại sau.';
    } catch (e) {
      debugPrint('AI Coach Error: $e');
      throw AiProcessingFailure('Lỗi kết nối AI Coach: ${e.toString()}');
    }
  }

  void resetSession() {
    _chatSession = null;
  }
}
