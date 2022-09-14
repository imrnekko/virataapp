import 'package:flutter/material.dart';
import 'package:virata_app/model/item.dart';
import 'package:virata_app/model/transaction.dart';
import 'package:virata_app/screen/home/edititem.dart';

class TransactionListTile extends StatelessWidget {
  final TransactionData trans;
  TransactionListTile({required this.trans});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.0),
      child: Card(
        margin: EdgeInsets.all(10),
        child: ListTile(
          onLongPress: () {},
          contentPadding: EdgeInsets.only(right: 30, left: 36),
          title: Text(trans.id.toString()),
          trailing: Text("RM " + (trans.amount.toStringAsFixed(2)).toString()),
          subtitle: Text(trans.shopperid.toString() + " unit"),
        ),
      ),
    );
  }
}
