import 'package:flutter/cupertino.dart';
import 'package:login/home.dart';
import 'package:login/login.dart';
import 'package:login/userPreferences.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return FutureBuilder(
      future: userProvider.loadUser(),
      builder: (context, snapshot) {
        if (userProvider.isLoggedIn) {
          return Home();
        } else {
          return Login();
        }
      },
    );
  }
}
