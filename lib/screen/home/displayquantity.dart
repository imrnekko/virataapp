import 'package:empty_widget/empty_widget.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:virata_app/screen/home/dashboard.dart';
import 'package:virata_app/services/auth.dart';
import 'package:virata_app/services/database.dart';

class DisplayQuantity extends StatefulWidget {
  int? needQty;
  String? currencyCode;
  String? imageStr;
  DisplayQuantity(
      {Key? key,
      required this.needQty,
      required this.currencyCode,
      required this.imageStr})
      : super(key: key);

  @override
  _DisplayQuantityState createState() => _DisplayQuantityState();
}

class _DisplayQuantityState extends State<DisplayQuantity> {
  String sessionID = AuthService().getUserID();

  List<String> getDataList() {
    List<String> list = [];
    for (int i = 0; i < int.parse(widget.needQty.toString()); i++) {
      list.add(widget.imageStr.toString());
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
          //nameAvatarPath = 'avatar/' + item.toString();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          //borderRadius: BorderRadius.circular(20.0),
          color: Colors.transparent,
        ),
        alignment: Alignment.center,
        child: Image.asset(
          'assets/images/' + item.toString(),
          width: 120,
          fit: BoxFit.fill,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Navigator.of(context).pop();
        },
      ),
    );
  }
}
