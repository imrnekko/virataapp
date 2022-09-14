import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:image_picker/image_picker.dart';

import 'package:path/path.dart';
import 'package:virata_app/class/Constants.dart';
import 'package:virata_app/model/wallet.dart';
import 'package:virata_app/screen/catcherror.dart';
import 'package:virata_app/screen/home/dashboard.dart';
import 'package:virata_app/screen/home/keyinpayment.dart';
import 'package:virata_app/screen/home/paybillsdisplay.dart';
import 'package:virata_app/screen/loading.dart';
import 'package:virata_app/services/auth.dart';
import 'package:virata_app/services/database.dart';
import 'package:virata_app/services/transactionsession.dart';

class TotalPayOption extends StatefulWidget {
  TotalPayOption({Key? key, required this.budgetAmount}) : super(key: key);
  double budgetAmount;
  @override
  _TotalPayOptionState createState() => _TotalPayOptionState();
}

class _TotalPayOptionState extends State<TotalPayOption> {
  bool isInitilized = false;
  @override
  void initState() {
    FlutterMobileVision.start().then((value) {
      isInitilized = true;
    });
    super.initState();
  }

  //OCR Price Label Scan

  Future<Null> _scanPriceLabel(String? currencyCode, double? walletAmt) async {
    List<OcrText> list = [];

    try {
      list = await FlutterMobileVision.read(
        waitTap: true,
        fps: 5,
        //multiple: true,
      );

      for (OcrText text in list) {
        print('valueis ${text.value}');

        bool isNumeric = true;
        var valueStr;

        int currencyCodeLength = currencyCode!.length;

        try {
          if (text.value.contains(currencyCode)) {
            valueStr = double.parse(
                text.value.replaceAll(' ', '').substring(currencyCodeLength));
          } else {
            valueStr = double.parse(text.value);
          }
        } on FormatException {
          isNumeric = false;
          print('False value is ${text.value}');
          Navigator.push(
            this.context,
            MaterialPageRoute(
                builder: (context) => CatchError(type: "scanprice")),
          );
        } finally {
          if (isNumeric == true) {
            if (valueStr > walletAmt) {
              Navigator.push(
                this.context,
                MaterialPageRoute(
                    builder: (context) => CatchError(type: "overprice")),
              );
            } else {
              double priceNew =
                  (double.parse(valueStr.toString()) * 20).roundToDouble() /
                      20.0;

              Navigator.push(
                this.context,
                MaterialPageRoute(
                    builder: (context) =>
                        PaymentBillsScreen(totalPayment: priceNew)),
              );
            }
          }
        }
      }
    } catch (e) {}
  }

  String sessionID = AuthService().getUserID();

  File? _labelImg;
  String nameImgPath = "";

  final imagepicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    String budgetAmountStr = widget.budgetAmount.toStringAsFixed(2);
    TransactionSession.init();

    final fileName =
        _labelImg != null ? basename(_labelImg!.path) : 'No Image Selected';

    var scaffold1 = StreamBuilder<Wallet>(
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
              //backgroundColor: Colors.grey[100],

              body: Container(
                  /* decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage("assets/images/shopping-bg1.jpg"),
            fit: BoxFit.cover,
          )),*/
                  child: Center(
                child: Column(
                  /*child: Image.network(
                'https://s4.anilist.co/file/anilistcdn/character/large/b14-9Kb1E5oel1ke.png'),*/

                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          //print(generateRandomString(5).toString());
                          /*DatabaseService(uid: sessionID).UpdateTransactionData(
                      generateRandomString(5).toString(),
                      double.parse(totalFromMyBudget));*/

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => PaymentBillsScreen(
                                    totalPayment:
                                        double.parse(budgetAmountStr))),
                          );
                        },
                        icon: Icon(Icons.wallet_travel),
                        label: Text(
                          "From My Budget\nRM $budgetAmountStr",
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
                    Container(
                      child: ElevatedButton.icon(
                        onPressed: () => _scanPriceLabel(
                            walletdata!.currency, walletdata.amount),
                        icon: Icon(Icons.shop_rounded),
                        label: Text(
                          "Scan Total Payment",
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
                    Container(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => KeyInPayment()),
                          );
                        },
                        icon: Icon(Icons.list_alt),
                        label: Text(
                          "Key In Total Payment",
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
              )),
            );
          } else {
            return Loading();
          }
        });

    var scaffold2 = StreamBuilder<Wallet>(
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
              //backgroundColor: Colors.grey[100],

              body: Container(
                  /* decoration: BoxDecoration(
              image: DecorationImage(
            image: AssetImage("assets/images/shopping-bg1.jpg"),
            fit: BoxFit.cover,
          )),*/
                  child: Center(
                child: Column(
                  /*child: Image.network(
                'https://s4.anilist.co/file/anilistcdn/character/large/b14-9Kb1E5oel1ke.png'),*/

                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _scanPriceLabel(
                              walletdata!.currency, walletdata.amount);
                        },
                        icon: Icon(Icons.shop_rounded),
                        label: Text(
                          "Scan Total Payment",
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
                    Container(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => KeyInPayment()),
                          );
                        },
                        icon: Icon(Icons.list_alt),
                        label: Text(
                          "Key In Total Payment",
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
              )),
            );
          } else {
            return Loading();
          }
        });

    if (widget.budgetAmount == 0) {
      return scaffold2;
    } else {
      return scaffold1;
    }
  }

  void choiceAction(String choice) {
    if (choice == Constants.EndSession) {
      showDialog(
        context: this.context,
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
