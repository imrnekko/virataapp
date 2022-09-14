//import 'package:dropdownfield/dropdownfield.dart';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:virata_app/api/firebase_api.dart';
import 'package:virata_app/class/Constants.dart';
import 'package:virata_app/config/palette.dart';
import 'package:virata_app/model/user.dart';
import 'package:virata_app/screen/home/dashboard.dart';
import 'package:virata_app/screen/authenticate/login-screen.dart';
import 'package:virata_app/screen/home/myprofile.dart';
import 'package:virata_app/screen/loading.dart';
import 'package:virata_app/services/database.dart';
import 'package:virata_app/services/usersession.dart';

class SetMyAccount extends StatefulWidget {
  SetMyAccount(
      {Key? key,
      required this.shopperID,
      required this.username,
      required this.email,
      required this.dob,
      required this.phonenum,
      required this.nationality,
      required this.gender})
      : super(key: key);
  String shopperID;
  String username;
  String email;
  String phonenum;
  String dob;
  String nationality;
  String gender;
  @override
  _SetMyAccountState createState() => _SetMyAccountState();
}

class _SetMyAccountState extends State<SetMyAccount> {
  String? sessionEmail = UserSession.getEmail();
  final _formKey = GlobalKey<FormState>();

  bool isMale = true;

  @override
  void initState() {
    super.initState();

    usernameSignupController.text = widget.username.toString();
    emailSignupController.text = widget.email.toString();
    dobController.text = widget.dob.toString();
    if (widget.phonenum.toString().substring(0, 3).compareTo("+60") == 0 ||
        widget.phonenum.toString().substring(0, 3).compareTo("+42") == 0 ||
        widget.phonenum.toString().substring(0, 3).compareTo("+17") == 0) {
      _phoneValue1 = widget.phonenum.toString().substring(0, 3);
    }
    phoneSignupController.text = widget.phonenum.toString().substring(3);

    //if (shopperData.nationality.toString().compareTo(other) == 0) {
    _nationValue1 = widget.nationality.toString();
    // }
    nationalityController.text = widget.nationality.toString();
    genderController.text = widget.gender.toString();

    if (widget.gender.toString() == ("Male")) {
      isMale = true;
    } else if (widget.gender.toString() == ("Female")) {
      isMale = false;
    }
  }

  DateTime? _selectedDate;

  final List<String> _phoneCodeItems = ['+60', '+42', '+666', '+17', '+228'];
  String? _phoneValue1;

  final List<String> _countryCodeItems = ['MAS', 'USA', 'NZL', 'AUS', 'GER'];
  String? _nationValue1;

  TextEditingController usernameSignupController = new TextEditingController();
  TextEditingController emailSignupController = new TextEditingController();
  TextEditingController phoneSignupController = new TextEditingController();
  TextEditingController dobController = new TextEditingController();
  TextEditingController nationalityController = new TextEditingController();
  TextEditingController genderController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ShopperData>(
        stream: DatabaseService(uid: widget.shopperID).userData,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            ShopperData? shopperData = snapshot.data;
            print(widget.shopperID);

            /* usernameSignupController.text = shopperData!.username.toString();
            emailSignupController.text = shopperData.email.toString();
            dobController.text = shopperData.dob.toString();
            if (shopperData.phonenum
                        .toString()
                        .substring(0, 3)
                        .compareTo("+60") ==
                    0 ||
                shopperData.phonenum
                        .toString()
                        .substring(0, 3)
                        .compareTo("+42") ==
                    0 ||
                shopperData.phonenum
                        .toString()
                        .substring(0, 3)
                        .compareTo("+17") ==
                    0) {
              _phoneValue1 = shopperData.phonenum.toString().substring(0, 3);
            }
            phoneSignupController.text =
                shopperData.phonenum.toString().substring(3);

            //if (shopperData.nationality.toString().compareTo(other) == 0) {
            _nationValue1 = shopperData.nationality.toString();
            // }
            nationalityController.text = shopperData.nationality.toString();
            genderController.text = shopperData.gender.toString();

            if (shopperData.gender.toString() == ("Male")) {
              isMale = true;
            } else if (shopperData.gender.toString() == ("Female")) {
              isMale = false;
            }*/

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
              //backgroundColor: Colors.grey[100],
              body: Container(
                  margin: EdgeInsets.only(top: 20),
                  child: Center(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          Text(
                            'My Account',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: 26, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            margin: EdgeInsets.all(10.0),
                            height: 60,
                            child: TextFormField(
                              controller: usernameSignupController,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter username';
                                }
                                if (!RegExp("^[a-zA-Z0-9.-]").hasMatch(value)) {
                                  return 'Please enter a valid username';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                icon: Icon(Icons.account_box),
                                hintText: 'Username',
                                border: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                ),
                              ),
                              keyboardType: TextInputType.name,
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(15),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            margin: EdgeInsets.all(10.0),
                            height: 60,
                            child: TextFormField(
                              controller: emailSignupController,
                              decoration: InputDecoration(
                                icon: Icon(Icons.email),
                                hintText: 'Email Address',
                                enabled: false,
                                border: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                ),
                              ),
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter email address';
                                }
                                if (!RegExp(
                                        "^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                              onChanged: (val) {},
                              keyboardType: TextInputType.emailAddress,
                              inputFormatters: <TextInputFormatter>[
                                LengthLimitingTextInputFormatter(35),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5.0),
                            margin: EdgeInsets.all(10.0),
                            height: 60,
                            child: TextFormField(
                              controller: dobController,
                              enabled: false,
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return 'Please enter date of birth ';
                                }
                                return null;
                              },
                              decoration: InputDecoration(
                                icon: Icon(Icons.calendar_view_day),
                                hintText: 'Date of birth',
                                border: OutlineInputBorder(
                                  borderRadius: new BorderRadius.circular(20.0),
                                ),
                              ),
                              onTap: () {
                                _selectDate(context);
                              },
                              focusNode: AlwaysDisabledFocusNode(),
                            ),
                          ),
                          Container(
                              padding: const EdgeInsets.all(5.0),
                              margin: EdgeInsets.all(10.0),
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      Colors.grey[500]!, // red as border color
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  DropdownButtonHideUnderline(
                                    child: Container(
                                      padding: const EdgeInsets.all(5.0),
                                      margin: EdgeInsets.all(10.0),
                                      child: DropdownButton<String>(
                                        icon: Icon(Icons.phone_android),
                                        value: _phoneValue1,
                                        items: _phoneCodeItems.map((value) {
                                          return DropdownMenuItem<String>(
                                              child: Text(value), value: value);
                                        }).toList(),
                                        onChanged: _onDropDownChangedPhoneNum1,
                                      ),
                                    ),
                                  ),
                                  Container(width: 1, color: Colors.grey[500]),
                                  Expanded(
                                    child: TextFormField(
                                      keyboardType: TextInputType.phone,
                                      autofocus: false,
                                      controller: phoneSignupController,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter phone number ';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Phone Number',
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                16, 16, 8, 16),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(20.0),
                                        ),
                                        suffixIcon: Padding(
                                          child: IconButton(
                                            onPressed: () {
                                              phoneSignupController.clear();
                                            },
                                            icon: Icon(
                                              Icons.cancel,
                                            ),
                                          ),
                                          padding: const EdgeInsets.all(5.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                          Container(
                              padding: const EdgeInsets.all(5.0),
                              margin: EdgeInsets.all(10.0),
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      Colors.grey[500]!, // red as border color
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  DropdownButtonHideUnderline(
                                    child: Container(
                                      padding: const EdgeInsets.all(5.0),
                                      margin: EdgeInsets.all(10.0),
                                      child: DropdownButton<String>(
                                        icon: Icon(Icons.nat_outlined),
                                        value: _nationValue1,
                                        items: _countryCodeItems.map((value) {
                                          return DropdownMenuItem<String>(
                                              child: Text(value), value: value);
                                        }).toList(),
                                        onChanged:
                                            _onDropDownChangedNationality1,
                                      ),
                                    ),
                                  ),
                                  Container(width: 1, color: Colors.grey[500]),
                                  Expanded(
                                    child: TextFormField(
                                      keyboardType: TextInputType.text,
                                      autofocus: false,
                                      readOnly: true,
                                      controller: nationalityController,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please choose nationality ';
                                        }
                                        return null;
                                      },
                                      decoration: InputDecoration(
                                        hintText: 'Nationality',
                                        contentPadding:
                                            const EdgeInsets.fromLTRB(
                                                16, 16, 8, 16),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              new BorderRadius.circular(20.0),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              )),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 30,
                                  child: Icon(Icons.people,
                                      color: Colors.grey[600]),
                                ),
                                Container(width: 10, color: Colors.grey[500]),
                                Container(),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isMale = true;
                                      genderController.text = "Male";
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        margin: EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                            color: isMale
                                                ? Palette.textColor2
                                                : Colors.transparent,
                                            border: Border.all(
                                                width: 1,
                                                color: isMale
                                                    ? Colors.transparent
                                                    : Palette.textColor1),
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Icon(
                                          Icons.account_circle_outlined,
                                          color: isMale
                                              ? Colors.white
                                              : Palette.iconColor,
                                        ),
                                      ),
                                      Text(
                                        "Male",
                                        style: TextStyle(
                                          color: Palette.textColor1,
                                          fontFamily: "Tahoma",
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  width: 50,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isMale = false;
                                      genderController.text = "Female";
                                    });
                                  },
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 30,
                                        height: 30,
                                        margin: EdgeInsets.only(right: 8),
                                        decoration: BoxDecoration(
                                            color: isMale
                                                ? Colors.transparent
                                                : Palette.textColor2,
                                            border: Border.all(
                                                width: 1,
                                                color: isMale
                                                    ? Palette.textColor1
                                                    : Colors.transparent),
                                            borderRadius:
                                                BorderRadius.circular(15)),
                                        child: Icon(
                                          Icons.account_circle_outlined,
                                          color: isMale
                                              ? Palette.iconColor
                                              : Colors.white,
                                        ),
                                      ),
                                      Text(
                                        "Female",
                                        style: TextStyle(
                                          color: Palette.textColor1,
                                          fontFamily: "Tahoma",
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (_formKey.currentState!.validate()) {
                                  String gender;
                                  if (isMale) {
                                    gender = "Male";
                                  } else {
                                    gender = "Female";
                                  }

                                  DatabaseService(uid: widget.shopperID)
                                      .updateShopperData(
                                    usernameSignupController.text,
                                    emailSignupController.text,
                                    _phoneValue1.toString() +
                                        phoneSignupController.text,
                                    dobController.text,
                                    gender,
                                    nationalityController.text,
                                  );

                                  Navigator.of(context).pushReplacement(
                                    new MaterialPageRoute(
                                        settings: const RouteSettings(
                                            name: '/dashboard'),
                                        builder: (context) => Dashboard()),
                                  );
                                }
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
                                    borderRadius:
                                        new BorderRadius.circular(20.0),
                                  ),
                                  padding: EdgeInsets.all(20.0)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            );
          } else {
            return Loading();
          }
        });
  }

  _selectDate(BuildContext context) async {
    var now = new DateTime.now();
    var formatterYear = new DateFormat('yyyy');
    String formattedYear = formatterYear.format(now);

    DateTime? newSelectedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate != null ? _selectedDate! : DateTime.now(),
        firstDate: DateTime(int.parse(formattedYear) - 113),
        lastDate: DateTime(int.parse(formattedYear) - 13),
        builder: (BuildContext context, Widget? child) {
          return Theme(
            data: ThemeData.dark().copyWith(
              colorScheme: ColorScheme.dark(
                primary: Colors.white,
                onPrimary: Colors.black,
                surface: Colors.blueGrey,
                onSurface: Colors.yellow,
              ),
              dialogBackgroundColor: Colors.black54,
            ),
            child: child!,
          );
        });

    if (newSelectedDate != null) {
      _selectedDate = newSelectedDate;
      dobController
        ..text = DateFormat.yMMMd().format(_selectedDate!)
        ..selection = TextSelection.fromPosition(TextPosition(
            offset: dobController.text.length,
            affinity: TextAffinity.upstream));
    }
  }

  void _onDropDownChangedPhoneNum1(String? value) {
    setState(() {
      _phoneValue1 = value;
    });
  }

  void _onDropDownChangedNationality1(String? value) {
    setState(() {
      _nationValue1 = value;
      nationalityController.text = value!;
    });
  }
}
