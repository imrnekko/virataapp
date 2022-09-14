import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virata_app/model/user.dart';
import 'package:virata_app/screen/authenticate/login-screen.dart';
import 'package:virata_app/screen/home/dashboard.dart';
import 'package:virata_app/screen/loading.dart';
import 'package:virata_app/services/auth.dart';
import 'package:virata_app/services/usersession.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  var finalEmail;
  @override
  void initState() {
    getValidationData().whenComplete(() async {
      Timer(
          Duration(seconds: 2),
          () => Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => (UserSession.getEmail() == null
                        ? LoginSignupScreen()
                        : Dashboard())),
                (Route<dynamic> route) => false,
              ));
    });
    super.initState();
  }

  Future getValidationData() async {
    UserSession.init();

    setState(() {
      finalEmail = UserSession.getEmail();
    });
  }

  @override
  Widget build(BuildContext context) {
    final MyUser? user = Provider.of<MyUser?>(context);
    print("wid: " + user.toString());

    return Loading();

    /*if (user == null) {
      return LoginSignupScreen();
    } else {
      print("wid: " + user.toString());
      return Dashboard();
    }*/
  }
}
