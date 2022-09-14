import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:virata_app/class/Constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:virata_app/model/item.dart';
import 'package:virata_app/model/transaction.dart';
import 'package:virata_app/screen/empty.dart';
import 'package:virata_app/screen/home/dashboard.dart';
import 'package:virata_app/screen/home/settings.dart';
import 'package:virata_app/screen/home/shoppingsession.dart';
import 'package:virata_app/screen/loading.dart';
import 'package:virata_app/services/auth.dart';
import 'package:virata_app/services/database.dart';
import 'package:virata_app/services/transactionsession.dart';

class ViewTransaction extends StatefulWidget {
  ViewTransaction({Key? key, required this.transid}) : super(key: key);
  String transid;
  @override
  _ViewTransactionState createState() => _ViewTransactionState();
}

class _ViewTransactionState extends State<ViewTransaction> {
  @override
  void initState() {
    super.initState();
    print(widget.transid);
  }

  @override
  Widget build(BuildContext context) {
    String sessionID = AuthService().getUserID();

    var transactionid = widget.transid.toString();
    var transactioncurrency;
    final _formKey = GlobalKey<FormState>();

    void _showItemCart(String userid, String transid, String currency) {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              child: Center(
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('shopper')
                      .doc(sessionID)
                      .collection('transaction')
                      .doc(transactionid)
                      .collection('item')
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    int count = 0;

                    if (!snapshot.hasData) {
                      return Loading();
                    }
                    var listview = ListView(
                      children: snapshot.data!.docs.map((items) {
                        count += 1;
                        return Card(
                          elevation: 10.00,
                          margin: EdgeInsets.all(0.50),
                          child: ListTile(
                            title: Text(
                              items['name'].toString(),
                            ),
                            subtitle: Text(
                              currency +
                                  " " +
                                  (items['priceperunit'] * items['quantity'])
                                      .toStringAsFixed(2),
                            ),
                            trailing: Text(
                              items['quantity'].toString() + " unit",
                            ),
                          ),
                        );
                      }).toList(),
                    );

                    if (count == 0) {
                      return Empty(type: "item2");
                    } else {
                      return listview;
                    }
                  },
                ),
              ),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            );
          });
    }

    //Start main body

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Virata",
          style: TextStyle(
            fontFamily: 'stereofunk',
            fontSize: 24,

            //letterSpacing: 1.5,
          ),
        ),
        elevation: 4.0,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                DatabaseService(uid: sessionID, transid: transactionid)
                    .deleteTransaction();
                Navigator.pop(context, true);
              })
        ],
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      //backgroundColor: Colors.grey[100],
      body: StreamBuilder<TransactionData>(
          stream:
              DatabaseService(uid: sessionID.toString(), transid: transactionid)
                  .transData,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              transactioncurrency = snapshot.data!.currency.toString();
              return Card(
                shape: new RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(20.0),
                ),
                child: Container(
                  margin: EdgeInsets.only(top: 20),
                  alignment: Alignment.center,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        Text(
                          'Transaction ID: $transactionid',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 20),
                        Card(
                          elevation: 10.00,
                          margin: EdgeInsets.all(0.50),
                          child: ListTile(
                            title: Text("Start Time"),
                            subtitle: Text(DateFormat('dd MMMM yyyy, hh:mm a')
                                .format(snapshot.data!.startTime!.toDate())
                                .toString()),
                          ),
                        ),
                        Card(
                          elevation: 10.00,
                          margin: EdgeInsets.all(0.50),
                          child: ListTile(
                            title: Text("Payment Time"),
                            subtitle: Text(DateFormat('dd MMMM yyyy, hh:mm a')
                                .format(snapshot.data!.paymentTime!.toDate())
                                .toString()),
                          ),
                        ),
                        Card(
                          elevation: 10.00,
                          margin: EdgeInsets.all(0.50),
                          child: ListTile(
                            title: Text("Transaction Status"),
                            subtitle: Text(snapshot.data!.status.toString()),
                          ),
                        ),
                        Card(
                          elevation: 10.00,
                          margin: EdgeInsets.all(0.50),
                          child: ListTile(
                            title: Text("Total Payment"),
                            trailing: Text(snapshot.data!.currency.toString() +
                                snapshot.data!.amount.toStringAsFixed(2)),
                          ),
                        ),
                        Card(
                          elevation: 10.00,
                          margin: EdgeInsets.all(0.50),
                          child: ListTile(
                            title: Text("Cash"),
                            trailing: Text(snapshot.data!.currency.toString() +
                                snapshot.data!.cash!.toStringAsFixed(2)),
                          ),
                        ),
                        Card(
                          elevation: 10.00,
                          margin: EdgeInsets.all(0.50),
                          child: ListTile(
                            title: Text("Change"),
                            trailing: Text(snapshot.data!.currency.toString() +
                                snapshot.data!.change!.toStringAsFixed(2)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return Loading();
            }
          }),
      floatingActionButton: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(20.0),
            ),
            padding: EdgeInsets.all(20.0)),
        label: Text(
          "View item",
          style: TextStyle(
            fontFamily: 'Tahoma',
            fontSize: 20,
            letterSpacing: 0.5,
          ),
        ),
        icon: FaIcon(
          FontAwesomeIcons.cartArrowDown,
          color: Colors.white,
        ),
        onPressed: () {
          _showItemCart(sessionID, transactionid, transactioncurrency);
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
                    TransactionSession.removeAll();
                    Navigator.of(context).pushReplacement(
                      new MaterialPageRoute(
                          settings: const RouteSettings(name: '/dashboard'),
                          builder: (context) => Dashboard()),
                    );
                  })
            ],
          );
        },
      );
    }
  }
}
