import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:virata_app/model/user.dart';
import 'package:virata_app/screen/authenticate/login-screen.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:virata_app/screen/home/dashboard.dart';
import 'package:virata_app/screen/home/keyinpayment.dart';
import 'package:virata_app/screen/home/paybillsdisplay.dart';
import 'package:virata_app/screen/home/returnbalance.dart';
import 'package:virata_app/screen/home/shoppingsession.dart';
import 'package:virata_app/screen/home/successpay.dart';

import 'package:virata_app/screen/wrapper.dart';
import 'package:virata_app/services/auth.dart';
import 'package:virata_app/services/transactionsession.dart';
import 'package:virata_app/services/usersession.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();

  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: VirataApp(),
    title: "ViRata",
    routes: {
      'login-screen': (_) => new LoginSignupScreen(),
      '/dashboard': (context) => Dashboard(),
      'shoppingsession': (context) => ShoppingSessionScreen(indexPage: 0),
      'successpay': (BuildContext context) => new SuccessPaymentScreen(),
      'returnbalance': (context) => ReturnBalanceScreen(),
      'keyinpayment': (context) => KeyInPayment(),
      //'paybillsscreen':(context)=>PaymentBillsScreen(totalPayment: totalPayment)
    },
  ));
}

class VirataApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TransactionSession.removeAll();

    //UserSession.removeEmail();
    return StreamProvider<MyUser?>.value(
      initialData: null,
      value: AuthService().user,
      child: MaterialApp(
        home: Wrapper(),
      ),
    );
  }
}
