import 'package:firstapp/supabase/SupabaseServices.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firstapp/models/Expense.dart';
import 'package:intl/intl.dart'; // Import for date formatting

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  List<Expense> _expenses = [];
  List<String> _dates = []; // List of unique dates
  Map<String, Map<String, double>> _dateCategoryTotals = {};
  bool _isLoading = true;
  int _currentPage = 0; // Current Page Index

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  // Fetch expenses from Supabase and categorize them by date and category
  Future<void> _fetchExpenses() async {
    try {
      setState(() => _isLoading = true);

      List<Expense> expenses = await SupabaseService().fetchExpenses();

      // Group expenses by date, then by category
      Map<String, Map<String, double>> dateCategoryTotals = {};
      Set<String> uniqueDates = {}; // Store unique dates

      for (var expense in expenses) {
        String expenseDate = expense.date;
        String category = expense.category;

        uniqueDates.add(expenseDate); // Add unique date

        if (!dateCategoryTotals.containsKey(expenseDate)) {
          dateCategoryTotals[expenseDate] = {};
        }

        dateCategoryTotals[expenseDate]![category] =
            (dateCategoryTotals[expenseDate]![category] ?? 0) + expense.amount;
      }

      setState(() {
        _expenses = expenses;
        _dateCategoryTotals = dateCategoryTotals;
        _dates = uniqueDates.toList()
          ..sort((a, b) => b.compareTo(a)); // Sort latest first
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
      backgroundColor: Color(0xFF222831),
      body: RefreshIndicator(
        onRefresh: _fetchExpenses,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: Colors.white))
            : _dateCategoryTotals.isEmpty
                ? Center(
                    child: Text(
                      "No expense data available",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )
                : Column(
                    children: [
                      SizedBox(height: 60),
                      Expanded(
                        child: PageView.builder(
                          itemCount: _dates.length,
                          controller: PageController(initialPage: 0),
                          onPageChanged: (index) {
                            setState(() {
                              _currentPage = index;
                            });
                          },
                          itemBuilder: (context, index) {
                            return _buildDatePieChart(_dates[index],
                                _dateCategoryTotals[_dates[index]] ?? {});
                          },
                        ),
                      ),
                      _buildPageIndicator(),
                      SizedBox(height: 20),
                    ],
                  ),
      ),
    );
  }

  // Page Indicator (Dots) , will decide if have to keep it or not 
  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_dates.length, (index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 12 : 8,
          height: _currentPage == index ? 12 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Colors.blueAccent : Colors.grey,
          ),
        );
      }),
    );
  }

  // Build Pie Chart for a specific date here 
  Widget _buildDatePieChart(String date, Map<String, double> categoryTotals) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF222831),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Color(0xFFD9D9D9)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _formatDate(date), 
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 15),
            Expanded(child: _buildPieChart(categoryTotals)), 
          ],
        ),
      ),
    );
  }

  // Build Pie Chart Based on Category Totals for a Specific Date
  Widget _buildPieChart(Map<String, double> categoryTotals) {
    return PieChart(
      PieChartData(
        sectionsSpace: 2,
        centerSpaceRadius: 50,
        sections: categoryTotals.entries.map((entry) {
          return PieChartSectionData(
            value: entry.value,
            title: "${entry.key}\n₹${entry.value.toStringAsFixed(2)}",
            color: _getCategoryColor(entry.key),
            radius: 90, 
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
      'Food': Color(0xFF3498DB),
      'Utilities': Color(0xFF2ECC71),
      'Entertainment': Color(0xFFE67E22),
      'Transport': Color(0xFFE74C3C),
      'Others': Color(0xFF9B59B6), 
    };
    return categoryColors[category] ?? Colors.grey;
  }


  String _formatDate(String date) {
    DateTime parsedDate = DateFormat('yyyy-MM-dd').parse(date);
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(Duration(days: 1));

    if (DateFormat('yyyy-MM-dd').format(parsedDate) ==
        DateFormat('yyyy-MM-dd').format(now)) {
      return "Today";
    } else if (DateFormat('yyyy-MM-dd').format(parsedDate) ==
        DateFormat('yyyy-MM-dd').format(yesterday)) {
      return "Yesterday";
    } else {
      return DateFormat('dd MMM yyyy').format(parsedDate); // E.g., 05 Feb 2024
    }
  }
}
