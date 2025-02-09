import 'package:firstapp/supabase/SupabaseServices.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:firstapp/models/Expense.dart';
import 'package:intl/intl.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  List<Expense> _expenses = [];
  List<String> _dates = [];
  Map<String, Map<String, double>> _dateCategoryTotals = {};
  bool _isLoading = true;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    try {
      setState(() => _isLoading = true);
      List<Expense> expenses = await SupabaseService().fetchExpenses();

      Map<String, Map<String, double>> dateCategoryTotals = {};
      Set<String> uniqueDates = {};

      for (var expense in expenses) {
        String expenseDate = expense.date;
        String category = expense.category;
        uniqueDates.add(expenseDate);

        dateCategoryTotals.putIfAbsent(expenseDate, () => {});
        dateCategoryTotals[expenseDate]![category] =
            (dateCategoryTotals[expenseDate]![category] ?? 0) + expense.amount;
      }

      setState(() {
        _expenses = expenses;
        _dateCategoryTotals = dateCategoryTotals;
        _dates = uniqueDates.toList()..sort((a, b) => b.compareTo(a));
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
        color: Colors.blueAccent,
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

  Widget _buildPageIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_dates.length, (index) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4),
          width: _currentPage == index ? 14 : 8,
          height: _currentPage == index ? 14 : 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _currentPage == index ? Colors.blueAccent : Colors.grey[600],
            boxShadow: [
              if (_currentPage == index)
                BoxShadow(color: Colors.blueAccent, blurRadius: 8),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildDatePieChart(String date, Map<String, double> categoryTotals) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2E3B4E), Color(0xFF222831)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 8,
                offset: Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              _formatDate(date),
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 20),
            Expanded(child: _buildPieChart(categoryTotals)),
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(Map<String, double> categoryTotals) {
    return PieChart(
      PieChartData(
        sectionsSpace: 3,
        centerSpaceRadius: 50,
        sections: categoryTotals.entries.map((entry) {
          return PieChartSectionData(
            value: entry.value,
            title: "${entry.key}\n₹${entry.value.toStringAsFixed(2)}",
            color: _getCategoryColor(entry.key),
            radius: 95,
            titleStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            showTitle: true,
          );
        }).toList(),
        borderData: FlBorderData(show: false),
        startDegreeOffset: 180,
      ),
    );
  }

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
      return DateFormat('dd MMM yyyy').format(parsedDate);
    }
  }
}
