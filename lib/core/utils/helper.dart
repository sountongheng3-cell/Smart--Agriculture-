import 'package:flutter/material.dart';

class Helper {
  // Show SnackBar
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // Hide Keyboard
  static void hideKeyboard(BuildContext context) {
    FocusScope.of(context).unfocus();
  }

  // Screen Width
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  // Screen Height
  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }
}
