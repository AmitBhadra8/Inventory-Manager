import 'package:flutter/material.dart';
import 'package:emoto_prac1/google_sheet_service.dart';
import '../models/transaction_model.dart';

class StockInOutScreen extends StatefulWidget {
  @override
  _StockInOutScreenState createState() => _StockInOutScreenState();
}

class _StockInOutScreenState extends State<StockInOutScreen> {
  bool isLoading = false;
  List<Transaction> transactions = [];
  final TextEditingController _idController = TextEditingController(); // Controller for ID input
  int? enteredId;

  @override
  void initState() {
    super.initState();
    fetchTransactions(); // Call the method when the screen initializes
  }

  // Method to fetch transactions
  Future<void> fetchTransactions() async {
    setState(() {
      isLoading = true; // Indicate that the data is loading
    });

    try {
      List<Transaction> fetchedTransactions = await GoogleSheetService.fetch_Transactions();
      print("Fetched transactions: $fetchedTransactions"); // Log fetched transactions
      setState(() {
        transactions = fetchedTransactions;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false; // Stop loading if there's an error
      });
      print("Error while fetching transactions: $e");
    }
  }


  // Update the change value based on ID
  void updateChangeById(int transactionId, bool isAdding) {
    setState(() {
      // Find the transaction by ID
      Transaction? transactionToUpdate = transactions.firstWhere(
            (transaction) => transaction.id == transactionId,
        orElse: () => Transaction(id: 0, itemName: "", change: 0, transactionType: "", threshold: 0, date: ""),
      );

      if (transactionToUpdate != null) {
        // Increment or decrement the change value
        if (isAdding) {
          transactionToUpdate.change += 1;
        } else {
          transactionToUpdate.change -= 1;
        }

        // Check if the stock is low (change < threshold)
        if (transactionToUpdate.change < transactionToUpdate.threshold) {
          _showLowStockAlert(transactionToUpdate); // Show alert if stock is low
        }
      } else {
        print("Transaction with ID $transactionId not found");
      }
    });
  }

// Method to show the low stock alert
  void _showLowStockAlert(Transaction transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Low Stock Alert"),
          content: Text("Item: ${transaction.itemName} has a low stock!\n"
              "Current Stock: ${transaction.change}\n"
              "Threshold: ${transaction.threshold}"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  // Method to handle the text input for ID
  void handleIdInput(String idText) {
    setState(() {
      enteredId = int.tryParse(idText); // Parse the entered ID as an integer
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Transaction History"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // Show loading spinner while fetching data
            : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TextField to enter ID
            TextField(
              controller: _idController,
              decoration: InputDecoration(
                labelText: 'Enter ID',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              onChanged: handleIdInput, // Handle input change
            ),
            SizedBox(height: 16),
            // Buttons to Add/Subtract change for a specific ID
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Only proceed if the entered ID is valid
                    if (enteredId != null) {
                      updateChangeById(enteredId!, true); // Add to the stock
                    } else {
                      print("Please enter a valid ID.");
                    }
                  },
                  child: Text("In (Add)"),
                ),
                SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    // Only proceed if the entered ID is valid
                    if (enteredId != null) {
                      updateChangeById(enteredId!, false); // Subtract from the stock
                    } else {
                      print("Please enter a valid ID.");
                    }
                  },
                  child: Text("Out (Subtract)"),
                ),
              ],
            ),
            SizedBox(height: 16),
            // Display the transactions in a table
            Table(
              border: TableBorder.all(),
              columnWidths: {
                0: FlexColumnWidth(1), // ID
                1: FlexColumnWidth(2), // Item Name
                2: FlexColumnWidth(1.4), // Change (+/-)
                3: FlexColumnWidth(1.4), // Transaction Type
                4: FlexColumnWidth(1.4), // Threshold
                5: FlexColumnWidth(2), // Date
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[300]),
                  children: [
                    tableCell("ID", isHeader: true),
                    tableCell("Item Name", isHeader: true),
                    tableCell("Change (+/-)", isHeader: true),
                    tableCell("Transaction Type", isHeader: true),
                    tableCell("Threshold", isHeader: true), // New threshold column
                    tableCell("Date", isHeader: true),
                  ],
                ),
                // Populate table rows with transaction data
                for (var transaction in transactions)
                  TableRow(
                    children: [
                      tableCell(transaction.id.toString()),
                      tableCell(transaction.itemName),
                      tableCell(
                        transaction.change.toString(),
                        isHighlighted: transaction.change < transaction.threshold, // Check if change is less than threshold
                      ),
                      tableCell(transaction.transactionType),
                      tableCell(transaction.threshold.toString()), // Display threshold value
                      tableCell(transaction.date),
                    ],
                  ),

              ],
            ),
          ],
        ),
      ),
    );
  }
}

  // Table cell widget to format the table cell data
  Widget tableCell(String text, {bool isHeader = false, bool isHighlighted = false}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: isHeader ? 16 : 14,
          color: isHighlighted ? Colors.red : Colors.black, // Highlight in red if change is lower than threshold
        ),
      ),
    );
  }

