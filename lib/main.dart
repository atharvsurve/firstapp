import 'package:flutter/material.dart';
import 'package:firstapp/app.dart';
import 'package:firstapp/supabase/SupabaseServices.dart';


void main() async{

  WidgetsFlutterBinding.ensureInitialized(); // Ensure async operations are allowed before runApp
  await SupabaseService().initialize(); // Initialize Supabase before using it

  runApp(App());
}

