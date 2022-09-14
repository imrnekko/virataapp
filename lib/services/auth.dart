import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:virata_app/model/user.dart';
import 'package:virata_app/services/database.dart';
//import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
//  final GoogleSignIn googleSignIn = GoogleSignIn();

  // create MyUser object based on User
  MyUser? _userFromFirebaseUser(User? user) {
    return user != null ? MyUser(uid: user.uid) : null;
  }

  //get User ID
  String getUserID() {
    final User? user = _auth.currentUser;
    final userid = user!.uid;
    return userid;
  }

  // auth change user stream
  Stream<MyUser?> get user {
    return _auth.authStateChanges().map(_userFromFirebaseUser);
  }

  //sign in anonymously
  Future SignInAnon() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sign in email and password
  Future signInNormally(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future forgotPassword(String emailStr) async {
    try {
      await _auth.sendPasswordResetEmail(email: emailStr);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  //sign in with google mail
  /*Future<String> signInWithGoogle() async {
    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount!.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    final User? user = authResult.user;

    assert(user!.isAnonymous);
    assert(await user.getIdToken() != null);

    final User currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return 'signInWithGoogle succeeded: $user';
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();

    print("User Sign Out");
  }*/

  //sign out normal
  Future signOut() async {
    await _auth.signOut();
  }

  //register with email and password
  Future registerUserWithEmailPassword(
      String email,
      String password,
      String username,
      String phonenum,
      String dob,
      String gender,
      String nationality,
      String avatarpath) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;

      await DatabaseService(uid: user!.uid)
          .setShopperData(username, email, phonenum, dob, gender, nationality);

      await DatabaseService(uid: user.uid).setWalletData(0, 10, 500, "RM");

      await DatabaseService(uid: user.uid).UpdateShopperAvatar(avatarpath);

      //if the nationality is MAS
      if (nationality == "MAS") {
        await DatabaseService(uid: user.uid, wallet_id: user.uid + "RM")
            .setBillsData(0.05, "RM", 0, "5SEN.png");
        await DatabaseService(uid: user.uid, wallet_id: user.uid + "RM")
            .setBillsData(0.10, "RM", 0, "10SEN.png");
        await DatabaseService(uid: user.uid, wallet_id: user.uid + "RM")
            .setBillsData(0.20, "RM", 0, "20SEN.png");
        await DatabaseService(uid: user.uid, wallet_id: user.uid + "RM")
            .setBillsData(0.50, "RM", 0, "50SEN.png");
        await DatabaseService(uid: user.uid, wallet_id: user.uid + "RM")
            .setBillsData(1, "RM", 0, "RM1.png");
        await DatabaseService(uid: user.uid, wallet_id: user.uid + "RM")
            .setBillsData(5, "RM", 0, "RM5.png");
        await DatabaseService(uid: user.uid, wallet_id: user.uid + "RM")
            .setBillsData(10, "RM", 0, "RM10.png");
        await DatabaseService(uid: user.uid, wallet_id: user.uid + "RM")
            .setBillsData(20, "RM", 0, "RM20.png");
        await DatabaseService(uid: user.uid, wallet_id: user.uid + "RM")
            .setBillsData(50, "RM", 0, "RM50.png");
        await DatabaseService(uid: user.uid, wallet_id: user.uid + "RM")
            .setBillsData(100, "RM", 0, "RM100.png");
      }

      return _userFromFirebaseUser(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
