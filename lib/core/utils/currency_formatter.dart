import 'package:intl/intl.dart';

class CurrencyFormatter {
  static String formatVND(double amount, {bool showSymbol = true}) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: showSymbol ? '₫' : '',
      decimalDigits: 0,
    );
    return formatter.format(amount).trim();
  }

  static String formatUSD(double amount, {bool showSymbol = true}) {
    final formatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: showSymbol ? '\$' : '',
      decimalDigits: 2,
    );
    return formatter.format(amount).trim();
  }

  static String formatCompact(double amount) {
    if (amount >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}
