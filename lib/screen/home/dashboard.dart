import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virata_app/screen/home/myprofile.dart';
import 'package:virata_app/screen/home/mywallet.dart';
import 'package:virata_app/screen/home/startshopping.dart';
import 'package:virata_app/screen/home/transactionhistory.dart';
import 'package:virata_app/services/auth.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int currentIndex = 3;
  final List<String> childrenTitle = [
    'My Wallet',
    'Shopping',
    'Transaction History',
    'My Profile',
  ];

  final List<Widget> children = [
    Container(color: Colors.blue, child:
    MyWalletScreen()),
    Container(color: Colors.blue, child: StartShopping()),
    Container(color: Colors.blue, child: TransactionHistory()),
    Container(color: Colors.blue, child: MyProfile()),
  ];

  final List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(
        icon: Icon(Icons.wallet_travel), label: 'My Wallet'),
    BottomNavigationBarItem(icon: Icon(Icons.shop), label: 'Shopping'),
    BottomNavigationBarItem(icon: Icon(Icons.list_alt), label: 'Transaction'),
    BottomNavigationBarItem(
        icon: Icon(Icons.account_box_rounded), label: 'Profile'),
  ];

  @override
  void initState() {
    super.initState();
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
        elevation: 4.0,
        automaticallyImplyLeading: false,
        actions: <Widget>[],
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
      //backgroundColor: Colors.grey[100],
    );
  }
}
