import 'package:flutter/material.dart';
//import 'package:flutter_svg/flutter_svg.dart';
//import '../../../constants.dart';

class ProfileMenu extends StatelessWidget {
  const ProfileMenu({
    Key? key,
    this.text,
    this.icon,
    this.press,
  }) : super(key: key);

  final String? text;
  final IconData? icon;
  final VoidCallback? press;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: TextButton(
        style: TextButton.styleFrom(
          primary: Colors.white,
          padding: EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          backgroundColor: Colors.blue,
        ),
        onPressed: press,
        child: Row(
          children: [
            /*SvgPicture.asset(
              icon,
              color: Colors.white12,
              width: 22,
            ),*/
            Icon(
              icon,
              color: Colors.white,
              size: 40.0,
              textDirection: TextDirection.ltr,
              semanticLabel:
                  'Icon', // Announced in accessibility modes (e.g TalkBack/VoiceOver). This label does not show in the UI.
            ),
            SizedBox(width: 20),
            Expanded(
                child: Text(
              text!,
              style: TextStyle(
                fontSize: 18,
              ),
            )),
            Icon(Icons.arrow_forward_ios),
          ],
        ),
      ),
    );
  }
}
