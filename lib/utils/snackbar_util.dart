import 'package:flutter/material.dart';

// Global key define karte hain jo har jageh accessible hogi
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

// Global function to show a snackbar

void showGlobalSnackBar(String message, {Color backgroundColor = Colors.red}) {
  final snackBar = SnackBar(
    content: Text(
      message,
      style: TextStyle(fontSize: 16, color: Colors.white),
    ),
    duration: Duration(seconds: 2),
    backgroundColor: backgroundColor,
    behavior: SnackBarBehavior.floating,
  );

  scaffoldMessengerKey.currentState?.showSnackBar(snackBar);
}
