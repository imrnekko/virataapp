import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:virata_app/class/Constants.dart';
import 'package:virata_app/config/palette.dart';
import 'package:virata_app/model/bills.dart';
import 'package:virata_app/model/user.dart';
import 'package:virata_app/model/wallet.dart';
import 'package:virata_app/screen/home/dashboard.dart';
import 'package:virata_app/screen/authenticate/login-screen.dart';
import 'package:virata_app/screen/home/myprofile.dart';
import 'package:virata_app/screen/home/settings.dart';
import 'package:virata_app/screen/loading.dart';
import 'package:virata_app/services/auth.dart';
import 'package:virata_app/services/database.dart';

class MyWalletScreen extends StatefulWidget {
  const MyWalletScreen({Key? key}) : super(key: key);
  @override
  _MyWalletState createState() => _MyWalletState();
}

class _MyWalletState extends State<MyWalletScreen> {
  final _formKey = GlobalKey<FormState>();

  List<TextEditingController> billsQty = [
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

  @override
  void initState() {
    super.initState();
  }

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

  @override
  Widget build(BuildContext context) {
    final fileName =
        _moneyImg != null ? basename(_moneyImg!.path) : 'No Image Selected';
    //final user = Provider.of<MyUser>(context);
    String sessionID = AuthService().getUserID();
    return StreamBuilder<Wallet>(
        stream: DatabaseService(
                uid: sessionID.toString(),
                wallet_id: sessionID.toString() + "RM")
            .walletData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            Wallet? walletdata = snapshot.data;
            String? walletCurrency = walletdata!.currency;
            double? walletAmount = walletdata.amount;
            String walletAmountStr = walletAmount!.toStringAsFixed(2);
            return Scaffold(
              body: Center(
                child: Form(
                  key: _formKey,
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
                              "My Wallet: \n$walletCurrency $walletAmountStr",
                              style: TextStyle(
                                fontFamily: 'Tahoma',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      title:
                                          Center(child: Text('Are you sure?')),
                                      // Retrieve the text the that user has entered by using the
                                      // TextEditingController.
                                      content: Text(
                                          "Are you sure you want to update your wallet?"),
                                      actions: <Widget>[
                                        TextButton(
                                            child: Text('No'),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            }),
                                        TextButton(
                                            child: Text('Yes'),
                                            onPressed: () {
                                              //Navigator.of(context).pop();
                                              //update wallet_bills_qty
                                              double totalAmount = 0;

                                              for (int i = 0;
                                                  i < billsQty.length;
                                                  i++) {
                                                totalAmount += double.parse(
                                                        valueController[i]
                                                            .text) *
                                                    int.parse(billsQty[i].text);

                                                DatabaseService(
                                                        uid: sessionID,
                                                        wallet_id:
                                                            walletdata.walletid,
                                                        bills_id:
                                                            idController[i]
                                                                .text)
                                                    .updateBillsQty(int.parse(
                                                        billsQty[i].text));
                                              }
                                              print("total amount" +
                                                  totalAmount.toString());
                                              //update user wallet
                                              DatabaseService(
                                                      uid: sessionID,
                                                      wallet_id:
                                                          walletdata.walletid)
                                                  .updateWalletData(
                                                      true, totalAmount);
                                              Navigator.of(context).pop();
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Dashboard()),
                                              );
                                            })
                                      ],
                                    );
                                  },
                                );
                              },
                              icon: Icon(Icons.update_rounded),
                              label: Text(
                                "Update",
                                style: TextStyle(
                                  fontFamily: 'Tahoma',
                                  fontSize: 18,
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
                              .doc(walletdata.walletid)
                              .collection('bills')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) {
                              return Loading();
                            } else {
                              //trans.add(snapshot.data);
                              //int index = 0;
                              return ListView.builder(
                                  itemCount: snapshot.data!.docs.length,
                                  itemBuilder: (context, index) {
                                    billsQty[index].text = snapshot
                                        .data!.docs[index]['quantity']
                                        .toString();

                                    currencyController[index].text = snapshot
                                        .data!.docs[index]['currency']
                                        .toString();

                                    valueController[index].text = snapshot
                                        .data!.docs[index]['value']
                                        .toString();

                                    idController[index].text = snapshot
                                        .data!.docs[index].id
                                        .toString();

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
                                          /*   FutureBuilder<Widget>(
                                            future: _getImage(
                                                context,
                                                snapshot
                                                    .data!.docs[index]['image']
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
                                                snapshot
                                                    .data!.docs[index]['image']
                                                    .toString()),
                                            width: 80,
                                          ),
                                          Container(
                                            width: 150,
                                            child: TextField(
                                              controller: billsQty[index],
                                              decoration: InputDecoration(
                                                suffixIcon: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween, // added line
                                                  mainAxisSize: MainAxisSize
                                                      .min, // added line
                                                  children: <Widget>[
                                                    IconButton(
                                                        icon: Icon(Icons.add),
                                                        onPressed: () {
                                                          setState(() {
                                                            if ((billsQty[index]
                                                                    .text)
                                                                .isEmpty) {
                                                              billsQty[index]
                                                                      .text =
                                                                  1.toString();
                                                            } else if ((int.parse(
                                                                        billsQty[index]
                                                                            .text) >=
                                                                    0 &&
                                                                int.parse(billsQty[
                                                                            index]
                                                                        .text) <=
                                                                    99)) {
                                                              billsQty[index]
                                                                  .text = (int.parse(
                                                                          billsQty[index]
                                                                              .text) +
                                                                      1)
                                                                  .toString();
                                                            }
                                                          });
                                                        }),
                                                    IconButton(
                                                        icon:
                                                            Icon(Icons.remove),
                                                        onPressed: () {
                                                          setState(() {
                                                            if ((billsQty[index]
                                                                    .text)
                                                                .isEmpty) {
                                                              billsQty[index]
                                                                      .text =
                                                                  0.toString();
                                                            } else if ((int.parse(
                                                                        billsQty[index]
                                                                            .text) >
                                                                    0 &&
                                                                int.parse(billsQty[
                                                                            index]
                                                                        .text) <=
                                                                    100)) {
                                                              billsQty[index]
                                                                  .text = (int.parse(
                                                                          billsQty[index]
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
                                              keyboardType:
                                                  TextInputType.number,
                                              inputFormatters: <
                                                  TextInputFormatter>[
                                                LengthLimitingTextInputFormatter(
                                                    2),
                                                FilteringTextInputFormatter
                                                    .digitsOnly
                                              ],
                                            ),
                                          ),
                                          Visibility(
                                            visible: false,
                                            child: TextField(
                                              controller:
                                                  valueController[index],
                                            ),
                                          )
                                        ],
                                      ),
                                    );

                                    return card;
                                  });
                            }
                          },
                        ),
                      ),
                      /*Expanded(
                        child: Container(
                            child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                captureImage();
                              },
                              icon: Icon(Icons.camera_alt_rounded),
                              label: Text(
                                "Use Camera",
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
                          ],
                        )),
                      )*/
                    ],
                  ),
                ),
              ),
            );
          } else {
            print("sesion id: " + sessionID + "RM");
            return Loading();
          }
        });
  }

  Future captureImage() async {
    try {
      final avatar = await imagepicker.pickImage(source: ImageSource.camera);

      if (avatar == null) return;
      setState(() {
        _moneyImg = File(avatar.path);
      });
    } catch (e) {
      print("object");
      setState(() {});
    }
  }
}
