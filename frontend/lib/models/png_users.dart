class PngUser{

  final String  playerId;
  final String  userName;
  final String  createdAt;
  final bool  isOnline;
  final int  wins;
  final int loses;
   List games = [];

  PngUser({
    required this.createdAt,
   required this.games,
  required  this.isOnline,
  required  this.loses,
   required this.playerId,
  required  this.userName,
  required  this.wins
  });
}