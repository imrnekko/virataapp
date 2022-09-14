import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';

class CatchError extends StatefulWidget {
  final String type;
  const CatchError({Key? key, required this.type}) : super(key: key);

  @override
  _ErrorState createState() => _ErrorState();
}

class _ErrorState extends State<CatchError> {
  @override
  Widget build(BuildContext context) {
    var title;
    var message;

    if (widget.type.toString() == "scanprice") {
      title = "Error";
      message = "The scanned label is not a label price";
    } else if (widget.type.toString() == "overprice") {
      title = "Error";
      message = "The total price exceeds of the amount in the wallet";
    }
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
          actions: <Widget>[],
          centerTitle: true,
          backgroundColor: Colors.blue,
        ),
        body: Center(
          child: Container(
              height: 500,
              width: 350,
              child: EmptyWidget(
                title: title,
                subTitle: message,
                image: ("assets/images/logo/wrong-logo.png"),
                titleTextStyle: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
                subtitleTextStyle: TextStyle(color: Colors.black),
              )),
        ));
  }
}
