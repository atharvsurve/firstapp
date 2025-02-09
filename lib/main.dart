import 'package:flutter/material.dart';
import 'package:firstapp/screens/auth/LoginScreen.dart';
import 'package:firstapp/app.dart';
import 'package:firstapp/supabase/SupabaseServices.dart';



void main() async{

  WidgetsFlutterBinding.ensureInitialized(); // Ensure async operations are allowed before runApp
  await SupabaseService().initialize(); // Initialize Supabase before using it

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: App(),
    );
  }
}
