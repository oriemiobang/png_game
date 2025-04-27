import 'package:png_game/models/my_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:png_game/models/png_users.dart';
import 'dart:math';

class DatabaseService {
  final String? uid;
  DatabaseService({this.uid});
  UserData myUserData = UserData();
  final CollectionReference pngCollection =
      FirebaseFirestore.instance.collection('png');

// first upload the user  data
  Future setUserData({required String userName}) async {
    DateTime now = DateTime.now();
    final random = Random();
    String formattedDate = DateFormat('d MMMM y').format(now);
    String playerId =
        'PNG${List.generate(9, (_) => random.nextInt(10)).join()}';
    return await pngCollection.doc(uid).set({
      'userName': userName,
      'playerId': playerId,
      'createdAt': formattedDate,
      'isOnline': false,
      'wins': 0,
      'losses': 0,
      'games': []
    });
  }

  // update user name
  Future<void> updateUserName(name) async {
    try {
      final documentSnapshot = await pngCollection.doc(uid).get();
      if (documentSnapshot.exists) {
        await pngCollection.doc(uid).update({
          'userName': name,
        });
      } else {
        print('user does not exist, please sign in sign in');
      }
    } catch (e) {
      print('cought an error: $e');
    }
  }

  // check if user is online
  Future<bool> isDeviceOnline() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  // update is online
  Future<void> updateIsOnline() async {
    bool isOnline = await isDeviceOnline();

    try {
      final documentSnapshot = await pngCollection.doc(uid).get();
      if (documentSnapshot.exists) {
        await pngCollection.doc(uid).update({
          'isOnline': isOnline,
        });
      } else {
        print('user does not exist, please sign in sign in');
      }
    } catch (e) {
      print('cought an error: $e');
    }
  }

  // update user wins
  Future<void> updateWins(win) async {
    try {
      final documentSnapshot = await pngCollection.doc(uid).get();
      if (documentSnapshot.exists) {
        await pngCollection.doc(uid).update({
          'wins': win,
        });
      } else {
        print('user does not exist, please sign in sign in');
      }
    } catch (e) {
      print('cought an error: $e');
    }
  }

  // update user losses
  Future<void> updateLosses(loss) async {
    try {
      final documentSnapshot = await pngCollection.doc(uid).get();
      if (documentSnapshot.exists) {
        await pngCollection.doc(uid).update({
          'losses': loss,
        });
      } else {
        print('user does not exist, please sign in sign in');
      }
    } catch (e) {
      print('cought an error: $e');
    }
  }

  // update user name
  Future<void> updateGames(List games) async {
    try {
      final documentSnapshot = await pngCollection.doc(uid).get();
      if (documentSnapshot.exists) {
        await pngCollection.doc(uid).update({
          'games': FieldValue.arrayUnion(games),
        });
      } else {
        print('user does not exist, please sign in sign in');
      }
    } catch (e) {
      print('cought an error: $e');
    }
  }

  // png user List from snapshot

  List<PngUser> pngListFromSnopshot(QuerySnapshot snapshot) {
    return snapshot.docs.map((doc) {
      final Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

      return PngUser(
          createdAt: data?['createdAt'] ?? '',
          games: data?['games'] ?? [],
          isOnline: data?['isOnline'] ?? true,
          loses: data?['loses'] ?? 0,
          playerId: data?['playerId'] ?? '',
          userName: data?['userName'] ?? '',
          wins: data?['wins'] ?? 0);
    }).toList();
  }

  Stream<List<PngUser?>?> get png_user {
    return pngCollection.snapshots().map(pngListFromSnopshot);
  }

  // user data from snopshot

  UserData _userDataFromSnopshot(DocumentSnapshot snapshot) {
    Map<String, dynamic>? data = snapshot.data() as Map<String, dynamic>?;
    print('current data: $data');

    return UserData(
        playerId: data?['playerId'] ?? '',
        userName: data?['userName'] ?? '',
        createdAt: data?['createdAt'] ?? '',
        isOnline: data?['isOnline'] ?? true,
        wins: data?['wins'] ?? 0,
        loses: data?['losses'] ?? 0,
        games: data?['games'] ?? []);
  }

  // get user doc from stream
  Stream<UserData?> get userData {
    return pngCollection.doc(uid).snapshots().map(_userDataFromSnopshot);
  }
}
