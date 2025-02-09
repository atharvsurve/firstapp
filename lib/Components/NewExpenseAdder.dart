import 'package:firstapp/Components/SnackBar.dart';
import 'package:firstapp/models/Expense.dart';
import 'package:firstapp/supabase/SupabaseServices.dart';
import 'package:flutter/material.dart';

class NewExpenseAdder extends StatefulWidget {
  final TextEditingController expenseNameController;
  final TextEditingController categoryController;
  final TextEditingController amountController;
  final TextEditingController dateController;

  const NewExpenseAdder({
    required this.expenseNameController,
    required this.categoryController,
    required this.amountController,
    required this.dateController,
    super.key,
  });

  @override
  State<NewExpenseAdder> createState() => _NewExpenseAdderState();
}

class _NewExpenseAdderState extends State<NewExpenseAdder> {
  String? _selectedCategory = 'Food'; // Default selected category
  TextEditingController _otherCategoryController = TextEditingController();

  // List of predefined categories
  final List<String> _categories = [
    'Food',
    'Utilities',
    'Entertainment',
    'Transport'
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      width: MediaQuery.of(context).size.width * 0.9,
      decoration: BoxDecoration(
        color: Color(0xFF222831), // Dark background for contrast
        border: Border.all(
          color: Color(0xFFEEEEEE),
          width: 0.4,
        ),
        borderRadius: BorderRadius.circular(15), // Rounded corners
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              "Add New Expense",
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),

            // Expense Name Field
            TextField(
              controller: widget.expenseNameController,
              decoration: InputDecoration(
                labelText: "Expense Name",
                labelStyle: TextStyle(color: Colors.white),
                hintText: "Enter the name of the expense",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Color(0xFF31363F), // Darker background for input
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF76ABAE), width: 2),
                ),
              ),
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.text,
            ),
            SizedBox(height: 20),

            // Category Field (Dropdown with "Other" option)
            DropdownButtonFormField<String>(
              dropdownColor: Color(0xFF31363F), // Dark background for dropdown
              value: _selectedCategory,
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue!;
                });
              },
              decoration: InputDecoration(
                labelText: "Category",
                labelStyle: TextStyle(color: Colors.white),
                filled: true,
                fillColor: Color(0xFF31363F), // Darker background for input
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF76ABAE), width: 2),
                ),
              ),
              style: TextStyle(color: Colors.white),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category, style: TextStyle(color: Colors.white)),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // Amount Field
            TextField(
              controller: widget.amountController,
              decoration: InputDecoration(
                labelText: "Amount",
                labelStyle: TextStyle(color: Colors.white),
                hintText: "Enter the amount spent",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Color(0xFF31363F), // Darker background for input
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF76ABAE), width: 2),
                ),
              ),
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.numberWithOptions(decimal: true),
            ),
            SizedBox(height: 20),

            // Date Field
            TextField(
              controller: widget.dateController,
              decoration: InputDecoration(
                labelText: "Date",
                labelStyle: TextStyle(color: Colors.white),
                hintText: "Select the date",
                hintStyle: TextStyle(color: Colors.grey),
                filled: true,
                fillColor: Color(0xFF31363F), // Darker background for input
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF76ABAE), width: 2),
                ),
              ),
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.datetime,
              onTap: () async {
                FocusScope.of(context).requestFocus(FocusNode());
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null) {
  setState(() {
    widget.dateController.text =
        "${pickedDate!.toLocal()}".split(' ')[0];
  });
}

                            },
            ),
            SizedBox(height: 25),

            // Submit Button
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  // Handle the submit action here (send data to the database)
                  String expenseName = widget.expenseNameController.text;
                  String category = _selectedCategory == 'Other'
                      ? _otherCategoryController.text
                      : _selectedCategory!;
                  double amount = double.parse(widget.amountController.text);
                  String date = widget.dateController.text;

                  // Create an Expense model
                  Expense expense = Expense(
                    expenseName: expenseName,
                    category: category,
                    amount: amount,
                    date: date,
                  );

                  // Add the expense to Supabase
                  await SupabaseService().addExpense(expense);
                  showCustomSnackbar(
                    context: context,
                    message: "Added Successfully",
                    isSuccess: true, // Pass false for error messages
                  );

                  setState(() {
                    widget.expenseNameController.clear();
                    widget.amountController.clear();
                    widget.dateController.clear();
                    _selectedCategory = 'Food'; // Reset dropdown to default
                    _otherCategoryController.clear();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF76ABAE), // Button color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                child: Text(
                  "Add Expense",
                  style: TextStyle(fontSize: 18, color: Color(0xFF222831)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
