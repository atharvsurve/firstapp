import 'package:firstapp/Components/NewExpenseAdder.dart';
import 'package:firstapp/Components/TodaysNote.dart';
import 'package:flutter/material.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  _AddExpenseScreenState createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  // Controllers for text fields
  final TextEditingController expenseNameController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF222831), 
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 100.0, 8.0, 22.0),
                  child: NewExpenseAdder(
                    amountController: amountController,
                    categoryController: categoryController,
                    dateController: dateController,
                    expenseNameController: expenseNameController,
                  )),
            ),
            SizedBox(
              height: 30,
            ),
            Center(
              child: Todaysnote(),
            )
          ],
        ),
      ),
    );
  }
}
