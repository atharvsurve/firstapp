class Expense {
  final String expenseName;
  final String category;
  final double amount;
  final String date;

  Expense({
    required this.expenseName,
    required this.category,
    required this.amount,
    required this.date,
  });

  // Convert Expense object to a Map for storing in the database
  Map<String, dynamic> toMap() {
    return {
      'expense_name': expenseName,
      'category': category,
      'amount': amount,
      'date': date,
    };
  }

  // Optionally, a factory constructor to create Expense from a Map (useful for fetching data)
  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      expenseName: map['expense_name'],
      category: map['category'],
      amount: map['amount'],
      date: map['date'],
    );
  }
}
