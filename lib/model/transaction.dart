import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

@JsonSerializable()
class TransactionData {
  String id;
  Timestamp? startTime;
  Timestamp? paymentTime;
  String? currency;
  double amount;
  double? cash;
  double? change;
  String? status;
  String? shopperid;

  TransactionData(
      {required this.id,
      this.startTime,
      this.paymentTime,
      this.currency,
      required this.amount,
      this.cash,
      this.change,
      this.status,
      this.shopperid});
}
