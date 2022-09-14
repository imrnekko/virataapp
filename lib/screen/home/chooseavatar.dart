import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:virata_app/screen/home/dashboard.dart';
import 'package:virata_app/services/auth.dart';
import 'package:virata_app/services/database.dart';

class ChooseAvatar extends StatefulWidget {
  //final String type;
  //const ChooseAvatar({Key? key, required this.type}) : super(key: key);

  @override
  _ChooseAvatarState createState() => _ChooseAvatarState();
}

class _ChooseAvatarState extends State<ChooseAvatar> {
  String sessionID = AuthService().getUserID();

  String nameAvatarPath = "";

  List<String> getDataList() {
    List<String> list = [];
    for (int i = 0; i < 10; i++) {
      list.add("avatar_" + (i + 1).toString() + ".png");
    }
    return list;
  }

  List<Widget> getWidgetList() {
    return getDataList().map((item) => getItemContainer(item)).toList();
  }

  Widget getItemContainer(String item) {
    return GestureDetector(
      onTap: () {
        setState(() {
          nameAvatarPath = 'avatar/' + item.toString();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          //borderRadius: BorderRadius.circular(20.0),
          color: Colors.blue,
        ),
        alignment: Alignment.center,
        child: Image.asset(
          'assets/images/avatar/' + item.toString(),
          color: (nameAvatarPath == "avatar/" + item.toString())
              ? Colors.greenAccent
              : null,
          colorBlendMode: (nameAvatarPath == "avatar/" + item.toString())
              ? BlendMode.color
              : BlendMode.clear,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var title;
    var message;

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
      body: GridView.count(
        // Spacing between horizontal sub-widgets
        crossAxisSpacing: 10.0,
        //The spacing between vertical sub-widgets
        mainAxisSpacing: 10.0,
        //GridView padding
        padding: EdgeInsets.all(10.0),
        //The number of Widgets in a row
        crossAxisCount: 2,
        //Child Widget aspect ratio
        childAspectRatio: 1.0,
        //Child Widget list
        children: getWidgetList(),
      ),
      floatingActionButton: FloatingActionButton(
        child: FaIcon(
          FontAwesomeIcons.thumbsUp,
          color: Colors.white,
        ),
        heroTag: null,
        onPressed: () {
          DatabaseService(uid: sessionID).UpdateShopperAvatar(nameAvatarPath);
          Navigator.of(context).pushReplacement(
            new MaterialPageRoute(
                settings: const RouteSettings(name: '/dashboard'),
                builder: (context) => Dashboard()),
          );
        },
      ),
    );
  }
}
