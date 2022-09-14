//import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:virata_app/class/Constants.dart';
import 'package:virata_app/model/transaction.dart';
import 'package:virata_app/screen/authenticate/login-screen.dart';
import 'package:virata_app/screen/empty.dart';
import 'package:virata_app/screen/home/dashboard.dart';
import 'package:virata_app/screen/home/myprofile.dart';
import 'package:virata_app/screen/home/settings.dart';
import 'package:virata_app/screen/home/transactionlist.dart';
import 'package:virata_app/screen/home/transactionlisttile.dart';
import 'package:virata_app/screen/home/viewtransaction.dart';
import 'package:virata_app/screen/loading.dart';
import 'package:virata_app/services/auth.dart';
import 'package:virata_app/services/database.dart';
import 'package:virata_app/services/worldtime.dart';

class TransactionHistory extends StatefulWidget {
  _TransactionHistoryState createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  @override
  void initState() {
    super.initState();
  }

  String sessionID = AuthService().getUserID();

  Widget build(BuildContext context) {
    var shopperRef =
        FirebaseFirestore.instance.collection('shopper').doc(sessionID).get();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('shopper')
          .doc(sessionID)
          .collection('transaction')
          .orderBy('startTime', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Loading();
        }

        int index = 0;

        //trans.add(snapshot.data);
        var listview = ListView(
          children: snapshot.data!.docs.map((DocumentSnapshot document) {
            if (document['status'] == "Success") {
              index += 1;
              return Card(
                elevation: 10.00,
                margin: EdgeInsets.all(0.50),
                child: ListTile(
                  title: Text(document.id.toString()),
                  subtitle: Text(DateFormat('dd MMMM yyyy, hh:mm a')
                      .format(document['startTime'].toDate())
                      .toString()),
                  trailing: Text(document['currency'].toString() +
                      document['amount'].toStringAsFixed(2)),
                  onLongPress: () {
                    DatabaseService(uid: sessionID, transid: document.id)
                        .deleteTransaction();
                  },
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => ViewTransaction(
                                transid: document.id.toString())));
                  },
                ),
              );
            } else {
              return Container();
            }
          }).toList(),
        );

        if (index == 0) {
          return Empty(type: "transaction");
        } else {
          return listview;
        }
      },
    );
  }

  void choiceAction(String choice) {
    if (choice == Constants.EndSession) {
      print('End Session');
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MyProfile()),
      );
    }
  }
}
