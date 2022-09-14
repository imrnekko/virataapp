import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:virata_app/class/Constants.dart';
import 'package:virata_app/model/bills.dart';
import 'package:virata_app/model/transaction.dart';
import 'package:virata_app/model/wallet.dart';
import 'package:virata_app/screen/authenticate/login-screen.dart';
import 'package:virata_app/screen/home/dashboard.dart';
import 'package:virata_app/screen/home/displayquantity.dart';
import 'package:virata_app/screen/home/function/calcpayment.dart';
import 'package:virata_app/screen/home/myprofile.dart';
import 'package:virata_app/screen/home/returnbalance.dart';
import 'package:virata_app/screen/home/settings.dart';
import 'package:virata_app/screen/home/transactionlist.dart';
import 'package:virata_app/screen/loading.dart';
import 'package:virata_app/services/auth.dart';
import 'package:virata_app/services/database.dart';
import 'package:virata_app/services/transactionsession.dart';

class PaymentBillsScreen extends StatefulWidget {
  final double totalPayment;
  const PaymentBillsScreen({Key? key, required this.totalPayment})
      : super(key: key);

  @override
  _PaymentBillsState createState() => _PaymentBillsState();
}

class _PaymentBillsState extends State<PaymentBillsScreen> {
  String sessionID = AuthService().getUserID();

  List<int?> needQty = [];
  @override
  Widget build(BuildContext context) {
    String sessionID = AuthService().getUserID();

    Future<Widget> _getImage(BuildContext context, String imageName) async {
      Image image;
      return await FireStorageService.loadImage(context, imageName)
          .then((value) {
        return image = Image.network(
          value.toString(),
          fit: BoxFit.scaleDown,
          width: 300,
        );
      });
    }

    List<Bills> billsList = [];
    List<Bills> remainingBillsList1 = [];
    List<Bills> remainingBillsList2 = [];

    double? totalPaymentAmt = widget.totalPayment;
    String totalPaymentAmtStr = totalPaymentAmt.toStringAsFixed(2);

    double decimalVal = double.parse(totalPaymentAmt.toStringAsFixed(2)) -
        double.parse(totalPaymentAmt.toStringAsFixed(0));
    decimalVal = decimalVal.abs();
    print(decimalVal.toStringAsFixed(2));

    double cashAmt = 0;
    double cashAmt1 = 0;
    double cashAmt2 = 0;

    return StreamBuilder<Wallet>(
        stream: DatabaseService(
                uid: sessionID.toString(), wallet_id: sessionID + "RM")
            .walletData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Wallet? walletdata = snapshot.data;
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
                actions: <Widget>[
                  PopupMenuButton<String>(
                    onSelected: choiceAction,
                    itemBuilder: (BuildContext context) {
                      return Constants.choices.map((String choice) {
                        return PopupMenuItem<String>(
                          value: choice,
                          child: Text(choice),
                        );
                      }).toList();
                    },
                  )
                ],
                centerTitle: true,
                backgroundColor: Colors.blue,
              ),
              body: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('shopper')
                      .doc(sessionID)
                      .collection('wallet')
                      .doc(snapshot.data!.walletid)
                      .collection('bills')
                      .orderBy('value', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Loading();
                    } else {
                      double tempAmt = totalPaymentAmt;
                      double tempAmt2 = totalPaymentAmt;
                      return Center(
                        child: Column(
                          /*child: Image.network(
            'https://s4.anilist.co/file/anilistcdn/character/large/b14-9Kb1E5oel1ke.png'),*/

                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            SizedBox(
                              height: 25,
                            ),
                            Container(
                                padding: EdgeInsets.all(15),
                                child: Column(
                                  children: [
                                    Text(
                                      "You have to pay",
                                      style: TextStyle(
                                        fontFamily: 'Tahoma',
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      child: Text(
                                        "RM $totalPaymentAmtStr",
                                        style: TextStyle(
                                          fontFamily: 'Aero',
                                          fontSize: 25,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  ],
                                )),
                            Visibility(
                              child: Expanded(
                                  flex: 3,
                                  child: Container(
                                      child: ListView(
                                    children: snapshot.data!.docs
                                        .map((DocumentSnapshot document) {
                                      Bills needBills = calcPayment(
                                          tempAmt,
                                          walletdata!.amount,
                                          document['value'],
                                          document['quantity']);

                                      if (document['quantity'] > 0 &&
                                          needBills.quantity! > 0) {
                                        tempAmt = tempAmt -
                                            (document['value'] *
                                                needBills.quantity);

                                        //assign need quantity to _showBillsDisplay
                                        needQty.add(needBills.quantity);

                                        needBills.image = document['image'];
                                        needBills.currency =
                                            document['currency'];

                                        tempAmt = roundDouble(tempAmt, 1);

                                        print(tempAmt);

                                        cashAmt1 += (document['value'] *
                                            needBills.quantity);

                                        var cashTile = GestureDetector(
                                          onTap: () {
                                            showModalBottomSheet(
                                                context: context,
                                                builder: (context) {
                                                  return Container(
                                                    child: DisplayQuantity(
                                                      needQty:
                                                          needBills.quantity,
                                                      currencyCode:
                                                          TransactionSession
                                                              .getCurrency(),
                                                      imageStr:
                                                          document['image'],
                                                    ),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 20,
                                                            horizontal: 20),
                                                  );
                                                });
                                          },
                                          child: Card(
                                            elevation: 10.00,
                                            margin: EdgeInsets.all(0.50),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                FutureBuilder<Widget>(
                                                  future: _getImage(
                                                      context,
                                                      document['image']
                                                          .toString()),
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState.done) {
                                                      return Container(
                                                        child: snapshot.data,
                                                        width: 80,
                                                        //height: 60,
                                                      );
                                                    }

                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return Container(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      );
                                                    }

                                                    return Container();
                                                  },
                                                ),
                                                Container(
                                                  width: 50,
                                                  child: Text(needBills.quantity
                                                      .toString()),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );

                                        billsList.add(needBills);

                                        Bills remBills = Bills(
                                            value: document['value'],
                                            quantity: document['quantity'] -
                                                needBills.quantity,
                                            currency: document['currency']);

                                        remainingBillsList1.add(remBills);

                                        if (document['value'] == 0.05 &&
                                            cashAmt1 < totalPaymentAmt) {
                                          cashAmt1 = 0;
                                        }

                                        return cashTile;
                                      } else {
                                        if (document['value'] == 0.05 &&
                                            cashAmt1 < totalPaymentAmt) {
                                          cashAmt1 = 0;
                                        }
                                        return Container();
                                      }
                                    }).toList(),
                                  ))),
                              visible:
                                  (cashAmt1 < totalPaymentAmt) ? false : true,
                            ),
                            Visibility(
                              child: Expanded(
                                  flex: 3,
                                  child: Container(
                                      child: ListView(
                                    children: snapshot.data!.docs
                                        .map((DocumentSnapshot document) {
                                      Bills needBills = calcPayment2(
                                          tempAmt2,
                                          walletdata!.amount,
                                          document['value'],
                                          document['quantity']);

                                      if (document['quantity'] > 0 &&
                                          needBills.quantity! > 0) {
                                        tempAmt2 = tempAmt2 -
                                            (document['value'] *
                                                needBills.quantity);

                                        //assign need quantity to _showBillsDisplay
                                        needQty.add(needBills.quantity);

                                        needBills.image = document['image'];
                                        needBills.currency =
                                            document['currency'];

                                        tempAmt2 = roundDouble(tempAmt2, 1);

                                        print(tempAmt2);

                                        cashAmt2 += (document['value'] *
                                            needBills.quantity);

                                        var cashTile = GestureDetector(
                                          onTap: () {
                                            showModalBottomSheet(
                                                context: context,
                                                builder: (context) {
                                                  return Container(
                                                    child: DisplayQuantity(
                                                      needQty:
                                                          needBills.quantity,
                                                      currencyCode:
                                                          TransactionSession
                                                              .getCurrency(),
                                                      imageStr:
                                                          document['image'],
                                                    ),
                                                    padding:
                                                        EdgeInsets.symmetric(
                                                            vertical: 20,
                                                            horizontal: 20),
                                                  );
                                                });
                                          },
                                          child: Card(
                                            elevation: 10.00,
                                            margin: EdgeInsets.all(0.50),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                FutureBuilder<Widget>(
                                                  future: _getImage(
                                                      context,
                                                      document['image']
                                                          .toString()),
                                                  builder: (context, snapshot) {
                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState.done) {
                                                      return Container(
                                                        child: snapshot.data,
                                                        width: 80,
                                                        //height: 60,
                                                      );
                                                    }

                                                    if (snapshot
                                                            .connectionState ==
                                                        ConnectionState
                                                            .waiting) {
                                                      return Container(
                                                        child:
                                                            CircularProgressIndicator(),
                                                      );
                                                    }

                                                    return Container();
                                                  },
                                                ),
                                                Container(
                                                  width: 50,
                                                  child: Text(needBills.quantity
                                                      .toString()),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );

                                        billsList.add(needBills);

                                        Bills remBills = Bills(
                                            value: document['value'],
                                            quantity: document['quantity'] -
                                                needBills.quantity,
                                            currency: document['currency']);

                                        remainingBillsList2.add(remBills);

                                        if (document['value'] == 0.05 &&
                                            cashAmt1 >= totalPaymentAmt) {
                                          cashAmt2 = 0;
                                        }

                                        return cashTile;
                                      } else {
                                        if (document['value'] == 0.05 &&
                                            cashAmt1 >= totalPaymentAmt) {
                                          cashAmt2 = 0;
                                        }

                                        return Container();
                                      }
                                    }).toList(),
                                  ))),
                              visible:
                                  (cashAmt1 < totalPaymentAmt) ? true : false,
                            ),
                            Expanded(
                                child: Text(
                              "\nYou expected to give : RM${(cashAmt1 + cashAmt2).toStringAsFixed(2)}",
                              style: TextStyle(
                                fontFamily: 'Tahoma',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                            Expanded(
                                child: Text(
                              "Your expected balance : RM${((cashAmt1 + cashAmt2) - totalPaymentAmt).toStringAsFixed(2)}",
                              style: TextStyle(
                                fontFamily: 'Tahoma',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                          ],
                        ),
                      );
                    }
                  }),
              floatingActionButton: FloatingActionButton(
                child: FaIcon(
                  FontAwesomeIcons.moneyBill,
                  color: Colors.white,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Center(child: Text('Are you sure?')),
                        // Retrieve the text the that user has entered by using the
                        // TextEditingController.
                        content: Text("Proceed to payment?"),
                        actions: <Widget>[
                          TextButton(
                              child: Text('No'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              }),
                          TextButton(
                              child: Text('Yes'),
                              onPressed: () async {
                                if (cashAmt1 > totalPaymentAmt) {
                                  for (int i = 0;
                                      i < remainingBillsList1.length;
                                      i++) {
                                    DatabaseService(
                                            uid: sessionID,
                                            wallet_id: walletdata!.walletid,
                                            bills_id: remainingBillsList1[i]
                                                    .currency
                                                    .toString() +
                                                remainingBillsList1[i]
                                                    .value
                                                    .toString())
                                        .updateBillsQty(int.parse(
                                            remainingBillsList1[i]
                                                .quantity
                                                .toString()));
                                  }
                                } else {
                                  for (int i = 0;
                                      i < remainingBillsList2.length;
                                      i++) {
                                    DatabaseService(
                                            uid: sessionID,
                                            wallet_id: walletdata!.walletid,
                                            bills_id: remainingBillsList2[i]
                                                    .currency
                                                    .toString() +
                                                remainingBillsList2[i]
                                                    .value
                                                    .toString())
                                        .updateBillsQty(int.parse(
                                            remainingBillsList2[i]
                                                .quantity
                                                .toString()));
                                  }
                                }

                                double walletAmt =
                                    walletdata!.amount! - (cashAmt1 + cashAmt2);

                                DatabaseService(
                                        uid: sessionID,
                                        wallet_id: walletdata.walletid)
                                    .updateWalletData(true, walletAmt);

                                DatabaseService(
                                        uid: sessionID,
                                        transid: TransactionSession.getID()
                                            .toString())
                                    .updatePaymentTransactionData(
                                        widget.totalPayment,
                                        (cashAmt1 + cashAmt2));

                                double balanceAmt =
                                    (cashAmt1 + cashAmt2) - totalPaymentAmt;
                                Navigator.of(context).pop();
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          new ReturnBalanceScreen(
                                            balanceAmt: balanceAmt,
                                          )),
                                  (Route<dynamic> route) => false,
                                );

                                /* Navigator.of(context).pushReplacement(
                                  new MaterialPageRoute(
                                      settings: const RouteSettings(
                                          name: 'returnbalance'),
                                      builder: (context) => ReturnBalanceScreen(
                                            balanceAmt:
                                                cashAmt - totalPaymentAmt,
                                          )),
                                );*/
                              })
                        ],
                      );
                    },
                  );
                },
              ),
            );
          } else {
            print("sesion id: " + sessionID);
            return Loading();
          }
        });
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
                    DatabaseService(
                            uid: sessionID,
                            transid: TransactionSession.getID().toString())
                        .deleteTransaction();
                    TransactionSession.removeAll();
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

  double roundDouble(double value, int places) {
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }
}

class FireStorageService extends ChangeNotifier {
  FireStorageService();
  static Future<dynamic> loadImage(BuildContext context, String Image) async {
    return await FirebaseStorage.instance.ref().child(Image).getDownloadURL();
  }
}
