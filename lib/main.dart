import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'Screen/authscreen.dart';
import 'Screen/home_screen.dart';


Future<void> main() async {
   WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
   FirebaseAuth.instance.authStateChanges().listen((user) {
     if (user == null) {
       runApp(const MyApp(auth : false));
           }
     else {
           runApp(const MyApp(auth : true));
           }
       });
}
class MyApp extends StatelessWidget {
  final bool auth;
    const MyApp({Key? key, required this.auth}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return  GetMaterialApp(
      title: "AddMe",
      debugShowCheckedModeBanner: false,
      home:!auth?AuthScreen(): HomeScreen(),
        getPages: [
          GetPage(name: '/home', page: () =>  HomeScreen()),
          GetPage(name: '/auth', page: () =>  AuthScreen()),
        ],
    );
  }
}