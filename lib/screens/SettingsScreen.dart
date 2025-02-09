import 'package:flutter/material.dart';
import 'package:firstapp/supabase/SupabaseServices.dart';
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
    var userData = await SupabaseService().fetchUserDetails();
    setState(() {
      _userData = userData;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Logout"),
        content: Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text("Cancel")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text("Logout", style: TextStyle(color: Colors.red))),
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
    String formattedCreatedAt = _userData?['createdAt'] != null
        ? DateFormat.yMMMd().format(DateTime.parse(_userData!['createdAt']))
        : "N/A";

    String formattedLastLogin = _userData?['lastSignInAt'] != null
        ? DateFormat.yMMMd().format(DateTime.parse(_userData!['lastSignInAt']))
        : "N/A";
    return Scaffold(
      backgroundColor: Color(0xFF222831),
      appBar: AppBar(
        title: Text("Profile",
            style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF2E3B4E),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile Avatar
            CircleAvatar(
              radius: 55,
              backgroundColor: Colors.white10,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage("assets/atharv pic.jpg"),
                backgroundColor: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12),

            // User Info
            Text(
              "Atharv Surve",
              style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              _userData?['email'] ?? "No Email",
              style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontWeight: FontWeight.w300),
            ),
            SizedBox(height: 20),

            // Profile Details Card
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF393E46),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5,
                      offset: Offset(0, 3))
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Profile Details",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
                  Divider(color: Colors.grey[500], thickness: 1, endIndent: 20),
                  Text("Joined On: $formattedCreatedAt",
                      style: TextStyle(color: Colors.white70)),
                  Text("Last Login: $formattedLastLogin",
                      style: TextStyle(color: Colors.white70)),
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
            SizedBox(height: 20),

            // Logout Button (Standalone, Below Settings)
            Container(
              width: double.infinity,
              margin: EdgeInsets.only(top: 20),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  "Logout",
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Color(0xFF393E46),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white70, size: 22),
          SizedBox(width: 12),
          Text(title, style: TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }
}
