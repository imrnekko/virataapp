import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';

class Empty extends StatefulWidget {
  final String type;
  const Empty({Key? key, required this.type}) : super(key: key);

  @override
  _EmptyState createState() => _EmptyState();
}

class _EmptyState extends State<Empty> {
  @override
  Widget build(BuildContext context) {
    var title;
    var message;

    if (widget.type.toString() == "item1") {
      title = "No Item";
      message = "You have no item in cart yet";
    } else if (widget.type.toString() == "item2") {
      title = "No Item";
      message = "You have no item in this transaction";
    } else if (widget.type.toString() == "transaction") {
      title = "No Transaction";
      message = "You have no previous transaction yet";
    } else if (widget.type.toString() == "notification") {
      title = "No Notification";
      message = "No notification available yet";
    }
    return Scaffold(
        body: Center(
      child: Container(
          height: 500,
          width: 350,
          child: EmptyWidget(
            title: title,
            subTitle: message,
            image: ("assets/images/logo/virata-logo.png"),
            titleTextStyle: TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16),
            subtitleTextStyle: TextStyle(color: Colors.black),
          )),
    ));
  }
}
