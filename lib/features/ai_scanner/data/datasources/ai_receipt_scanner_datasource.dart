import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import '../../../../app/config/env_config.dart';
import '../../../../core/errors/failures.dart';

class AiReceiptResult {
  final String storeName;
  final double totalAmount;
  final DateTime date;
  final String category;
  final List<String> items;

  AiReceiptResult({
    required this.storeName,
    required this.totalAmount,
    required this.date,
    required this.category,
    required this.items,
  });

  factory AiReceiptResult.fromJson(Map<String, dynamic> json) {
    return AiReceiptResult(
      storeName: json['storeName'] as String? ?? 'Cửa hàng',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null
          ? DateTime.tryParse(json['date'] as String) ?? DateTime.now()
          : DateTime.now(),
      category: json['category'] as String? ?? 'Ăn uống',
      items: (json['items'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}

class AiReceiptScannerDataSource {
  Future<AiReceiptResult> scanReceipt(Uint8List imageBytes) async {
    final apiKey = EnvConfig.geminiApiKey;
    if (apiKey.isEmpty) {
      throw const AiProcessingFailure('Chưa cấu hình Gemini API Key.');
    }

    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
      );

      const prompt = '''
Phân tích hóa đơn chi tiêu trong hình ảnh này và bóc tách dữ liệu dưới dạng JSON thuần túy (KHÔNG dùng markdown, KHÔNG dùng ```json).
Định dạng JSON bắt buộc:
{
  "storeName": "Tên cửa hàng hoặc nhà hàng",
  "totalAmount": 150000,
  "date": "2026-08-26",
  "category": "Ăn uống",
  "items": ["Tên món 1", "Tên món 2"]
}
Lưu ý: 
- "category" phải chọn 1 trong các giá trị: "Ăn uống", "Mua sắm", "Hóa đơn & Điện nước", "Giải trí", "Di chuyển", "Khác".
- "totalAmount" là số tiền tổng cộng cần thanh toán (số thực).
''';

      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/jpeg', imageBytes),
        ])
      ];

      final response = await model.generateContent(content);
      final text = response.text?.trim() ?? '';

      debugPrint('Gemini Raw Response: $text');

      // Clean JSON if Gemini wrapped in codeblock
      String jsonStr = text;
      if (jsonStr.startsWith('```json')) {
        jsonStr = jsonStr.replaceAll('```json', '').replaceAll('```', '').trim();
      } else if (jsonStr.startsWith('```')) {
        jsonStr = jsonStr.replaceAll('```', '').trim();
      }

      final Map<String, dynamic> data = jsonDecode(jsonStr);
      return AiReceiptResult.fromJson(data);
    } catch (e) {
      debugPrint('AI Scan Error: $e');
      throw AiProcessingFailure('AI bóc tách hóa đơn không thành công: ${e.toString()}');
    }
  }
}
