import 'package:intl/intl.dart';
import '../config/app_constants.dart';

class Formatters {
  static final NumberFormat _money = NumberFormat.decimalPattern('en_IN');

  static String money(num value) =>
      '${AppConstants.currencySymbol}${_money.format(value.round())}';

  static String compact(num value) {
    if (value >= 10000000) return '${AppConstants.currencySymbol}${(value / 10000000).toStringAsFixed(1)}Cr';
    if (value >= 100000) return '${AppConstants.currencySymbol}${(value / 100000).toStringAsFixed(1)}L';
    if (value >= 1000) return '${AppConstants.currencySymbol}${(value / 1000).toStringAsFixed(1)}k';
    return money(value);
  }

  static String percent(double v) => '${(v * 100).toStringAsFixed(0)}%';
}
