import 'package:firstapp/supabase/SupabaseServices.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:intl/intl.dart';

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

    String formattedCreatedAt = _userData?['createdAt'] != null
        ? DateFormat.yMMMd().format(DateTime.parse(_userData!['createdAt']))
        : "N/A";

    String formattedLastLogin = _userData?['lastSignInAt'] != null
        ? DateFormat.yMMMd().format(DateTime.parse(_userData!['lastSignInAt']))
        : "N/A";

    return Scaffold(
      backgroundColor: Color(0xFF222831),
      appBar: AppBar(
        title: Text("Profile", style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        backgroundColor: const Color.fromARGB(124, 138, 138, 141),
        elevation: 5,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : _userData == null
                ? Center(child: Text("Failed to load user data", style: TextStyle(color: Colors.white, fontSize: 16)))
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Row
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage: NetworkImage(gravatarUrl),
                            backgroundColor: Colors.grey[700],
                          ),
                          SizedBox(width: 15),
                          GestureDetector(
                            onTap: _copyEmailToClipboard,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _userData!['email'] ?? "No Email",
                                  style: TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  "Tap to copy",
                                  style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Profile Details
                      Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Color(0xFF393E46),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Profile Details", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                            Divider(color: Colors.grey[500]),
                            Text("Joined On: $formattedCreatedAt", style: TextStyle(color: Colors.white70)),
                            Text("Last Login: $formattedLastLogin", style: TextStyle(color: Colors.white70)),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),

                      // Menu Options
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMenuItem(Icons.category, "Categories"),
                          _buildMenuItem(Icons.person_add, "Invite Friends"),
                          _buildMenuItem(Icons.notifications, "Notifications"),
                          _buildMenuItem(Icons.delete, "Clear Transactions"),
                        ],
                      ),

                      Spacer(),

                      // Logout Button
                      Center(
                        child: ElevatedButton(
                          onPressed: _logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          child: Text("Logout", style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ),

                      SizedBox(height: 20),

                      // Quote of the Day
                      Center(
                        child: Text(
                          "\"A budget is telling your money where to go instead of wondering where it went.\"",
                          style: TextStyle(fontSize: 14, color: Colors.grey[400], fontStyle: FontStyle.italic),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 22),
          SizedBox(width: 10),
          Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}
