//import 'package:dropdownfield/dropdownfield.dart';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:virata_app/api/notificationapi.dart';
import 'package:virata_app/class/Constants.dart';
import 'package:virata_app/model/user.dart';
import 'package:virata_app/model/wallet.dart';
import 'package:virata_app/screen/home/chooseavatar.dart';
import 'package:virata_app/screen/home/dashboard.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:virata_app/screen/authenticate/login-screen.dart';
import 'package:virata_app/screen/home/notificationboard.dart';
import 'package:virata_app/screen/home/setaccount.dart';
import 'package:virata_app/screen/home/settings.dart';
import 'package:virata_app/screen/home/viewavatar.dart';
import 'package:virata_app/screen/loading.dart';
import 'package:virata_app/services/auth.dart';
import 'package:virata_app/services/database.dart';

import 'package:virata_app/services/usersession.dart';

import 'components/profile_menu.dart';

class MyProfile extends StatefulWidget {
  @override
  _MyProfileState createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  final AuthService _auth = AuthService();

  String sessionID = AuthService().getUserID();
  String? sessionEmail = UserSession.getEmail();

  UploadTask? task;
  File? _avatarImg;
  String nameAvatarPath = "";

  final imagepicker = ImagePicker();

  Future getImage() async {
    try {
      final avatar = await imagepicker.pickImage(source: ImageSource.camera);

      if (avatar == null) return;
      setState(() {
        _avatarImg = File(avatar.path);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ViewAvatar(avatar: _avatarImg)),
        );
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

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ViewAvatar(avatar: _avatarImg)),
      );
    });
  }

  Future<Widget> _getImage(BuildContext context, String imageName) async {
    CircleAvatar image;
    return await FireStorageService.loadImage(context, imageName).then((value) {
      var image = GestureDetector(
        onTap: () {
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
                        Navigator.of(context).pop();
                        getImage();
                      }),
                  TextButton(
                      child: Text('Gallery'),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        selectFile();
                      }),
                  TextButton(
                      child: Text('Avatar'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        //getImage();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ChooseAvatar()),
                        );
                      }),
                ],
              );
            },
          );
        },
        child: CircleAvatar(
          backgroundColor: Colors.black87,
          backgroundImage: AssetImage('assets/images/avatar/avatar.png'),
          radius: 52,
          child: CircleAvatar(
            backgroundImage: NetworkImage(value.toString()),
            backgroundColor: Colors.transparent,
            radius: 48,
          ),
        ),
      );
      return image;
    });
  }

  @override
  Widget build(BuildContext context) {
    //final user = Provider.of<User>(context);
    void _showSettings() {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return StreamBuilder<Wallet>(
              stream: DatabaseService(
                      uid: sessionID, wallet_id: sessionID.toString() + "RM")
                  .walletData,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  Wallet? walletdata = snapshot.data;
                  return Container(
                    child: MySettings(wallet: walletdata!),
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  );
                } else {
                  return Loading();
                }
              },
            );
          });
    }

    void _showNotifications() {
      showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              child: NotificationBoard(),
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            );
          });
    }

    return StreamBuilder<ShopperData>(
      stream: DatabaseService(uid: sessionID).userData,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          ShopperData? shopperData = snapshot.data;

          String sessionUsername = shopperData!.username.toString();
          return Scaffold(
            //backgroundColor: Colors.grey[100],
            body: Container(
                child: Center(
              child: Column(
                /*child: Image.network(
                'https://s4.anilist.co/file/anilistcdn/character/large/b14-9Kb1E5oel1ke.png'),*/
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  /*CircleAvatar(
                    radius: 50.0,
                    backgroundImage:
                        AssetImage('assets/images/avatar/avatar.png'),
                    backgroundColor: Colors.transparent,
                  ),*/
                  FutureBuilder<Widget>(
                    future: _getImage(context, shopperData.avatarpath),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Container(
                          child: snapshot.data,
                        );
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircleAvatar(
                          backgroundColor: Colors.transparent,
                          radius: 52,
                          child: CircularProgressIndicator(),
                        );
                      }

                      return Container();
                    },
                  ),
                  Text(
                    'Hello $sessionUsername',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 20),
                  ProfileMenu(
                    text: "My Account",
                    icon: Icons.account_box,
                    press: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SetMyAccount(
                                shopperID: sessionID,
                                username: sessionUsername,
                                email: snapshot.data!.email.toString(),
                                phonenum: snapshot.data!.phonenum.toString(),
                                dob: snapshot.data!.dob.toString(),
                                nationality:
                                    snapshot.data!.nationality.toString(),
                                gender: snapshot.data!.gender.toString())),
                      );
                    },
                  ),
                  ProfileMenu(
                    text: "Notifications",
                    icon: Icons.notifications,
                    press: () {
                      _showNotifications();
                    },
                  ),
                  ProfileMenu(
                    text: "Settings",
                    icon: Icons.settings,
                    press: () {
                      _showSettings();
                    },
                  ),
                  ProfileMenu(
                    text: "Log Out",
                    icon: Icons.logout_rounded,
                    press: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Center(child: Text('Are you sure?')),
                            // Retrieve the text the that user has entered by using the
                            // TextEditingController.
                            content: Text("Proceed to logout?"),
                            actions: <Widget>[
                              TextButton(
                                  child: Text('No'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  }),
                              TextButton(
                                  child: Text('Yes'),
                                  onPressed: () async {
                                    await _auth.signOut();
                                    //Get.to(LoginSignupScreen());

                                    UserSession.removeEmail();
                                    Navigator.of(context).pop();
                                    Navigator.pushReplacementNamed(
                                        context, 'login-screen');

                                    /*   Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              LoginSignupScreen()),
                                    );*/
                                  })
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            )),
          );
        } else {
          return Loading();
        }
      },
    );
  }
}

class FireStorageService extends ChangeNotifier {
  FireStorageService();
  static Future<dynamic> loadImage(BuildContext context, String Image) async {
    return await FirebaseStorage.instance.ref().child(Image).getDownloadURL();
  }
}
