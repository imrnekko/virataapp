class MyUser {
  final String uid;

  MyUser({required this.uid});
}

class ShopperData {
  String? shopperid;
  String? username;
  String? email;
  String? phonenum;
  String? dob;
  String? gender;
  String? nationality;
  String avatarpath;

  ShopperData({
    this.shopperid,
    this.username,
    this.email,
    this.phonenum,
    this.dob,
    this.gender,
    this.nationality,
    required this.avatarpath,
  });
}
