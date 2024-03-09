import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  String? _userEmail;

  String? get userEmail => _userEmail;

  // Check if the user is logged in
  bool get isLoggedIn => _userEmail != null;

  // Load user data from shared preferences
  Future<void> loadUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userEmail = prefs.getString('userEmail');
    notifyListeners();
  }

  // Login user
  Future<void> loginUser(String email) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userEmail = email;
    prefs.setString('userEmail', email);
    notifyListeners();
  }

  // Logout user
  Future<void> logoutUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _userEmail = null;
    prefs.remove('userEmail');
    notifyListeners();
  }
}