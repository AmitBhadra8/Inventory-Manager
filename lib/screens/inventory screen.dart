import 'package:emoto_prac1/screens/stock_in_out.dart';
import 'package:flutter/material.dart';

import '../google_sheet_service.dart';
import '../models/inventory_model.dart';

class InventoryScreen extends StatefulWidget {
  @override
  _InventoryScreenState createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {


  final TextEditingController idController = TextEditingController();
  final TextEditingController itemNameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController thresholdController = TextEditingController();

  List<InventoryItem> inventory = [];

  @override
  void initState() {
    super.initState();
    fetchInventory();
  }


  // Fetch inventory items
  Future<void> fetchInventory() async {
    try {
      List<InventoryItem> data = await GoogleSheetService.fetchInventory();
      print("Fetched ${data.length} items");

      setState(() {
        inventory = data;
      });
    } catch (e) {
      print("Error fetching inventory: $e");
    }
  }

  // Add inventory item
  Future<void> addItem() async {
    String id = idController.text;
    String itemName = itemNameController.text;
    String quantity = quantityController.text;
    String price = priceController.text;
    String threshold = thresholdController.text;

    bool success = await GoogleSheetService.addItem(
      id: id,
      itemName: itemName,
      quantity: quantity,
      price: price,
      threshold: threshold,
    );

    if (success) {
      fetchInventory();
      idController.clear();
      itemNameController.clear();
      quantityController.clear();
      priceController.clear();
      thresholdController.clear();
    } else {
      print("Failed to add inventory item");
    }
  }

  // Delete inventory item
  Future<void> deleteItem() async {
    String id = idController.text;
    if (id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter a valid numeric Item ID")),
      );
      return;
    }

    bool success = await GoogleSheetService.deleteItem(id);

    if (success) {
      setState(() {
        fetchInventory();
        idController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Item deleted successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete item. Please check the ID.")),
      );
    }
  }

  // Update inventory item
  Future<void> updateItem() async {
    String idText = idController.text.trim();
    String itemName = itemNameController.text.trim();
    String quantityText = quantityController.text.trim();
    String priceText = priceController.text.trim();
    String thresholdText = thresholdController.text.trim();

    int? id = int.tryParse(idText);
    int? quantity = int.tryParse(quantityText);
    double? price = double.tryParse(priceText);
    int? threshold = int.tryParse(thresholdText);

    if (id == null || itemName.isEmpty || quantity == null || price == null ||
        threshold == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter valid details")),
      );
      return;
    }

    bool success = await GoogleSheetService.updateItem(
      id: id,
      itemName: itemName,
      quantity: quantity,
      price: price,
      threshold: threshold,
    );

    if (success) {
      setState(() {
        fetchInventory();
        idController.clear();
        itemNameController.clear();
        quantityController.clear();
        priceController.clear();
        thresholdController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Item updated successfully")),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update item. Please check the ID.")),
      );
    }
  }

  List<Map<String, dynamic>> stockList = []; // Store stock data


  @override
  Widget build(BuildContext context) {
    return Scaffold(


      appBar: AppBar(title: Text("Inventory Management")),
      body: Padding(
        padding: EdgeInsets.all(4.0),
        child: Column(
          children: [

            TextField(keyboardType: TextInputType.number,
                controller: idController,
                decoration: InputDecoration(labelText: "ID")),
            TextField(controller: itemNameController,
                decoration: InputDecoration(labelText: "Item Name")),
            TextField(keyboardType: TextInputType.number,
                controller: quantityController,
                decoration: InputDecoration(labelText: "Quantity")),
            TextField(keyboardType: TextInputType.number,
                controller: priceController,
                decoration: InputDecoration(labelText: "Price")),
            TextField(keyboardType: TextInputType.number,
                controller: thresholdController,
                decoration: InputDecoration(labelText: "Threshold")),


            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  SizedBox(width: 10),
                  ElevatedButton(onPressed: addItem, child: Text("Add Item")),
                  SizedBox(width: 10),
                  ElevatedButton(onPressed: deleteItem, child: Text("Delete Item")),
                  SizedBox(width: 10),
                  ElevatedButton(onPressed: updateItem, child: Text("Modify Item")),
                ],
              ),
            ),

            ElevatedButton(onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => StockInOutScreen()));
            }, child: Text("Stock In/OUT")),

            SizedBox(height: 10,),
            // Table Header
            Table(
              border: TableBorder.all(),
              columnWidths: {
                0: FlexColumnWidth(0.7), // ID
                1: FlexColumnWidth(1.3), // Item Name
                2: FlexColumnWidth(0.7), // Quantity
                3: FlexColumnWidth(0.7), // Threshold
                4: FlexColumnWidth(1), // Last Updated
                5: FlexColumnWidth(1), // Stock Status
              },
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey[300]),
                  children: [
                    tableCell("ID", isHeader: true),
                    tableCell("Item Name", isHeader: true),
                    tableCell("Quantity", isHeader: true),
                    tableCell("Threshold", isHeader: true),
                    tableCell("Last Updated", isHeader: true),
                    tableCell("Stock Status", isHeader: true),
                  ],
                ),
              ],
            ),
            Expanded(
              child: inventory.isEmpty
                  ? Center(child: Text("No items found"))
                  : ListView.builder(
                itemCount: inventory.length,
                itemBuilder: (context, index) {
                  final item = inventory[index];

                  // Determine Stock Status based on Threshold
                  String stockStatus = item.quantity < item.threshold
                      ? "⚠ Low Stock"
                      : "Normal";
                  Color stockColor = item.quantity < item.threshold
                      ? Colors.red
                      : Colors.green;

                  return Table(
                    border: TableBorder.all(),
                    columnWidths: {
                      0: FlexColumnWidth(0.7),
                      1: FlexColumnWidth(1.3),
                      2: FlexColumnWidth(0.7),
                      3: FlexColumnWidth(0.7),
                      4: FlexColumnWidth(1),
                      5: FlexColumnWidth(1),
                    },
                    children: [
                      TableRow(
                        children: [
                          tableCell(item.id.toString()),
                          tableCell(item.itemName),
                          tableCell(item.quantity.toString()),
                          tableCell(item.threshold.toString()),
                          // Display Threshold
                          tableCell(item.lastUpdate.toString()),
                          tableCell(stockStatus, textColor: stockColor),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),



          ],
        ),
      ),


    );
  }

  Widget tableCell(String text,
      {bool isHeader = false, Color textColor = Colors.black}) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          fontSize: 16,
          color: textColor, // Apply color dynamically for stock status
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}