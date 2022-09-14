import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virata_app/model/loginmodel.dart';
import 'package:virata_app/model/user.dart';
import 'package:virata_app/config/palette.dart';
import 'package:virata_app/screen/authenticate/login-screen.dart';
import 'package:virata_app/screen/home/dashboard.dart';
import 'package:virata_app/services/auth.dart';
import 'package:virata_app/services/loginsession.dart';
import 'package:virata_app/services/usersession.dart';

class buildSigninSection extends StatefulWidget {
  @override
  _buildSigninSectionState createState() => _buildSigninSectionState();
}

class _buildSigninSectionState extends State<buildSigninSection> {
  final AuthService _auth = AuthService();
  LoginUser loginuser = new LoginUser();
  final _formKey = GlobalKey<FormState>();
  final _formResetKey = GlobalKey<FormState>();

  bool isRememberMe = false;
  bool obscureText = true;

  final emailLoginController = TextEditingController();
  final passwordLoginController = TextEditingController();

  final emailResetController = TextEditingController();

  String email = '';
  String password = '';

  @override
  void initState() {
    super.initState();

    init();
  }

  Future init() async {
    final email = await UserSecureStorage.getEmail() ?? '';
    final pass = await UserSecureStorage.getPassword() ?? '';

    setState(() {
      if (email == '') {
        isRememberMe = false;
      } else {
        isRememberMe = true;
      }
      this.emailLoginController.text = email;
      this.passwordLoginController.text = pass;
    });
  }

  @override
  Widget build(BuildContext context) {
    final MyUser? user = Provider.of<MyUser?>(context);
    //print(user);
    return Container(
        margin: EdgeInsets.only(top: 20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              //buildTextField(Icons.mail_outline, "Email Address", false, true),
              //buildTextField(Icons.password, "Password", true, false),

              Container(
                padding: const EdgeInsets.all(5.0),
                height: 60,
                child: TextFormField(
                  controller: emailLoginController,
                  decoration: InputDecoration(
                    icon: Icon(Icons.account_box),
                    hintText: 'Email address',
                    border: OutlineInputBorder(
                      borderRadius: new BorderRadius.circular(20.0),
                    ),
                  ),
                  validator: (val) =>
                      val!.isEmpty ? 'Enter valid email address' : null,
                  onSaved: (value) {
                    loginuser.email = value;
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
                  controller: passwordLoginController,
                  obscureText: obscureText,
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
                            obscureText = !obscureText;
                          });
                        },
                        icon: (obscureText)
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
                  onSaved: (value) {
                    loginuser.password = value;
                  },
                  onChanged: (val) {
                    setState(() => password = val);
                  },
                  keyboardType: TextInputType.visiblePassword,
                  inputFormatters: <TextInputFormatter>[
                    LengthLimitingTextInputFormatter(15),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Checkbox(
                        value: isRememberMe,
                        activeColor: Palette.textColor2,
                        onChanged: (value) {
                          setState(() {
                            isRememberMe = !isRememberMe;
                          });
                        },
                      ),
                      Text("Remember me\n",
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: "Aero",
                              color: Palette.textColor1))
                    ],
                  ),
                  TextButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Center(child: Text('Password reset')),
                            // Retrieve the text the that user has entered by using the
                            // TextEditingController.
                            content: TextField(
                              onChanged: (value) {},
                              controller: emailResetController,
                              decoration:
                                  InputDecoration(hintText: "Email Address"),
                            ),
                            actions: <Widget>[
                              TextButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    //usernameController.clear();
                                    //passwordController.clear();
                                    Navigator.of(context).pop();
                                  }),
                              TextButton(
                                  child: Text('OK'),
                                  onPressed: () {
                                    AuthService().forgotPassword(
                                        emailResetController.text);
                                    //usernameController.clear();
                                    //passwordController.clear();
                                    Navigator.of(context).pop();
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Center(
                                              child: Text('Password reset')),
                                          // Retrieve the text the that user has entered by using the
                                          // TextEditingController.
                                          content: Text(
                                              "The link for password reset has been sent to your email."),
                                          actions: <Widget>[
                                            TextButton(
                                                child: Text('OK'),
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                })
                                          ],
                                        );
                                      },
                                    );
                                  })
                            ],
                          );
                        },
                      );
                    },
                    child: Text("Forgot Password?\n",
                        style: TextStyle(
                            fontSize: 12,
                            fontFamily: "Aero",
                            color: Palette.textColor1)),
                  )
                ],
              ),
              Container(
                  padding: const EdgeInsets.all(3.0),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                        primary: Colors.blue,
                        onPrimary: Colors.white,
                        minimumSize: Size(double.infinity, 50)),
                    icon: FaIcon(
                      FontAwesomeIcons.key,
                      color: Colors.white,
                    ),
                    onPressed: () async {
                      if (isRememberMe == true) {
                        _formKey.currentState!.save();
                        if (emailLoginController.text.isNotEmpty) {
                          await UserSecureStorage.setEmail(
                              emailLoginController.text);
                        }
                        if (passwordLoginController.text.isNotEmpty) {
                          await UserSecureStorage.setPassword(
                              passwordLoginController.text);
                        }
                      } else {
                        await UserSecureStorage.removeAll();
                      }
                      //FirebaseFirestore.instance.collection('shopper').snapshots();
                      print(email);
                      print(password);
                      //Login button
                      if (_formKey.currentState!.validate()) {
                        dynamic result =
                            await _auth.signInNormally(email, password);
                        if (result == null) {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title:
                                    Center(child: Text('Invalid credentials')),
                                // Retrieve the text the that user has entered by using the
                                // TextEditingController.
                                content: Text("Invalid email or password"),
                                actions: <Widget>[
                                  TextButton(
                                      child: Text('Okay'),
                                      onPressed: () {
                                        //usernameController.clear();
                                        //passwordController.clear();
                                        Navigator.of(context).pop();
                                      })
                                ],
                              );
                            },
                          );
                        } else {
                          //final SharedPreferences sharedPreferences =
                          // await SharedPreferences.getInstance();

                          //sharedPreferences.setString(
                          // 'email', emailLoginController.text);
                          UserSession.setEmail(emailLoginController.text);
                          //Get.to(Dashboard());
                          //Navigator.pushReplacementNamed(context, '/dashboard');
                          Navigator.of(context).pushReplacement(
                            new MaterialPageRoute(
                                settings:
                                    const RouteSettings(name: '/dashboard'),
                                builder: (context) => Dashboard()),
                          );
                        }
                      }
                    },
                    label: Text("Sign in",
                        style: TextStyle(
                            fontSize: 14,
                            fontFamily: "Tahoma",
                            color: Colors.white)),
                  )),
            ],
          ),
        ));
  }

  void verifyOTP() async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationID, smsCode: otpController.text);

    await auth.signInWithCredential(credential).then((value) {
      print("You are logged in successfully");
      Fluttertoast.showToast(
          msg: "You are logged in successfully",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    });
  }
}
