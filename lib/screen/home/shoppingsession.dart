import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:virata_app/class/Constants.dart';
import 'package:virata_app/screen/authenticate/login-screen.dart';
import 'package:virata_app/screen/home/dashboard.dart';
import 'package:virata_app/screen/home/mybudget.dart';
import 'package:virata_app/screen/home/myprofile.dart';
import 'package:virata_app/screen/home/settings.dart';
import 'package:virata_app/screen/home/shoppingboard.dart';
import 'package:virata_app/screen/home/totalpayopt.dart';
import 'package:virata_app/services/auth.dart';
import 'package:virata_app/services/database.dart';
import 'package:virata_app/services/transactionsession.dart';

class ShoppingSessionScreen extends StatefulWidget {
  ShoppingSessionScreen({Key? key, required this.indexPage}) : super(key: key);

  int indexPage;
  @override
  _ShoppingSessionState createState() => _ShoppingSessionState();
}

class _ShoppingSessionState extends State<ShoppingSessionScreen> {
  String sessionID = AuthService().getUserID();
  int currentIndex = 0;

  final List<Widget> children = [
    Container(color: Colors.blue, child: ShoppingBoard()),
    Container(color: Colors.blue, child: Budget()),
  ];

  final List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(icon: Icon(Icons.shop_2), label: 'My Budget'),
    BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Shopping Cart'),
  ];

  @override
  void initState() {
    super.initState();
    currentIndex = widget.indexPage;
  }

  @override
  Widget build(BuildContext context) {
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
        elevation: 4.0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: children[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          currentIndex: currentIndex,
          items: items),
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
                    print('End Session :' +
                        TransactionSession.getID().toString());
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
}
