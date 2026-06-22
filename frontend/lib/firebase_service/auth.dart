import 'package:firebase_auth/firebase_auth.dart';
import 'package:png_game/firebase_service/database_service.dart';
import 'package:png_game/models/my_user.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // create user object based on firebase user
  _userFromFirebase(User? user) {
    return user != null ? MyUser(uid: user.uid) : null;
  }

  // auth cahnge user stream
  Stream<MyUser?> get user {
    return _auth
        .authStateChanges()
        .map((User? user) => _userFromFirebase(user));
  }

  // sign out
  Future signOut() async {
    try {
      return await _auth.signOut();
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // sign in
  Future signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email, password: password);
      User? user = result.user;
      return _userFromFirebase(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // register with email and password
  Future registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      await DatabaseService(uid: user!.uid).setUserData(userName: name);
      return _userFromFirebase(user);
    } catch (e) {
      print(e.toString());
      return null;
    }
  }
}
