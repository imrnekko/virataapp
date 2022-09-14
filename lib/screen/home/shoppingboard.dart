import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:virata_app/class/Constants.dart';
import 'package:virata_app/model/wallet.dart';
import 'package:virata_app/screen/authenticate/login-screen.dart';
import 'package:virata_app/screen/home/additem.dart';
import 'package:virata_app/screen/home/myprofile.dart';
import 'package:virata_app/screen/home/settings.dart';
import 'package:virata_app/screen/home/totalpayopt.dart';
import 'package:virata_app/screen/loading.dart';
import 'package:virata_app/services/auth.dart';
import 'package:virata_app/services/database.dart';
import 'package:virata_app/services/transactionsession.dart';

class ShoppingBoard extends StatefulWidget {
  const ShoppingBoard({Key? key}) : super(key: key);
  @override
  _ShoppingBoardState createState() => _ShoppingBoardState();
}

class _ShoppingBoardState extends State<ShoppingBoard> {
  final AuthService _auth = AuthService();

  String sessionID = AuthService().getUserID();

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

            double? walletAmount = walletdata!.amount;
            String walletAmountStr = walletAmount!.toStringAsFixed(2);
            double budgetAmount = 0;

            if (TransactionSession.getTotalPriceFromBudget() == null) {
              budgetAmount = 0;
            } else {
              budgetAmount = TransactionSession.getTotalPriceFromBudget()!;
            }
            String budgetAmountStr = budgetAmount.toStringAsFixed(2);

            double? availableAmount = walletAmount - budgetAmount;
            String availableAmountStr = availableAmount.toStringAsFixed(2);

            return Scaffold(
              body: Center(
                child: Column(
                  /*child: Image.network(
            'https://s4.anilist.co/file/anilistcdn/character/large/b14-9Kb1E5oel1ke.png'),*/

                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      "My Wallet",
                      style: TextStyle(
                        fontFamily: 'Tahoma',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      child: Text(
                        "RM $walletAmountStr",
                        style: TextStyle(
                          fontFamily: 'Aero',
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      "Current Budget",
                      style: TextStyle(
                        fontFamily: 'Tahoma',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      child: Text(
                        "RM $budgetAmountStr",
                        style: TextStyle(
                          fontFamily: 'Aero',
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      "Available Budget",
                      style: TextStyle(
                        fontFamily: 'Tahoma',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      child: Text(
                        "RM $availableAmountStr",
                        style: TextStyle(
                          fontFamily: 'Aero',
                          fontSize: 25,
                          color:
                              (availableAmount > 0) ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              floatingActionButton: FloatingActionButton(
                child: FaIcon(
                  FontAwesomeIcons.cashRegister,
                  color: Colors.white,
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      if (availableAmount >= 0) {
                        return AlertDialog(
                          title: Center(child: Text('Proceed?')),
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
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TotalPayOption(
                                            budgetAmount: budgetAmount)),
                                  );
                                })
                          ],
                        );
                      } else {
                        return AlertDialog(
                          title: Center(child: Text('Error')),
                          // Retrieve the text the that user has entered by using the
                          // TextEditingController.
                          content: Text(
                              "Your budget amount has exceeds the available amount in your wallet. Please check your budget."),
                          actions: <Widget>[
                            TextButton(
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                }),
                            /* TextButton(
                                child: Text('Yes'),
                                onPressed: () async {
                                  Navigator.of(context).pop();
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TotalPayOption()),
                                  );
                                })*/
                          ],
                        );
                      }
                    },
                  );
                },
              ),
            );
          } else {
            return Loading();
          }
        });
  }
}
