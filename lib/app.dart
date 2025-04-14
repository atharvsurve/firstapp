import 'package:firstapp/screens/auth/LoginScreen.dart';
import 'package:flutter/material.dart';
import 'screens/InsightsScreen.dart';
import './screens/AddExpenseScreen.dart';
import './screens/SettingsScreen.dart';

class App extends StatefulWidget {
  const App({super.key});
  @override
  State<StatefulWidget> createState() => AppState();
}

class AppState extends State<App> {
  int _selectedIndex = 0;

  // List of pages for bottom navigation
  final List<Widget> pages = [
    InsightsScreen(),
    AddExpenseScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Tracker',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/login', // First screen to check auth status
      routes: {
        '/login': (context) => LoginScreen(),
        '/home': (context) => Scaffold(
            body: pages[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() => _selectedIndex = index);
              },
              backgroundColor: Color(0xFF222831),
              selectedItemColor: Colors.white, // Set selected item color
              unselectedItemColor: Colors.grey, // Set unselected item color
              items: [
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_sharp),
                  label: "Insights",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.add),
                  label: "Add Expense",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person_2_sharp),
                  label: "Profile",
                ),
              ],
            )),
      },
    );
  }
}
