import 'package:intl/intl.dart';

class InventoryItem {
  final int id;
  final String itemName;
  final int quantity;
  final double price;
  final int threshold;
  final String lastUpdate;

  InventoryItem({
    required this.id,
    required this.itemName,
    required this.quantity,
    required this.price,
    required this.threshold,
    required this.lastUpdate,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    print("Parsing InventoryItem: $json");

    // Convert the lastUpdate field to a proper date format
    String formattedDate = json['lastupdate'] != null
        ? DateFormat('yyyy-MM-dd').format(DateTime.parse(json['lastupdate']))
        : "N/A";

    return InventoryItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      itemName: json['itemname'] ?? "Unknown Item",
      quantity: int.tryParse(json['quantity'].toString()) ?? 0,
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      threshold: int.tryParse(json['threshold'].toString()) ?? 0,
      lastUpdate: formattedDate,
    );
  }
}

