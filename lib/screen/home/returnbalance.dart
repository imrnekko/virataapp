import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:path_provider/path_provider.dart';
import 'package:virata_app/class/Constants.dart';
import 'package:virata_app/model/wallet.dart';
import 'package:virata_app/screen/home/dashboard.dart';
import 'package:virata_app/screen/home/myprofile.dart';
import 'package:virata_app/screen/home/successpay.dart';
import 'package:virata_app/screen/home/viewtransaction.dart';
import 'package:virata_app/screen/loading.dart';
import 'package:virata_app/services/auth.dart';
import 'package:virata_app/services/database.dart';
import 'package:virata_app/services/transactionsession.dart';

class ReturnBalanceScreen extends StatefulWidget {
  double? balanceAmt;
  ReturnBalanceScreen({Key? key, this.balanceAmt}) : super(key: key);

  @override
  _ReturnBalanceState createState() => _ReturnBalanceState();
}

class _ReturnBalanceState extends State<ReturnBalanceScreen> {
  String sessionID = AuthService().getUserID();
  final _formKey = GlobalKey<FormState>();

  TextEditingController checkTxt = TextEditingController();
  String chckTxt = "";

  List<TextEditingController> billsQty = [
    for (int i = 0; i < 10; i++) TextEditingController()
  ];

  List<TextEditingController> qtyFromWallet = [
    for (int i = 0; i < 10; i++) TextEditingController()
  ];

  List<TextEditingController> idController = [
    for (int i = 0; i < 10; i++) TextEditingController()
  ];

  List<TextEditingController> valueController = [
    for (int i = 0; i < 10; i++) TextEditingController()
  ];

  List<TextEditingController> currencyController = [
    for (int i = 0; i < 10; i++) TextEditingController()
  ];

  File? _moneyImg;
  String nameImgPath = "";

  final imagepicker = ImagePicker();

  Future<Widget> _getImage(BuildContext context, String imageName) async {
    Image image;
    return await FireStorageService.loadImage(context, imageName).then((value) {
      return image = Image.network(
        value.toString(),
        fit: BoxFit.scaleDown,
      );
    });
  }

  //notifications

  FlutterLocalNotificationsPlugin? fltrNotification;

  @override
  void initState() {
    super.initState();
    var androidInitilize = new AndroidInitializationSettings('app_icon');
    var iOSinitilize = new IOSInitializationSettings();
    var initilizationsSettings = new InitializationSettings(
        android: androidInitilize, iOS: iOSinitilize);
    fltrNotification = new FlutterLocalNotificationsPlugin();
    fltrNotification!.initialize(initilizationsSettings,
        onSelectNotification: notificationSelected);
  }

  //success transaction notification
  Future _showNotification(String transid) async {
    final ByteData data =
        await rootBundle.load('assets/sound/default_virata_sound.mp3');
    Directory tempDir = await getTemporaryDirectory();
    File tempFile = File('${tempDir.path}/default_virata_sound.mp3');
    await tempFile.writeAsBytes(data.buffer.asUint8List(), flush: true);
    var mp3Uri = tempFile.uri.toString();

    var androidDetails = new AndroidNotificationDetails(
        "VR_Trans_001", "Transaction",
        channelDescription: "Transaction Successful",
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound('default_virata_sound'),
        playSound: true,
        importance: Importance.max,
        styleInformation: BigTextStyleInformation(''),
        priority: Priority.high);
    var iSODetails = new IOSNotificationDetails();
    var generalNotificationDetails =
        new NotificationDetails(android: androidDetails, iOS: iSODetails);

    var title = "Transaction Completed";
    var body =
        "You have successfully completed your transaction. Transaction ID: " +
            transid +
            ".";
    var payload = transid;

    await fltrNotification!
        .show(0, title, body, generalNotificationDetails, payload: transid);

    DatabaseService(uid: sessionID).setNotification(title, body, payload);
  }

  @override
  Widget build(BuildContext context) {
    final fileName = _moneyImg != null
        ? Path.basename(_moneyImg!.path)
        : 'No Image Selected';
    //final user = Provider.of<MyUser>(context);
    String sessionID = AuthService().getUserID();
    double? balanceAmt = widget.balanceAmt;
    String balanceAmtStr = balanceAmt!.toStringAsFixed(2);

    return StreamBuilder<Wallet>(
        stream: DatabaseService(
                uid: sessionID.toString(),
                wallet_id: sessionID.toString() + "RM")
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
                automaticallyImplyLeading: false,
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
              body: Form(
                child: Column(
                  /*child: Image.network(
            'https://s4.anilist.co/file/anilistcdn/character/large/b14-9Kb1E5oel1ke.png'),*/

                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: Container(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "Return balance: \nRM$balanceAmtStr",
                            style: TextStyle(
                              fontFamily: 'Tahoma',
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          ElevatedButton.icon(
                            onPressed: () {
                              double totalCheckAmount = 0;

                              for (int i = 0; i < billsQty.length; i++) {
                                if (billsQty[i].text.isNotEmpty) {
                                  totalCheckAmount +=
                                      double.parse(valueController[i].text) *
                                          int.parse(billsQty[i].text);
                                }
                              }

                              print(totalCheckAmount.toString() +
                                  " = " +
                                  widget.balanceAmt.toString());

                              if (roundDouble(totalCheckAmount, 2) ==
                                  roundDouble(widget.balanceAmt!, 2)) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title:
                                          Center(child: Text('Are you sure?')),
                                      // Retrieve the text the that user has entered by using the
                                      // TextEditingController.
                                      content: Text("Finish shopping?"),
                                      actions: <Widget>[
                                        TextButton(
                                            child: Text('No'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            }),
                                        TextButton(
                                            child: Text('Yes'),
                                            onPressed: () {
                                              DatabaseService(
                                                      uid: sessionID,
                                                      transid:
                                                          TransactionSession
                                                                  .getID()
                                                              .toString())
                                                  .returnBalanceTransactionData(
                                                      widget.balanceAmt!);

                                              //UPDATE BILLS QTY
                                              for (int i = 0;
                                                  i < billsQty.length;
                                                  i++) {
                                                int tempQty = 0;
                                                if (billsQty[i].text.isEmpty) {
                                                  tempQty = 0;
                                                } else {
                                                  tempQty = int.parse(
                                                      billsQty[i].text);
                                                }
                                                DatabaseService(
                                                        uid: sessionID,
                                                        wallet_id: walletdata!
                                                            .walletid,
                                                        bills_id:
                                                            idController[i].text)
                                                    .updateBillsQty(int.parse(
                                                            qtyFromWallet[i]
                                                                .text) +
                                                        tempQty);
                                              }

                                              //UPDATE WALLET AMT
                                              DatabaseService(
                                                      uid: sessionID,
                                                      wallet_id:
                                                          walletdata!.walletid)
                                                  .updateWalletData(
                                                      true,
                                                      walletdata.amount! +
                                                          totalCheckAmount);

                                              _showNotification(
                                                  TransactionSession.getID()
                                                      .toString());

                                              Navigator.of(context).pop();
                                              Navigator.of(context)
                                                  .pushReplacement(
                                                      //new
                                                      new MaterialPageRoute(
                                                          //new
                                                          settings:
                                                              const RouteSettings(
                                                                  name:
                                                                      'successpay'), //new
                                                          builder: (context) =>
                                                              new SuccessPaymentScreen(
                                                                  transid: TransactionSession
                                                                          .getID()
                                                                      .toString())) //new
                                                      );
                                            })
                                      ],
                                    );
                                  },
                                );
                              } else {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title: Center(child: Text('Error')),
                                      // Retrieve the text the that user has entered by using the
                                      // TextEditingController.
                                      content: Text(
                                          "Wrong returned balance. Please check again."),
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
                              }
                            },
                            icon: Icon(Icons.check),
                            label: Text(
                              "Confirm",
                              style: TextStyle(
                                fontFamily: 'Tahoma',
                                fontSize: 20,
                                letterSpacing: 0.5,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                                shape: new RoundedRectangleBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                ),
                                padding: EdgeInsets.all(20.0)),
                          ),
                        ],
                      )),
                    ),
                    Expanded(
                      flex: 3,
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('shopper')
                            .doc(sessionID)
                            .collection('wallet')
                            .doc(walletdata!.walletid)
                            .collection('bills')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Loading();
                          } else {
                            //trans.add(snapshot.data);
                            return ListView.builder(
                              itemCount: snapshot.data!.docs.length,
                              itemBuilder: (context, index) {
                                //billsQty[index].text = document['quantity'].toString();

                                currencyController[index].text = snapshot
                                    .data!.docs[index]['currency']
                                    .toString();

                                valueController[index].text = snapshot
                                    .data!.docs[index]['value']
                                    .toString();

                                qtyFromWallet[index].text = snapshot
                                    .data!.docs[index]['quantity']
                                    .toString();

                                idController[index].text =
                                    snapshot.data!.docs[index].id.toString();

                                var card = Card(
                                  elevation: 10.00,
                                  margin: EdgeInsets.all(0.50),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Visibility(
                                        visible: false,
                                        child: TextField(
                                          controller: idController[index],
                                        ),
                                      ),
                                      /*FutureBuilder<Widget>(
                                        future: _getImage(
                                            context,
                                            snapshot.data!.docs[index]['image']
                                                .toString()),
                                        builder: (context, snapshot) {
                                          if (snapshot.connectionState ==
                                              ConnectionState.done) {
                                            return Container(
                                              child: snapshot.data,
                                              width: 80,
                                              //height: 60,
                                            );
                                          }

                                          if (snapshot.connectionState ==
                                              ConnectionState.waiting) {
                                            return Container(
                                              child:
                                                  CircularProgressIndicator(),
                                            );
                                          }

                                          return Container();
                                        },
                                      ),*/
                                      Image(
                                        image: AssetImage('assets/images/' +
                                            snapshot.data!.docs[index]['image']
                                                .toString()),
                                        width: 80,
                                      ),
                                      Container(
                                        width: 150,
                                        child: TextField(
                                          controller: billsQty[index],
                                          decoration: InputDecoration(
                                            suffixIcon: Row(
                                              mainAxisAlignment: MainAxisAlignment
                                                  .spaceBetween, // added line
                                              mainAxisSize: MainAxisSize
                                                  .min, // added line
                                              children: <Widget>[
                                                IconButton(
                                                    icon: Icon(Icons.add),
                                                    onPressed: () {
                                                      setState(() {
                                                        //maybe use for loop
                                                        if ((billsQty[index]
                                                                .text)
                                                            .isEmpty) {
                                                          billsQty[index].text =
                                                              1.toString();
                                                        } else if ((int.parse(
                                                                    billsQty[
                                                                            index]
                                                                        .text) >=
                                                                0 &&
                                                            int.parse(billsQty[
                                                                        index]
                                                                    .text) <=
                                                                99)) {
                                                          billsQty[index]
                                                              .text = (int.parse(
                                                                      billsQty[
                                                                              index]
                                                                          .text) +
                                                                  1)
                                                              .toString();
                                                        }
                                                      });
                                                    }),
                                                IconButton(
                                                    icon: Icon(Icons.remove),
                                                    onPressed: () {
                                                      setState(() {
                                                        if ((billsQty[index]
                                                                .text)
                                                            .isEmpty) {
                                                          billsQty[index].text =
                                                              0.toString();
                                                        } else if ((int.parse(
                                                                    billsQty[
                                                                            index]
                                                                        .text) >
                                                                0 &&
                                                            int.parse(billsQty[
                                                                        index]
                                                                    .text) <=
                                                                100)) {
                                                          billsQty[index]
                                                              .text = (int.parse(
                                                                      billsQty[
                                                                              index]
                                                                          .text) -
                                                                  1)
                                                              .toString();
                                                        }
                                                      });
                                                    }),
                                              ],
                                            ),
                                            hintText: 'Qty',
                                            border: OutlineInputBorder(),
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: <TextInputFormatter>[
                                            LengthLimitingTextInputFormatter(2),
                                            FilteringTextInputFormatter
                                                .digitsOnly
                                          ],
                                        ),
                                      ),
                                      Visibility(
                                        visible: false,
                                        child: TextField(
                                          controller: valueController[index],
                                        ),
                                      ),
                                      Visibility(
                                        visible: false,
                                        child: TextField(
                                          controller: qtyFromWallet[index],
                                        ),
                                      )
                                    ],
                                  ),
                                );

                                return card;
                              },
                            );
                          }
                        },
                      ),
                    ),
                    Expanded(
                      child: Container(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                              child: Container(
                            padding: EdgeInsets.all(5),
                            margin: EdgeInsets.all(5),
                            child: ElevatedButton.icon(
                              onPressed: () {
                                double totalCheckAmount = 0;

                                for (int i = 0; i < billsQty.length; i++) {
                                  if (billsQty[i].text.isNotEmpty) {
                                    totalCheckAmount +=
                                        double.parse(valueController[i].text) *
                                            int.parse(billsQty[i].text);
                                  }
                                }

                                double outstandingBalance =
                                    widget.balanceAmt! - totalCheckAmount;

                                if (roundDouble(totalCheckAmount, 2) ==
                                    roundDouble(widget.balanceAmt!, 2)) {
                                  setState(() {
                                    chckTxt = "The balance is correct";
                                  });
                                } else {
                                  setState(() {
                                    chckTxt =
                                        "The balance is incorrect. You have an outstanding balance of " +
                                            walletdata.currency.toString() +
                                            " " +
                                            outstandingBalance
                                                .toStringAsFixed(2);
                                  });
                                }
                              },
                              icon: FaIcon(
                                FontAwesomeIcons.checkDouble,
                                color: Colors.white,
                              ),
                              label: Text(
                                "Check",
                                style: TextStyle(
                                  fontFamily: 'Tahoma',
                                  fontSize: 20,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                  shape: new RoundedRectangleBorder(
                                    borderRadius:
                                        new BorderRadius.circular(20.0),
                                  ),
                                  padding: EdgeInsets.all(20.0)),
                            ),
                          )),
                          Expanded(
                              child: Container(
                            padding: EdgeInsets.all(5),
                            child: Text(
                              chckTxt,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Tahoma',
                                fontSize: 16,
                                color: (chckTxt == "The balance is correct")
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ))
                        ],
                      )),
                    )
                  ],
                ),
              ),
            );
          } else {
            print("sesion id: " + sessionID + "RM");
            return Loading();
          }
        });
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

  void notificationSelected(String? payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');

      await Navigator.push(
        this.context,
        MaterialPageRoute<void>(
            builder: (context) => ViewTransaction(transid: payload)),
      );
    }
  }

  double roundDouble(double value, int places) {
    num mod = pow(10.0, places);
    return ((value * mod).round().toDouble() / mod);
  }
}
