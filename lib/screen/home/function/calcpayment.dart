import 'dart:math';

import 'package:firebase_core/firebase_core.dart';
import 'package:virata_app/model/user.dart';
import 'package:virata_app/services/database.dart';

import 'package:virata_app/model/bills.dart';

int getDigitValue(int x, double number) {
  num divisor = pow(10, x - 1);
  print("divisor :" + divisor.toString());
  int result = (number / int.parse(divisor.toString())).floor() *
      int.parse(divisor.toString());
  return result;
}

double binarySearchCash(List<double> list, double x) {
  int min = 0;
  int max = list.length - 1;

  while (min <= max) {
    int mid = ((min + max) / 2).floor();
    if (x == list[mid]) {
      return x;
    } else if (x < list[mid]) {
      max = mid - 1;
      return list[mid];
    } else {
      min = mid + 1;
    }
  }

  return 0;
}

Bills calcPayment(double amount, double? wallet, double val, int qty) {
  //int amtInt = amount.toInt();
  double needQty;

  // if ((wallet! - amount) < 50) {
  //  needQty = qty.toDouble();
  //} else {
  needQty = amount / val;
  //}

  if (needQty < qty) {
  } else if (needQty > qty) {
    needQty = qty.toDouble();
  }

  int needQtyInt = 0;

  if (needQty < 1) {
    needQtyInt = 0;
  } else {
    needQtyInt = needQty.ceil();
  }

  return Bills(
    quantity: needQtyInt,
    value: val,
  );
}

Bills calcPayment2(double amount, double? wallet, double val, int qty) {
  //int amtInt = amount.toInt();
  double needQty;

  // if ((wallet! - amount) < 50) {
  //  needQty = qty.toDouble();
  //} else {
  needQty = amount / val;
  //}

  if (needQty < qty) {
  } else if (needQty > qty) {
    needQty = qty.toDouble();
  }

  int needQtyInt = 0;

  needQtyInt = needQty.ceil();

  return Bills(
    quantity: needQtyInt,
    value: val,
  );
}
