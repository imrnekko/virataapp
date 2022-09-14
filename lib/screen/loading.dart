import 'package:flutter/material.dart';

class Loading extends StatefulWidget {
  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            /// Loader Animation Widget
            CircleAvatar(
              backgroundColor: Colors.grey,
              backgroundImage: AssetImage("assets/images/logo/virata-logo.png"),
              radius: 30.0,
            ),
            SizedBox(
              height: 20,
            ),
            CircularProgressIndicator(
              valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
            ),
            Text("Loading"),
          ],
        ),
      ),
    );
  }
}
