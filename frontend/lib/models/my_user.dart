class MyUser {

  final String? uid;
  MyUser({this.uid});
}

class UserData{

  final String? playerId;
  final String? userName;
  final String? createdAt;
  final bool? isOnline;
  final int? wins;
  final int? loses;
  final List? games;

  UserData({
    this.createdAt,
    this.games,
    this.isOnline,
    this.loses,
    this.playerId,
    this.userName,
    this.wins
  });
}