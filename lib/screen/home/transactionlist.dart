import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:virata_app/class/Constants.dart';
import 'package:virata_app/model/transaction.dart';
import 'package:virata_app/screen/home/dashboard.dart';
import 'package:virata_app/screen/home/transactionlisttile.dart';
import 'package:virata_app/screen/loading.dart';
import 'package:virata_app/services/database.dart';

class TransactionList extends StatefulWidget {
  _TransactionListState createState() => _TransactionListState();
}

class _TransactionListState extends State<TransactionList> {
  @override
  Widget build(BuildContext context) {
    final trans = Provider.of<List<TransactionData>>(context);
    //var trans1;
    /*if (trans != null) {
      trans1 = trans;
    }*/

    return Scaffold(
      backgroundColor: Colors.blue,
      body: ListView.builder(
        itemCount: trans.length,
        itemBuilder: (BuildContext context, int index) {
          return TransactionListTile(trans: trans[index]);
        },
      ),
    );
  }

  void choiceAction(String choice) {
    if (choice == Constants.EndSession) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Center(child: Text('End Session')),
            // Retrieve the text the that user has entered by using the
            // TextEditingController.
            content: Text("Are you sure?"),
            actions: <Widget>[
              TextButton(
                  child: Text('No'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  }),
              TextButton(
                  child: Text('Yes'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    print('End Session');
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Dashboard()),
                    );
                  })
            ],
          );
        },
      );
    }
  }
}
