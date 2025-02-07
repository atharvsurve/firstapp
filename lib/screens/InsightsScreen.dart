import 'package:firstapp/supabase/SupabaseServices.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firstapp/models/Expense.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  List<Expense> _expenses = [];
  Map<String, double> _categoryTotals = {}; // Stores total amount per category
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  // Fetch expenses from Supabase and group them by category
  Future<void> _fetchExpenses() async {
    try {
      setState(() => _isLoading = true); // Show loading while fetching

      List<Expense> expenses = await SupabaseService().fetchExpenses();

      // Group expenses by category and sum the amounts
      Map<String, double> categoryTotals = {};
      for (var expense in expenses) {
        categoryTotals[expense.category] =
            (categoryTotals[expense.category] ?? 0) + expense.amount;
      }

      setState(() {
        _expenses = expenses;
        _categoryTotals = categoryTotals;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching expenses: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF222831), // Dark background for modern UI
      body: RefreshIndicator(
        onRefresh: _fetchExpenses, // Pull-to-refresh functionality
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : _categoryTotals.isEmpty
                ? Center(
                    child: Text(
                      "No expense data available",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16.0 , 80.0 , 16.0 , 16.0 ),
                    child: Column(
                      children: [
                        _buildSummaryCard(), // Displays total spending
                        SizedBox(height: 20),
                        Expanded(
                          child: Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(0xFF222831), // Dark theme contrast
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                  offset: Offset(0, 5),
                                )
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Spending Breakdown",
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 15),
                                Expanded(child: _buildPieChart()), // Pie Chart
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  // Summary Card - Shows Total Spending
  Widget _buildSummaryCard() {
    double totalSpent =
        _categoryTotals.values.fold(0, (sum, value) => sum + value);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFF091057), // Dark blue with elevation
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            spreadRadius: 2,
            offset: Offset(0, 5),
          )
        ],
      ),
      child: Column(
        children: [
          Text(
            "Total Spending",
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
          SizedBox(height: 8),
          Text(
            "₹${totalSpent.toStringAsFixed(2)}",
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Build Pie Chart
  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 50,
        sections: _categoryTotals.entries.map((entry) {
          return PieChartSectionData(
            value: entry.value,
            title: "${entry.key}\n₹${entry.value.toStringAsFixed(2)}",
            color: _getCategoryColor(entry.key),
            radius: 90, // Larger for better visibility
            titleStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList(),
      ),
    );
  }

  // Assign a unique color for each category
  Color _getCategoryColor(String category) {
    final Map<String, Color> categoryColors = {
      'Food': Color(0xFF3498DB), // Blue
      'Utilities': Color(0xFF2ECC71), // Green
      'Entertainment': Color(0xFFE67E22), // Orange
      'Transport': Color(0xFFE74C3C), // Red
      'Others': Color(0xFF9B59B6), // Purple
    };
    return categoryColors[category] ?? Colors.grey;
  }
}
