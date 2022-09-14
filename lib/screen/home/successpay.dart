import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:virata_app/class/Constants.dart';
import 'package:virata_app/screen/authenticate/login-screen.dart';
import 'package:virata_app/screen/home/dashboard.dart';
import 'package:virata_app/screen/home/myprofile.dart';
import 'package:virata_app/screen/home/settings.dart';
import 'package:virata_app/screen/home/viewtransaction.dart';
import 'package:virata_app/services/transactionsession.dart';

class SuccessPaymentScreen extends StatefulWidget {
  String? transid;
  SuccessPaymentScreen({Key? key, this.transid}) : super(key: key);

  @override
  _SuccessPaymentState createState() => _SuccessPaymentState();
}

class _SuccessPaymentState extends State<SuccessPaymentScreen> {
  @override
  Widget build(BuildContext context) {
    TransactionSession.removeAll();
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
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: EmptyWidget(
          title: "Transaction Successful",
          subTitle:
              "You have successfully completed your transaction. Transaction ID : " +
                  widget.transid.toString(),
          image: ("assets/images/logo/virata-logo.png"),
          titleTextStyle: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
          subtitleTextStyle: TextStyle(color: Colors.black),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            child: FaIcon(
              FontAwesomeIcons.list,
              color: Colors.white,
            ),
            onPressed: () {
              TransactionSession.removeAll();
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          ViewTransaction(transid: widget.transid!)));
            },
          ),
          SizedBox(
            height: 10,
          ),
          FloatingActionButton(
            child: FaIcon(
              FontAwesomeIcons.thumbsUp,
              color: Colors.white,
            ),
            heroTag: null,
            onPressed: () {
              TransactionSession.removeAll();
              Navigator.of(context).pushAndRemoveUntil(
                new MaterialPageRoute(
                    settings: const RouteSettings(name: '/dashboard'),
                    builder: (context) => Dashboard()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ), /*FloatingActionButton(
        child: FaIcon(
          FontAwesomeIcons.thumbsUp,
          color: Colors.white,
        ),
        onPressed: () {
          TransactionSession.removeAll();
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => Dashboard()));
        },
      ),*/
    );
  }
}
