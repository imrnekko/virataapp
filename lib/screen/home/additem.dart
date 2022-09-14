import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:virata_app/class/Constants.dart';
import 'package:virata_app/screen/catcherror.dart';
import 'package:virata_app/screen/home/dashboard.dart';
import 'package:virata_app/screen/home/shoppingsession.dart';
import 'package:virata_app/services/auth.dart';
import 'package:virata_app/services/database.dart';
import 'package:virata_app/services/transactionsession.dart';

class AddItem extends StatefulWidget {
  //AddItem({Key? key}) : super(key: key);
  AddItem({Key? key, required this.currency});
  String currency;

  @override
  _AddItemState createState() => _AddItemState();
}

class _AddItemState extends State<AddItem> {
  Random random = new Random();
  //int randomNumber = random.nextInt(100);

  final nameController = TextEditingController();
  final qtyController = TextEditingController();
  final priceController = TextEditingController();
  bool isInitilized = false;
  @override
  void initState() {
    FlutterMobileVision.start().then((value) {
      isInitilized = true;
    });
    super.initState();
  }

  //OCR Price Label Scan

  Future<Null> _scanPriceLabel(String? currencyCode) async {
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
          print('False value is ${text.value}');
          isNumeric = false;
          Navigator.push(
            this.context,
            MaterialPageRoute(
                builder: (context) => CatchError(type: "scanprice")),
          );
        } finally {
          if (isNumeric) {
            setState(() {
              priceController.text = valueStr.toString();
            });
          }
        }
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    String sessionID = AuthService().getUserID();
    final _formKey = GlobalKey<FormState>();
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
          margin: EdgeInsets.only(top: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                Text(
                  'Add Item',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 26, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(5.0),
                  margin: EdgeInsets.all(10.0),
                  height: 60,
                  child: TextFormField(
                    controller: nameController,
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter item name';
                      }
                      if (!RegExp("^[a-zA-Z0-9.-]").hasMatch(value)) {
                        return 'Please enter a valid item name';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      icon: Icon(Icons.fastfood),
                      hintText: 'Item Name',
                      border: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(20.0),
                      ),
                    ),
                    keyboardType: TextInputType.name,
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(25),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5.0),
                  margin: EdgeInsets.all(10.0),
                  height: 60,
                  child: TextFormField(
                    controller: qtyController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.format_list_numbered),
                      hintText: 'Item Quantity',
                      border: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(20.0),
                      ),
                      suffixIcon: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceBetween, // added line
                        mainAxisSize: MainAxisSize.min, // added line
                        children: <Widget>[
                          IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  if ((qtyController.text).isEmpty) {
                                    qtyController.text = 1.toString();
                                  } else if ((int.parse(qtyController.text) >=
                                          0 &&
                                      int.parse(qtyController.text) <= 99)) {
                                    qtyController.text =
                                        (int.parse(qtyController.text) + 1)
                                            .toString();
                                  }
                                });
                              }),
                          IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  if ((qtyController.text).isEmpty) {
                                    qtyController.text = 0.toString();
                                  } else if ((int.parse(qtyController.text) >
                                          0 &&
                                      int.parse(qtyController.text) <= 100)) {
                                    qtyController.text =
                                        (int.parse(qtyController.text) - 1)
                                            .toString();
                                  }
                                });
                              }),
                        ],
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter quantity';
                      }
                      if (value == "0") {
                        return 'Quantity must greater than 0';
                      }
                      if (!RegExp("^[a-zA-Z0-9.-]").hasMatch(value)) {
                        return 'Please enter a valid quantity';
                      }
                      return null;
                    },
                    onChanged: (val) {},
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(35),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(5.0),
                  margin: EdgeInsets.all(10.0),
                  height: 60,
                  child: TextFormField(
                    controller: priceController,
                    decoration: InputDecoration(
                      icon: Icon(Icons.price_change),
                      hintText: 'Item Price',
                      border: OutlineInputBorder(
                        borderRadius: new BorderRadius.circular(20.0),
                      ),
                      suffixIcon: Padding(
                        child: IconButton(
                          onPressed: () {
                            _scanPriceLabel(widget.currency);
                          },
                          icon: Icon(Icons.camera),
                        ),
                        padding: const EdgeInsets.all(5.0),
                      ),
                    ),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter item price';
                      }
                      if (double.parse(value) <= 0) {
                        return 'Please enter item price';
                      }
                      if (!RegExp("^[a-zA-Z0-9.-]").hasMatch(value)) {
                        return 'Please enter a valid item price';
                      }
                      return null;
                    },
                    onChanged: (val) {},
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      LengthLimitingTextInputFormatter(35),
                    ],
                  ),
                ),
                SizedBox(
                  height: 50,
                ),
                Container(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      /*FirebaseFirestore.instance.collection("items").add({
                        "name": nameController.text,
                        "priceperunit": double.parse(priceController.text),
                        "quantity": int.parse(qtyController.text),
                      });*/

                      if (_formKey.currentState!.validate()) {
                        double priceNew =
                            (double.parse(priceController.text) * 20)
                                    .roundToDouble() /
                                20.0;
                        DatabaseService(
                                uid: sessionID,
                                transid: TransactionSession.getID().toString())
                            .updateItemData(
                                random.nextInt(100).toString(),
                                nameController.text.toString(),
                                priceNew,
                                int.parse(qtyController.text));

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ShoppingSessionScreen(indexPage: 1)),
                        );
                      }
                    },
                    icon: Icon(Icons.check_circle),
                    label: Text(
                      "Add",
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
}
