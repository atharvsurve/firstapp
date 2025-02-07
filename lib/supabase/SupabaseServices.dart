import 'package:firstapp/Components/SnackBar.dart';
import 'package:firstapp/models/Expense.dart';
import 'package:firstapp/screens/auth/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  Future<void> initialize() async {
    await Supabase.initialize(
      url:
          'https://nnkhnqyvfcaaujapwvur.supabase.co', // Your Supabase project URL
      anonKey:
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5ua2hucXl2ZmNhYXVqYXB3dnVyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg3ODE3MzksImV4cCI6MjA1NDM1NzczOX0.OnW-R6IR2CBO9F1kVrqCmSEFU_PyUJJeGErHG-2PYDo', // Your Supabase anon key
      authOptions: FlutterAuthClientOptions(),
    );
  }

  SupabaseClient get client => Supabase.instance.client;

//Register User Function
  Future<void> registerUser({
    required BuildContext context,
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      // Sign up the user using Supabase
      final AuthResponse response = await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        showCustomSnackbar(
          context: context,
          message: "Registration successful!",
          isSuccess: true, // Pass false for error messages
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  LoginScreen()), // Replace with your login screen widget
        );
      }
    } catch (e) {
      showCustomSnackbar(
        context: context,
        message: e.toString(),
        isSuccess: false,
      );
    }
  }

//login Function
  Future<void> loginUser({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    try {
      // Sign in the user using Supabase
      final AuthResponse response =
          await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Navigate to the home screen or another screen
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        showCustomSnackbar(
          context: context,
          message: "Invalid email or password",
          isSuccess: false, // Pass false for error messages
        );
      }
    } catch (e) {
      showCustomSnackbar(
        context: context,
        message: e.toString(),
        isSuccess: false, // Pass false for error messages
      );
      print(e.toString());
    }
  }

//add expense function
  Future<void> addExpense(Expense expense) async {
    try {
      await Supabase.instance.client
          .from('expenses') // Reference your 'expenses' table
          .insert({
        'expense_name': expense.expenseName,
        'category': expense.category,
        'amount': expense.amount,
        'date': expense.date,
      });
      print('Expense added successfully!');
    } catch (e) {
      print('Error: $e');
    }
  }

//fetch expense function
  Future<List<Expense>> fetchExpenses() async {
    try {
      final response = await Supabase.instance.client
          .from('expenses') // Reference your 'expenses' table
          .select(); // Fetch all columns

      List<Expense> expenses =
          (response as List).map((item) => Expense.fromMap(item)).toList();

      return expenses;
    } catch (e) {
      print('Error fetching expenses: $e');
      return []; 
    }
  }
}
