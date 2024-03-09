import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:login/firebase_options.dart';
import 'package:login/open.dart';
import 'package:login/splash_screen.dart';
import 'package:login/userPreferences.dart';
import 'package:provider/provider.dart';

import 'home.dart';
import 'login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.appAttest,
  );
  runApp(
    ChangeNotifierProvider(
      create:(context)=>UserProvider(),
      child: MaterialApp(
        home: SplashScreen(),
        debugShowCheckedModeBanner: false,
        routes: {
          'opening':(context)=>Opening(),
          'login':(context)=>Login(),
          'home':(context)=>Home(),
        },
      ),
    )
  );
}


