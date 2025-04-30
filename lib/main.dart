import 'package:flutter/material.dart';
import 'services/hive_service.dart';
import 'screens/password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Folder Task Manager',
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: PasswordScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
