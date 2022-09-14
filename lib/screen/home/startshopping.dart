import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:virata_app/api/notificationapi.dart';
import 'package:virata_app/class/Constants.dart';
import 'package:virata_app/model/wallet.dart';
import 'package:virata_app/screen/authenticate/login-screen.dart';
import 'package:virata_app/screen/home/dashboard.dart';
import 'package:virata_app/screen/home/myprofile.dart';
import 'package:virata_app/screen/home/settings.dart';
import 'package:virata_app/screen/home/shoppingsession.dart';
import 'package:virata_app/screen/loading.dart';
import 'package:virata_app/services/auth.dart';
import 'package:virata_app/services/database.dart';
import 'package:virata_app/services/transactionsession.dart';

class StartShopping extends StatefulWidget {
  const StartShopping({Key? key}) : super(key: key);

  @override
  _StartShoppingState createState() => _StartShoppingState();
}

class _StartShoppingState extends State<StartShopping> {
  String sessionID = AuthService().getUserID();

  FlutterLocalNotificationsPlugin? fltrNotification;
  void initState() {
    super.initState();
    var androidInitialize = new AndroidInitializationSettings('app_icon');
    var iOSinitilize = new IOSInitializationSettings();
    var initilizationsSettings = new InitializationSettings(
        android: androidInitialize, iOS: iOSinitilize);
    fltrNotification = new FlutterLocalNotificationsPlugin();
    fltrNotification!.initialize(initilizationsSettings,
        onSelectNotification: notificationSelected);
  }

  Future _showNotification() async {
    var androidDetails = new AndroidNotificationDetails(
        "Channel ID", "Desi programmer",
        channelDescription: "This is my channel", importance: Importance.max);
    var iSODetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iSODetails);

    await fltrNotification!.show(
        0, null, "You created a Task", generalNotificationDetails,
        payload: "1");
  }

  @override
  Widget build(BuildContext context) {
    TransactionSession.init();
    return StreamBuilder<Wallet>(
        stream: DatabaseService(
                uid: sessionID.toString(),
                wallet_id: sessionID.toString() + "RM")
            .walletData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Wallet? walletdata = snapshot.data;

            var minAmt = (walletdata!.minAmount!.toDouble()).toStringAsFixed(2);
            var maxAmt = (walletdata.maxAmount!.toDouble()).toStringAsFixed(2);
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(12.0),
                      child: Text(
                        "Are you ready? Start your shopping.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 20,
                            fontFamily: "Tahoma",
                            fontWeight: FontWeight.bold,
                            color: Colors.black87),
                      ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    Container(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              if (walletdata.isAvailable == false &&
                                  walletdata.amount! <= 0.00) {
                                return AlertDialog(
                                  title: Center(child: Text('Alert')),
                                  content: Text(
                                      "Please update your wallet first before start shopping"),
                                  actions: <Widget>[
                                    TextButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        }),
                                  ],
                                );
                              } else if (walletdata.amount! <
                                  walletdata.minAmount!) {
                                return AlertDialog(
                                  title: Center(child: Text('Alert')),
                                  content: Text(
                                      "Your wallet amount is below the minimum limit. \n\nMinimum Amount: RM $minAmt"),
                                  actions: <Widget>[
                                    TextButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        }),
                                  ],
                                );
                              } else if (walletdata.amount! >
                                  walletdata.maxAmount!) {
                                return AlertDialog(
                                  title: Center(child: Text('Alert')),
                                  content: Text(
                                      "Your wallet amount is below the minimum limit. \n\nMaximum Amount: RM $maxAmt"),
                                  actions: <Widget>[
                                    TextButton(
                                        child: Text('OK'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        }),
                                  ],
                                );
                              } else {
                                return AlertDialog(
                                  title: Center(child: Text('Are you sure?')),
                                  // Retrieve the text the that user has entered by using the
                                  // TextEditingController.
                                  content:
                                      Text("Do you want to start shopping?"),
                                  actions: <Widget>[
                                    TextButton(
                                        child: Text('No'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        }),
                                    TextButton(
                                        child: Text('Yes'),
                                        onPressed: () {
                                          //_showNotification();
                                          String id;
                                          TransactionSession.removeAll();

                                          id = generateRandomString(8)
                                              .toString();
                                          TransactionSession.setID(
                                              id.toString());
                                          TransactionSession.setCurrency(
                                              walletdata.currency.toString());

                                          DatabaseService(
                                                  uid: sessionID, transid: id)
                                              .updateInitialTransactionData(
                                                  walletdata.currency
                                                      .toString());

                                          Navigator.of(context).pop();
                                          Navigator.pushReplacementNamed(
                                              context, 'shoppingsession');
                                        })
                                  ],
                                );
                              }
                            },
                          );
                        },
                        icon: Icon(Icons.shop_rounded),
                        label: Text(
                          "Start Shopping",
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
            );
          } else {
            return Loading();
          }
        });
  }

  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    return List.generate(len, (index) => _chars[r.nextInt(_chars.length)])
        .join();
  }

  void notificationSelected(String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
  }
}
