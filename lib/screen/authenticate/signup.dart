import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:virata_app/api/firebase_api.dart';
import 'package:virata_app/model/user.dart';
import 'package:virata_app/config/palette.dart';
import 'package:virata_app/screen/authenticate/login-screen.dart';
import 'package:virata_app/screen/home/dashboard.dart';
import 'package:virata_app/screen/home/myprofile.dart';
import 'package:virata_app/services/auth.dart';
import 'package:intl/intl.dart';
import 'package:virata_app/services/database.dart';

enum Gender { male, female }

class buildSignUpSection extends StatefulWidget {
  @override
  _buildSignUpSectionState createState() => _buildSignUpSectionState();
}

class _buildSignUpSectionState extends State<buildSignUpSection> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  UploadTask? task;
  File? _avatarImg;
  String nameAvatarPath = "";

  final imagepicker = ImagePicker();

  Gender _gender = Gender.male;
  bool isMale = true;

  DateTime? _selectedDate;

  final List<String> _phoneCodeItems = ['+60', '+42', '+666', '+17', '+228'];
  String? _phoneValue;

  final List<String> _countryCodeItems = ['MAS', 'USA', 'NZL', 'AUS', 'GER'];
  String? _nationValue;

  final usernameSignupController = TextEditingController();
  final passwordSignupController = TextEditingController();
  final passwordRSignupController = TextEditingController();
  final emailSignupController = TextEditingController();
  final phoneSignupController = TextEditingController();
  final dobController = TextEditingController();
  final nationalityController = TextEditingController();
  final genderController = TextEditingController();

  String email = '';
  String password = '';

  bool obscureText1 = true;
  bool obscureText2 = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final MyUser? user = Provider.of<MyUser?>(context);
    print(user);

    final fileName =
        _avatarImg != null ? basename(_avatarImg!.path) : 'No Image Selected';

    return Container(
        margin: EdgeInsets.only(top: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              //buildTextField(Icons.supervised_user_circle, "User Name", false, false),
              //buildTextField(Icons.mail_outline, "Email Address", false, true),
              //buildTextField(Icons.password, "Password", true, false),
              Container(
                padding: const EdgeInsets.all(5.0),
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
                height: 60,
                child: TextFormField(
                  controller: emailSignupController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.email),
                    hintText: 'Email Address',
                    border: OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(20.0),
                    ),
                  ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter email address';
                    }
                    if (!RegExp("^[a-zA-Z0-9+_.-]+@[a-zA-Z0-9.-]+.[a-z]")
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                  onChanged: (val) {
                    setState(() => email = val);
                  },
                  keyboardType: TextInputType.emailAddress,
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(35),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5.0),
                height: 60,
                child: TextFormField(
                  controller: passwordSignupController,
                  obscureText: obscureText1,
                  obscuringCharacter: "•",
                  decoration: InputDecoration(
                    icon: Icon(Icons.password_rounded),
                    hintText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(20.0),
                    ),
                    suffixIcon: Padding(
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            obscureText1 = !obscureText1;
                          });
                        },
                        icon: (obscureText1)
                            ? Icon(Icons.face_retouching_off)
                            : Icon(
                                Icons.face,
                              ),
                      ),
                      padding: const EdgeInsets.all(5.0),
                    ),
                  ),
                  validator: (val) => val!.length < 6
                      ? 'Enter valid password (minimum 6 character long)'
                      : null,
                  onChanged: (val) {
                    setState(() => password = val);
                  },
                  keyboardType: TextInputType.visiblePassword,
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(15),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5.0),
                height: 60,
                child: TextFormField(
                  controller: passwordRSignupController,
                  obscureText: obscureText2,
                  obscuringCharacter: "•",
                  validator: (val) {
                    if (val!.isEmpty) {
                      return "Please enter the password";
                    }
                    if (val != passwordSignupController.text) {
                      return "Password do not match";
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    icon: Icon(Icons.password_rounded),
                    hintText: 'Retype Password',
                    border: OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(20.0),
                    ),
                    suffixIcon: Padding(
                      child: IconButton(
                        onPressed: () {
                          setState(() {
                            obscureText2 = !obscureText2;
                          });
                        },
                        icon: (obscureText2)
                            ? Icon(Icons.face_retouching_off)
                            : Icon(
                                Icons.face,
                              ),
                      ),
                      padding: const EdgeInsets.all(5.0),
                    ),
                  ),
                  keyboardType: TextInputType.visiblePassword,
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(15),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(5.0),
                height: 60,
                child: TextFormField(
                  controller: dobController,
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
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey[500]!, // red as border color
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      DropdownButtonHideUnderline(
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          child: DropdownButton<String>(
                            icon: Icon(Icons.phone_android),
                            value: _phoneValue,
                            items: _phoneCodeItems.map((value) {
                              return DropdownMenuItem<String>(
                                  child: Text(value), value: value);
                            }).toList(),
                            onChanged: _onDropDownChangedPhoneNum,
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
                                const EdgeInsets.fromLTRB(16, 16, 8, 16),
                            border: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(20.0),
                            ),
                            suffixIcon: Padding(
                              child: IconButton(
                                onPressed: () {
                                  phoneSignupController.clear();
                                  setState(() {
                                    _phoneValue = null;
                                  });
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
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.grey[500]!, // red as border color
                    ),
                  ),
                  child: Row(
                    children: <Widget>[
                      DropdownButtonHideUnderline(
                        child: Container(
                          padding: const EdgeInsets.all(5.0),
                          child: DropdownButton<String>(
                            icon: Icon(Icons.nat_outlined),
                            value: _nationValue,
                            items: _countryCodeItems.map((value) {
                              return DropdownMenuItem<String>(
                                  child: Text(value), value: value);
                            }).toList(),
                            onChanged: _onDropDownChangedNationality,
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
                                const EdgeInsets.fromLTRB(16, 16, 8, 16),
                            border: OutlineInputBorder(
                              borderRadius: new BorderRadius.circular(20.0),
                            ),
                            suffixIcon: Padding(
                              child: IconButton(
                                onPressed: () {
                                  nationalityController.clear();
                                  setState(() {
                                    _nationValue = null;
                                  });
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
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 0),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 30,
                      child: Icon(Icons.people, color: Colors.grey[600]),
                    ),
                    Container(width: 10, color: Colors.grey[500]),
                    Container(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          isMale = true;
                          _gender = Gender.male;
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
                                borderRadius: BorderRadius.circular(15)),
                            child: Icon(
                              Icons.account_circle_outlined,
                              color: isMale ? Colors.white : Palette.iconColor,
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
                          _gender = Gender.female;
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
                                borderRadius: BorderRadius.circular(15)),
                            child: Icon(
                              Icons.account_circle_outlined,
                              color: isMale ? Palette.iconColor : Colors.white,
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
                padding: const EdgeInsets.all(2.0),
                child: Text("Upload Avatar: "),
              ),
              Container(
                padding: const EdgeInsets.all(3.0),
                child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blueGrey,
                        onPrimary: Colors.white,
                        minimumSize: Size(double.infinity, 50)),
                    icon: FaIcon(
                      FontAwesomeIcons.upload,
                      color: Colors.white,
                    ),
                    label: Text("Upload Image",
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Tahoma",
                            color: Colors.white)),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Center(child: Text('Choose you avatar')),
                            // Retrieve the text the that user has entered by using the
                            // TextEditingController.
                            content: Text("Choose you avatar from"),
                            actions: <Widget>[
                              TextButton(
                                  child: Text('Camera'),
                                  onPressed: () {
                                    getImage();
                                  }),
                              TextButton(
                                  child: Text('Gallery'),
                                  onPressed: () async {
                                    selectFile();
                                  })
                            ],
                          );
                        },
                      );
                    }),
              ),
              Container(
                padding: const EdgeInsets.all(2.0),
                child: Text(fileName),
              ),
              Container(
                width: 200,
                margin: EdgeInsets.only(top: 20),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                      text: "By pressing 'Submit' you agree to our ",
                      style: TextStyle(
                        color: Palette.textColor1,
                        fontFamily: 'Tahoma',
                      ),
                      children: [
                        TextSpan(
                          //recognizer: ,
                          text: "terms & conditions",
                          style: TextStyle(
                            color: Colors.orange,
                            fontFamily: 'Tahoma',
                          ),
                        ),
                      ]),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                  padding: const EdgeInsets.all(3.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        onPrimary: Colors.white,
                        minimumSize: Size(double.infinity, 50)),
                    icon: FaIcon(
                      FontAwesomeIcons.registered,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        if (_phoneValue == null) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title:
                                    Center(child: Text('Invalid credentials')),
                                // Retrieve the text the that user has entered by using the
                                // TextEditingController.
                                content: Text(
                                    "Please select your phone country code."),
                                actions: <Widget>[
                                  TextButton(
                                      child: Text('Okay'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      })
                                ],
                              );
                            },
                          );
                        } else if (_nationValue == null) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title:
                                    Center(child: Text('Invalid credentials')),
                                // Retrieve the text the that user has entered by using the
                                // TextEditingController.
                                content:
                                    Text("Please select your nationality."),
                                actions: <Widget>[
                                  TextButton(
                                      child: Text('Okay'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      })
                                ],
                              );
                            },
                          );
                        } else {
                          String gender;
                          if (isMale) {
                            gender = "Male";
                          } else {
                            gender = "Female";
                          }

                          if (_avatarImg != null) {
                            //upload the new image avatar into database
                            uploadFile();
                          } else {
                            //if not, system will upload the default avatar into database
                            nameAvatarPath = "avatar/avatar.png";
                          }

                          //register new user into database
                          dynamic result =
                              await _auth.registerUserWithEmailPassword(
                                  email,
                                  password,
                                  usernameSignupController.text,
                                  _phoneValue.toString() +
                                      phoneSignupController.text,
                                  dobController.text,
                                  gender,
                                  nationalityController.text,
                                  nameAvatarPath);
                          if (result == null) {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Center(
                                      child: Text('Invalid credentials')),
                                  // Retrieve the text the that user has entered by using the
                                  // TextEditingController.
                                  content: Text(
                                      "Invalid registration details. Please try again."),
                                  actions: <Widget>[
                                    TextButton(
                                        child: Text('Okay'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        })
                                  ],
                                );
                              },
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Center(child: Text('Success')),
                                  // Retrieve the text the that user has entered by using the
                                  // TextEditingController.
                                  content: Text(
                                      "You have been registered successfully."),
                                  actions: <Widget>[
                                    TextButton(
                                        child: Text('Okay'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    LoginSignupScreen()),
                                          );
                                        })
                                  ],
                                );
                              },
                            );
                          }
                        }
                      }
                    },
                    label: Text("Register",
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Tahoma",
                            color: Colors.white)),
                  )),
            ],
          ),
        ));
  }

  _selectDate(BuildContext context) async {
    var now = new DateTime.now();
    var formatterYear = new DateFormat('yyyy');
    String formattedYear = formatterYear.format(now);
    print(formattedYear);

    DateTime? newSelectedDate = await showDatePicker(
        context: context,
        initialDate: _selectedDate != null
            ? _selectedDate!
            : DateTime(int.parse(formattedYear) - 11),
        firstDate: DateTime(int.parse(formattedYear) - 113),
        lastDate: DateTime(int.parse(formattedYear) - 11),
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
      dobController.text = DateFormat.yMMMd().format(_selectedDate!);
      dobController.selection = TextSelection.fromPosition(TextPosition(
          offset: dobController.text.length, affinity: TextAffinity.upstream));
    }
  }

  void _onDropDownChangedPhoneNum(String? value) {
    setState(() {
      _phoneValue = value;
    });
  }

  void _onDropDownChangedNationality(String? value) {
    setState(() {
      _nationValue = value;
      nationalityController.text = value.toString();
    });
  }

  Future getImage() async {
    try {
      final avatar = await imagepicker.pickImage(source: ImageSource.camera);

      if (avatar == null) return;
      setState(() {
        _avatarImg = File(avatar.path);
      });
    } catch (e) {
      print("object");
      setState(() {});
    }
  }

  Future selectFile() async {
    final result = await FilePicker.platform.pickFiles();

    if (result == null) return;
    final path = result.files.single.path;

    setState(() {
      _avatarImg = File(path!);
    });
  }

  Future uploadFile() async {
    if (_avatarImg == null) return;

    final fileName = basename(_avatarImg!.path);
    nameAvatarPath = 'avatar/$fileName';

    task = FirebaseApi.uploadFile(nameAvatarPath, _avatarImg!);
    setState(() {});

    if (task == null) return;

    final snapshot = await task!.whenComplete(() {});
    final urlDownload = await snapshot.ref.getDownloadURL();

    print('Download-Link: $urlDownload');
  }

  Widget buildUploadStatus(UploadTask task) => StreamBuilder<TaskSnapshot>(
        stream: task.snapshotEvents,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final snap = snapshot.data!;
            final progress = snap.bytesTransferred / snap.totalBytes;
            final percentage = (progress * 100).toStringAsFixed(2);

            return Text(
              '$percentage %',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            );
          } else {
            return Container();
          }
        },
      );
}
