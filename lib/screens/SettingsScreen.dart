import 'package:firstapp/supabase/SupabaseServices.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      var userData = await SupabaseService().fetchUserDetails();
      setState(() {
        _userData = userData;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() => _isLoading = false);
    }
  }

  void _copyEmailToClipboard() {
    if (_userData?['email'] != null) {
      Clipboard.setData(ClipboardData(text: _userData!['email']));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Email copied to clipboard!")),
      );
    }
  }

  Future<void> _logout() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text("Cancel")),
          TextButton(onPressed: () => Navigator.pop(context, true), child: Text("Logout")),
        ],
      ),
    );

    if (confirm) {
      await SupabaseService().logout();
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    String gravatarUrl = _userData?['email'] != null
        ? "https://www.gravatar.com/avatar/${md5.convert(utf8.encode(_userData!['email']))}?d=identicon"
        : "https://www.gravatar.com/avatar/?d=identicon";

    return Scaffold(
      backgroundColor: Color(0xFF222831),
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(color: Colors.white,fontSize: 20, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(124, 138, 138, 141),
        centerTitle: true,
        elevation: 5,
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : _userData == null
                ? Text("Failed to load user data", style: TextStyle(color: Colors.white, fontSize: 16))
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: NetworkImage(gravatarUrl),
                        backgroundColor: Colors.grey[700],
                      ),
                      SizedBox(height: 15),
                      GestureDetector(
                        onTap: _copyEmailToClipboard,
                        child: Text(
                          _userData!['email'] ?? "No Email",
                          style: TextStyle(fontSize: 18, color: Colors.white70, decoration: TextDecoration.underline),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text("Joined: ${_userData!['createdAt']}", style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                      Text("Last Login: ${_userData!['lastSignInAt']}", style: TextStyle(color: Colors.white70), textAlign: TextAlign.center),
                      SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Text("Logout", style: TextStyle(fontSize: 16, color: Colors.white)),
                      ),
                    ],
                  ),
      ),
    );
  }
}
