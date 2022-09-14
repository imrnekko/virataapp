import 'package:get/get.dart';
import 'package:http/http.dart';
import 'dart:convert';

class WorldTime {
  String location;
  String? time;
  String? flag;
  String url;

  WorldTime({required this.location, required this.url});

  Future<void> getTIme() async {
    final response =
        await get(Uri.parse('http://worldtimeapi.org/api/timezone/$url'));
    Map data = jsonDecode(response.body);

    String datetime = data['datetime'];
    String offset = data['utc_offset'].substring(1, 3);

    DateTime now = DateTime.parse(datetime);
    now = now.add(Duration(hours: int.parse(offset)));

    time = now.toString();
  }
}

WorldTime instance =
    WorldTime(location: "Asia/Kuala_Lumpur", url: "Asia/Kuala_Lumpur");
