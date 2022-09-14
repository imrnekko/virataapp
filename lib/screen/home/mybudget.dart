import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:virata_app/class/Constants.dart';
import 'package:virata_app/model/item.dart';
import 'package:virata_app/screen/empty.dart';
import 'package:virata_app/screen/home/additem.dart';
import 'package:virata_app/screen/home/dashboard.dart';
import 'package:virata_app/screen/home/edititem.dart';
import 'package:virata_app/screen/loading.dart';
import 'package:virata_app/services/auth.dart';
import 'package:virata_app/services/database.dart';
import 'package:virata_app/services/transactionsession.dart';

class Budget extends StatefulWidget {
  _BudgetState createState() => _BudgetState();
}

class _BudgetState extends State<Budget> {
  /*DatabaseService? db;
  List items = [];
  initialise() {
    db = DatabaseService();
    db!.initiliase();
  }*/

  /*@override
  void initState() {
    super.initState();
    initialise();
  }*/

  /*Widget itemcartTemplate(items) {
    return Card(
      margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  items['name'].toString(),
                  style: TextStyle(
                      fontSize: 18,
                      fontFamily: "Tahoma",
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  "RM" +
                      (items['priceperunit'] * items['quantity'])
                          .toStringAsFixed(2),
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "Aero",
                    color: Colors.green[800],
                  ),
                ),
              ],
            ),
            Text(
              items['quantity'].toString() + " unit",
              textAlign: TextAlign.left,
              style: TextStyle(
                  fontSize: 16,
                  fontFamily: "Tahoma",
                  fontWeight: FontWeight.bold),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  tooltip: 'Edit item details',
                  onPressed: () {
                    /*Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditItem(
                                itemCart: docs[1],
                                db: db!,
                              )),
                    );*/
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Delete item',
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Center(child: Text('Delete item?')),
                          // Retrieve the text the that user has entered by using the
                          // TextEditingController.
                          content: Text("Delete item '" +
                              items['name'].toString() +
                              " x " +
                              items['quantity'].toString() +
                              "'?"),
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
                                  items.reference.delete();
                                })
                          ],
                        );
                      },
                    );
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    String sessionID = AuthService().getUserID();
    return Scaffold(
      backgroundColor: Colors.blue,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('shopper')
            .doc(sessionID)
            .collection('transaction')
            .doc(TransactionSession.getID().toString())
            .collection('item')
            .snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          int count = 0;
          double sum = 0;

          if (!snapshot.hasData) {
            return Loading();
          }

          var listview = ListView.builder(
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                sum += double.parse(
                        snapshot.data!.docs[index]['priceperunit'].toString()) *
                    int.parse(
                        snapshot.data!.docs[index]['quantity'].toString());

                TransactionSession.setTotalPriceFromBudget(sum);

                return Card(
                  elevation: 10.00,
                  margin: EdgeInsets.all(0.50),
                  child: ListTile(
                      title: Text(
                        snapshot.data!.docs[index]['name'].toString(),
                      ),
                      subtitle: Text(
                        TransactionSession.getCurrency().toString() +
                            " " +
                            (snapshot.data!.docs[index]['priceperunit'] *
                                    snapshot.data!.docs[index]['quantity'])
                                .toStringAsFixed(2),
                      ),
                      trailing: Text(
                        snapshot.data!.docs[index]['quantity'].toString() +
                            " unit",
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => EditItem(
                                      currency: TransactionSession.getCurrency()
                                          .toString(),
                                      itemid: snapshot.data!.docs[index].id,
                                      itemname: snapshot.data!.docs[index]
                                          ['name'],
                                      qty: snapshot
                                          .data!.docs[index]['quantity']
                                          .toString(),
                                      price: double.parse(snapshot
                                              .data!.docs[index]['priceperunit']
                                              .toString())
                                          .toStringAsFixed(2),
                                    )));
                      }),
                );
              });

          if (snapshot.data!.docs.length == 0) {
            TransactionSession.removeTotalPriceFromBudget();
            return Empty(type: "item1");
          } else {
            return listview;
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: FaIcon(
          FontAwesomeIcons.plus,
          color: Colors.white,
        ),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => AddItem(
                      currency: TransactionSession.getCurrency().toString())));
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
                    Navigator.of(context).pushAndRemoveUntil(
                      new MaterialPageRoute(
                          settings: const RouteSettings(name: '/dashboard'),
                          builder: (context) => Dashboard()),
                      (Route<dynamic> route) => false,
                    );
                  })
            ],
          );
        },
      );
    }
  }
}
