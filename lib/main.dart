
import 'package:appshopsua/chatbox/chat_screen.dart';
import 'package:appshopsua/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); //khởi tạo firebase
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Bán Sữa',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false, //tắt banner debug bên góc phải màn hình
      home: DangNhapPage(),
    );
  }
}

