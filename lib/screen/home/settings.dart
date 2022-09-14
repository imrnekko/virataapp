//import 'package:dropdownfield/dropdownfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:virata_app/class/Constants.dart';
import 'package:virata_app/model/wallet.dart';
import 'package:virata_app/screen/home/dashboard.dart';
import 'package:virata_app/screen/authenticate/login-screen.dart';
import 'package:virata_app/screen/home/myprofile.dart';
import 'package:virata_app/screen/loading.dart';
import 'package:virata_app/services/auth.dart';
import 'package:virata_app/services/database.dart';

class MySettings extends StatefulWidget {
  MySettings({Key? key, required this.wallet}) : super(key: key);

  Wallet wallet;
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<MySettings> {
  String sessionID = AuthService().getUserID();

  final _formKey = GlobalKey<FormState>();

  //RangeValues _currentRangeValues = const RangeValues(5, 500);
  TextEditingController minAmtController = new TextEditingController();
  TextEditingController maxAmtController = new TextEditingController();

  void initState() {
    super.initState();

    int minAmtInt = widget.wallet.minAmount!.toInt();
    int maxAmtInt = widget.wallet.maxAmount!.toInt();

    minAmtController.text = minAmtInt.toString();
    maxAmtController.text = maxAmtInt.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: Colors.grey[100],
      body: Container(
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              /*child: Image.network(
                'https://s4.anilist.co/file/anilistcdn/character/large/b14-9Kb1E5oel1ke.png'),*/

              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Container(
                  child: Column(
                    children: <Widget>[
                      Text(
                        'Settings',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          "Wallet Capacity Range",
                          style: TextStyle(
                            fontFamily: 'Tahoma',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5.0),
                        margin: EdgeInsets.all(10.0),
                        height: 60,
                        child: TextFormField(
                          controller: minAmtController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter the wallet minimum amount limit';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            icon: Icon(Icons.arrow_drop_down_sharp),
                            hintText: 'Minimum Amount Limit',
                            border: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(5.0),
                        margin: EdgeInsets.all(10.0),
                        height: 60,
                        child: TextFormField(
                          controller: maxAmtController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter the wallet maximum amount limit';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            icon: Icon(Icons.arrow_drop_up_sharp),
                            hintText: 'Maximum Amount Limit',
                            border: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(20.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      DatabaseService(
                              uid: sessionID, wallet_id: widget.wallet.walletid)
                          .updateWalletCapacity(
                              double.parse(minAmtController.text),
                              double.parse(maxAmtController.text));
                      Navigator.of(context).pushReplacement(
                        new MaterialPageRoute(
                            settings: const RouteSettings(name: '/dashboard'),
                            builder: (context) => Dashboard()),
                      );
                    },
                    icon: Icon(Icons.check_circle),
                    label: Text(
                      "Update",
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
          ),
        ),
      ),
    );
  }
}
