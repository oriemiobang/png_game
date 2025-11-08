import 'package:flutter/material.dart';

class HomeViewModel with ChangeNotifier {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  
  void openDrawer() {
    scaffoldKey.currentState?.openDrawer();
  }

  // Add any home-specific business logic here
}