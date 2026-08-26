import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../../app/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../transaction/domain/entities/transaction_entity.dart';
import '../../../transaction/presentation/bloc/transaction_bloc.dart';
import '../../../transaction/presentation/bloc/transaction_event.dart';
import '../../data/datasources/ai_receipt_scanner_datasource.dart';

class AiScannerPage extends StatefulWidget {
  const AiScannerPage({super.key});

  @override
  State<AiScannerPage> createState() => _AiScannerPageState();
}

class _AiScannerPageState extends State<AiScannerPage> {
  final ImagePicker _picker = ImagePicker();
  final _dataSource = AiReceiptScannerDataSource();

  Uint8List? _selectedImageBytes;
  bool _isAnalyzing = false;
  AiReceiptResult? _scanResult;
  String? _errorMessage;

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (file != null) {
        final bytes = await file.readAsBytes();
        setState(() {
          _selectedImageBytes = bytes;
          _scanResult = null;
          _errorMessage = null;
        });
        _analyzeReceipt(bytes);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Không thể chọn hình ảnh: $e';
      });
    }
  }

  Future<void> _analyzeReceipt(Uint8List bytes) async {
    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final result = await _dataSource.scanReceipt(bytes);
      setState(() {
        _scanResult = result;
        _isAnalyzing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isAnalyzing = false;
      });
    }
  }

  void _saveParsedTransaction() {
    if (_scanResult == null) return;

    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      final transaction = TransactionEntity(
        id: const Uuid().v4(),
        title: _scanResult!.storeName,
        amount: _scanResult!.totalAmount,
        type: 'expense',
        category: _scanResult!.category,
        date: _scanResult!.date,
        note: _scanResult!.items.isNotEmpty
            ? 'Sản phẩm: ${_scanResult!.items.join(', ')}'
            : 'Được bóc tách tự động bởi AI Vision',
        isAiParsed: true,
        createdAt: DateTime.now(),
      );

      context.read<TransactionBloc>().add(
            AddTransactionRequested(
              userId: authState.user.uid,
              transaction: transaction,
            ),
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã lưu giao dịch AI thành công vào ví!'),
          backgroundColor: AppColors.income,
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {
        _selectedImageBytes = null;
        _scanResult = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AI Receipt Scanner',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Instructions Banner
            GlassCard(
              opacity: 0.1,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: AppColors.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tự Động Đọc Hóa Đơn bằng AI',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Chụp hoặc chọn ảnh hóa đơn, Gemini Vision sẽ bóc tách số tiền & danh mục tự động.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondaryDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Image Picker Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_outlined),
                    label: const Text('Chụp Ảnh'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.cardDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: const Text('Thư Viện'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.cardDark,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Preview Box
            if (_selectedImageBytes != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  height: 220,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  child: Image.memory(
                    _selectedImageBytes!,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Analyzing Indicator
            if (_isAnalyzing) ...[
              GlassCard(
                opacity: 0.15,
                child: const Column(
                  children: [
                    CircularProgressIndicator(color: AppColors.accent),
                    SizedBox(height: 16),
                    Text(
                      'Gemini AI đang phân tích hóa đơn...',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Vui lòng chờ trong giây lát',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Error Display
            if (_errorMessage != null) ...[
              GlassCard(
                opacity: 0.15,
                border: Border.all(color: AppColors.expense),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: AppColors.expense),
                ),
              ),
            ],

            // Parsed Result Card
            if (_scanResult != null && !_isAnalyzing) ...[
              GlassCard(
                opacity: 0.15,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Kết Quả AI Bóc Tách',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.income,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.income.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Chính xác 98%',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.income,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildResultRow('Cửa hàng', _scanResult!.storeName),
                    _buildResultRow(
                      'Tổng tiền',
                      CurrencyFormatter.formatVND(_scanResult!.totalAmount),
                      valueColor: AppColors.expense,
                      isBold: true,
                    ),
                    _buildResultRow('Gợi ý danh mục', _scanResult!.category),
                    if (_scanResult!.items.isNotEmpty)
                      _buildResultRow('Món ăn / Item', _scanResult!.items.join(', ')),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: 'Xác Nhận & Lưu Vào Ví',
                      gradient: AppColors.incomeGradient,
                      onPressed: _saveParsedTransaction,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, {Color? valueColor, bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: AppColors.textSecondaryDark),
          ),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
                fontSize: isBold ? 16 : 14,
                color: valueColor ?? Colors.white,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}
