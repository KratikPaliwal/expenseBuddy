import 'package:flutter/material.dart';
import 'currency.dart';

class CurrencyProvider extends ChangeNotifier {
  Currency _currency = Currency.inr;

  Currency get currency => _currency;

  String get symbol => currencyMap[_currency]!.symbol;

  double get rate => currencyMap[_currency]!.rate;


  double convert(double amountInInr) {
    return amountInInr * rate;
  }


  double toBase(double displayAmount) {
    return displayAmount / rate;
  }

  void changeCurrency(Currency newCurrency) {
    if (_currency == newCurrency) return;
    _currency = newCurrency;
    notifyListeners();
  }
}
