import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virata_app/class/Constants.dart';
import 'package:virata_app/model/wallet.dart';
import 'package:virata_app/screen/authenticate/login-screen.dart';
import 'package:virata_app/screen/home/dashboard.dart';
import 'package:virata_app/screen/home/myprofile.dart';
import 'package:virata_app/screen/home/paybillsdisplay.dart';
import 'package:virata_app/screen/home/settings.dart';
import 'package:virata_app/screen/loading.dart';
import 'package:virata_app/services/auth.dart';
import 'package:virata_app/services/database.dart';
import 'package:virata_app/services/transactionsession.dart';

class KeyInPayment extends StatefulWidget {
  @override
  _KeyInPaymentState createState() => _KeyInPaymentState();
}

class _KeyInPaymentState extends State<KeyInPayment> {
  String sessionID = AuthService().getUserID();
  final notesController = TextEditingController();
  final senController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String sessionID = AuthService().getUserID();
    final _formKey = GlobalKey<FormState>();
    return StreamBuilder<Wallet>(
        stream: DatabaseService(
                uid: sessionID.toString(), wallet_id: sessionID + "RM")
            .walletData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Wallet? walletdata = snapshot.data;

            String currencyCode = walletdata!.currency.toString();

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
              //backgroundColor: Colors.grey[100],
              body: Container(
                child: Form(
                  key: _formKey,
                  child: Center(
                    child: Column(
                      /*child: Image.network(
                'https://s4.anilist.co/file/anilistcdn/character/large/b14-9Kb1E5oel1ke.png'),*/

                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Container(
                          padding: EdgeInsets.all(20),
                          width: 350,
                          child: TextFormField(
                            controller: notesController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter amount of $currencyCode';
                              }
                            },
                            decoration: InputDecoration(
                              icon: Icon(Icons.money),
                              hintText: 'Total amount ($currencyCode)',
                              helperText:
                                  'Enter the total $currencyCode amount that have to pay',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              LengthLimitingTextInputFormatter(3),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(20),
                          width: 350,
                          child: TextFormField(
                            controller: senController,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please enter amount of cent';
                              }
                            },
                            decoration: InputDecoration(
                              icon: Icon(Icons.money_rounded),
                              hintText: 'Total amount (CENT)',
                              helperText:
                                  'Enter the total cent amount that have to pay',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              LengthLimitingTextInputFormatter(2),
                              FilteringTextInputFormatter.digitsOnly
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(20),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                double totalPaymentAmt = double.parse(
                                    notesController.text +
                                        "." +
                                        senController.text);

                                double priceNew =
                                    (totalPaymentAmt * 20).roundToDouble() /
                                        20.0;
                                if (priceNew == 0.00) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Center(child: Text('Error')),
                                        // Retrieve the text the that user has entered by using the
                                        // TextEditingController.
                                        content: Text(
                                            "The total payment amount is zero."),
                                        actions: <Widget>[
                                          TextButton(
                                              child: Text('OK'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              }),
                                        ],
                                      );
                                    },
                                  );
                                } else if (priceNew >
                                    double.parse(
                                        walletdata.amount.toString())) {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Center(child: Text('Error')),
                                        // Retrieve the text the that user has entered by using the
                                        // TextEditingController.
                                        content: Text(
                                            "The total payment amount exceeded the total amount in wallet."),
                                        actions: <Widget>[
                                          TextButton(
                                              child: Text('OK'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              }),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  print("yosh3");

                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Center(
                                            child: Text('Are you sure?')),
                                        // Retrieve the text the that user has entered by using the
                                        // TextEditingController.
                                        content: Text(
                                            "Are you sure the payment amount is correct?"),
                                        actions: <Widget>[
                                          TextButton(
                                              child: Text('No'),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              }),
                                          TextButton(
                                              child: Text('Yes'),
                                              onPressed: () {
                                                TransactionSession
                                                    .setTotalPrice(priceNew);

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          PaymentBillsScreen(
                                                              totalPayment:
                                                                  priceNew)),
                                                );
                                              })
                                        ],
                                      );
                                    },
                                  );
                                }
                              }
                            },
                            icon: Icon(Icons.list_alt),
                            label: Text(
                              "Confirm",
                              style: TextStyle(
                                fontFamily: 'Tahoma',
                                fontSize: 20,
                                letterSpacing: 1.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                ),
                                padding: EdgeInsets.all(20.0)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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

  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }
}
