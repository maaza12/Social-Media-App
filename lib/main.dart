import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'loginscreen.dart';
import 'postmanagment.dart';
import 'signupscreen.dart';
import 'userforgetpassword.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyD1xl5imEb4_d1P5Nfu7oKultSnIUpsdlM",
        authDomain: "com.example.mmy_app.firebaseapp.com",
        projectId: "user-authentication-ef145",
        storageBucket: "user-authentication-ef145.appspot.com",
        messagingSenderId: "443539865348",
        appId: "1:443539865348:android:33d4b24739632c39289a51",
      ),
    );
  } catch (e) {
    print("Firebase initialization failed: $e");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Social Media App',
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/signup', page: () => SignUpScreen()),
        GetPage(name: '/reset-password', page: () => ResetPasswordScreen()),
        GetPage(name: '/feed', page: () => FeedScreen()),
      ],
    );
  }
}
