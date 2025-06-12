import 'package:shared_preferences/shared_preferences.dart';

class CurrencyHelper {
  static Future<String> getCurrency() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('currency') ?? 'EUR';
  }

  static String currencySymbol(String currency) {
    return currency == 'USD' ? '\$' : '€';
  }
}
