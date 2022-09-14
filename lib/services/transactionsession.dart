import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

class TransactionSession {
  static SharedPreferences? _preferences;

  static const _startTime = 'startTime';

  static const _id = 'transactionID';

  static const _currency = 'currency';

  static const _totalPrice = 'totalPriceFromBudget';

  static const _totalPriceFromBudget = 'totalPriceFromBudget';

  static const _totalCash = 'totalCash';

  static Future init() async =>
      _preferences = await SharedPreferences.getInstance();

  static Future setID(String id) async {
    await _preferences?.setString(_id, id);
  }

  static String? getID() {
    return _preferences?.getString(_id);
  }

  static Future removeID() async {
    await _preferences?.remove(_id);
  }

  static Future setCurrency(String currency) async {
    await _preferences?.setString(_currency, currency);
  }

  static String? getCurrency() {
    return _preferences?.getString(_currency);
  }

  static Future setStartTime() async {
    await _preferences?.setString(_startTime, DateTime.now().toString());
  }

  static String? getStartTime() {
    return _preferences?.getString(_startTime);
  }

  static Future removeStartTime() async {
    await _preferences?.remove(_startTime);
  }

  static Future setTotalPriceFromBudget(double totalPrice) async {
    await _preferences?.setDouble(_totalPriceFromBudget, totalPrice);
  }

  static double? getTotalPriceFromBudget() {
    return _preferences?.getDouble(_totalPriceFromBudget);
  }

  static Future removeTotalPriceFromBudget() async {
    await _preferences?.remove(_totalPriceFromBudget);
  }

  static Future setTotalPrice(double totalPrice) async {
    await _preferences?.setDouble(_totalPrice, totalPrice);
  }

  static double? getTotalPrice() {
    return _preferences?.getDouble(_totalPrice);
  }

  static Future removeTotalPrice() async {
    await _preferences?.remove(_totalPrice);
  }

  static Future setCashPrice(double cash) async {
    await _preferences?.setDouble(_totalCash, cash);
  }

  static double? getCashPrice() {
    return _preferences?.getDouble(_totalCash);
  }

  static Future removeCashPrice() async {
    await _preferences?.remove(_totalCash);
  }

  //remove all
  static Future removeAll() async {
    await _preferences?.remove(_id);
    await _preferences?.remove(_startTime);
    await _preferences?.remove(_totalPrice);
    await _preferences?.remove(_totalPriceFromBudget);
    await _preferences?.remove(_totalCash);
  }
}
