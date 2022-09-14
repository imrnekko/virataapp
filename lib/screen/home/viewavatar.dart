import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:virata_app/api/firebase_api.dart';
import 'package:virata_app/screen/home/dashboard.dart';
import 'package:virata_app/services/auth.dart';
import 'package:virata_app/services/database.dart';

class ViewAvatar extends StatefulWidget {
  final File? avatar;
  const ViewAvatar({Key? key, required this.avatar}) : super(key: key);

  @override
  _ViewAvatarState createState() => _ViewAvatarState();
}

class _ViewAvatarState extends State<ViewAvatar> {
  String sessionID = AuthService().getUserID();
  UploadTask? task;
  String nameAvatarPath = "avatar/avatar.png";

  final imagepicker = ImagePicker();
  @override
  Widget build(BuildContext context) {
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
            child: widget.avatar != null
                ? Image.file(widget.avatar!)
                : Text("No Image"),
          ),
        ),
        floatingActionButton: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
              backgroundColor: Colors.red,
              child: FaIcon(
                FontAwesomeIcons.thumbsDown,
                color: Colors.white,
              ),
              onPressed: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Dashboard()));
              },
            ),
            SizedBox(
              height: 10,
            ),
            FloatingActionButton(
              child: FaIcon(
                FontAwesomeIcons.thumbsUp,
                color: Colors.white,
              ),
              heroTag: null,
              onPressed: () {
                uploadFile();
                DatabaseService(uid: sessionID)
                    .UpdateShopperAvatar(nameAvatarPath);
                Navigator.of(context).pushReplacement(
                  new MaterialPageRoute(
                      settings: const RouteSettings(name: '/dashboard'),
                      builder: (context) => Dashboard()),
                );
              },
            ),
          ],
        ));
  }

  Future uploadFile() async {
    if (widget.avatar == null) return;

    final fileName = basename(widget.avatar!.path);
    nameAvatarPath = 'avatar/$fileName';

    task = FirebaseApi.uploadFile(nameAvatarPath, widget.avatar!);
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
