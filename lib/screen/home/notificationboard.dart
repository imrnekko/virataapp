import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:virata_app/class/Constants.dart';
import 'package:virata_app/screen/authenticate/login-screen.dart';
import 'package:virata_app/screen/empty.dart';
import 'package:virata_app/screen/home/myprofile.dart';
import 'package:virata_app/screen/home/settings.dart';
import 'package:virata_app/screen/home/shoppingsession.dart';
import 'package:virata_app/services/auth.dart';

class NotificationBoard extends StatefulWidget {
  @override
  _NotificationBoardState createState() => _NotificationBoardState();
}

class _NotificationBoardState extends State<NotificationBoard> {
  DateFormat sfd = new DateFormat("dd MMMM yyyy hh:mm a");

  String sessionID = AuthService().getUserID();

  @override
  Widget build(BuildContext context) {
    Widget notificationTemplate(notifications) {
      return Card(
        margin: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    notifications['title'].toString(),
                    style: TextStyle(
                        fontSize: 18,
                        fontFamily: "Tahoma",
                        fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cancel),
                    tooltip: 'Delete notification',
                    onPressed: () {
                      notifications.reference.delete();
                    },
                  )
                ],
              ),
              Text(
                notifications['body'].toString(),
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 15,
                  fontFamily: "Tahoma",
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    sfd.format(notifications['time'].toDate()).toString(),
                    style: TextStyle(
                        fontSize: 14,
                        fontFamily: "Tahoma",
                        fontWeight: FontWeight.bold),
                  ),
                ],
              )
            ],
          ),
        ),
      );
    }

    return Scaffold(
      //backgroundColor: Colors.grey[100],
      body: Center(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('shopper')
              .doc(sessionID)
              .collection('notification')
              .orderBy('time', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: Text("Loading"),
              );
            }
            int count = 0;
            var listview = ListView(
              children: snapshot.data!.docs.map((notifications) {
                count += 1;
                /*return Center(
                  child: ListTile(
                      title: Text("RM" + shopper['amount'].toStringAsFixed(2))),
                );*/
                return notificationTemplate(notifications);
              }).toList(),
            );

            if (count == 0) {
              return Empty(type: "notification");
            } else {
              return listview;
            }
          },
        ),
      ),
    );
  }
}
