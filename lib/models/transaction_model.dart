class Transaction {
  int id;
  String itemName;
  int change; // Ensure numeric type
  String transactionType;
  int threshold;
  String date;

  // Constructor
  Transaction({
    required this.id,
    required this.itemName,
    required this.change,
    required this.transactionType,
    required this.threshold,
    required this.date,
  });

  // Method to create a Transaction from JSON
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? 0,  // Add null checks to avoid issues
      itemName: json['itemName'] ?? '',
      change: json['change'] ?? 0,
      transactionType: json['transaction-type'] ?? '',  // Make sure keys match exactly
      threshold: json['threshold'] ?? 0,
      date: json['date'] ?? '',
    );
  }



  // Method to convert Transaction to JSON (if needed)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'itemName': itemName,
      'change': change,
      'transactionType': transactionType, // Fixed JSON key name
      'threshold': threshold,
      'date': date,
    };
  }
}
