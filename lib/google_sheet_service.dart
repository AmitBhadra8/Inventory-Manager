import 'dart:convert';
import 'package:http/http.dart' as http;
import 'models/inventory_model.dart';
import 'package:intl/intl.dart';

import 'models/transaction_model.dart';


class GoogleSheetService {
  static const String baseUrl =
      "https://script.google.com/macros/s/AKfycbzJDA_8hm_rT8w6sJ8AshMG-dmwqOJZFfu4EhIjLOPeGXMRgDl5gEg9so22wBw6d6C3/exec";

  // Fetch inventory items from Google Sheets
  static Future<List<InventoryItem>> fetchInventory() async {
    final response = await http.get(Uri.parse("$baseUrl?action=getInventory"));

    print("Response from API: ${response.body}");

    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => InventoryItem.fromJson(json)).toList();
    } else {
      throw Exception("Failed to load inventory items");
    }
  }

  // Add a new inventory item
  static Future<bool> addItem({
    required String id,
    required String itemName,
    required String quantity,
    required String price,
    required String threshold,
  }) async {

    String currentDate = DateFormat('yyyy-MM-dd').format(DateTime.now()); // Get today's date


    final response = await http.get(Uri.parse(
        "$baseUrl?action=addItem&id=$id&itemname=$itemName&quantity=$quantity&price=$price&threshold=$threshold"));

    if (response.statusCode == 200) {
      var result = jsonDecode(response.body);
      return result["status"] == "SUCCESS";
    } else {
      return false;
    }
  }

  // Delete an inventory item
  static Future<bool> deleteItem(String id) async {
    final response =
    await http.get(Uri.parse("$baseUrl?action=deleteItem&id=$id"));

    print("Delete API Response: ${response.body}"); // Debugging print

    if (response.statusCode == 200) {
      print("Successfully deleting...");
      final Map<String, dynamic> data = jsonDecode(response.body);
      return data["status"] == "SUCCESS";
    } else {
      print("Not deleting");
      return false;
    }
  }

  // Update an inventory item
  static Future<bool> updateItem({
    required int id,
    required String itemName,
    required int quantity,
    required double price,
    required int threshold,
  }) async {
    final Uri url = Uri.parse(
        "$baseUrl?action=updateItem&id=$id&itemname=$itemName&quantity=$quantity&price=$price&threshold=$threshold");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      return jsonResponse['status'] == "SUCCESS";
    } else {
      return false;
    }
  }

  // Static method to fetch transactions from the API
  static Future<List<Transaction>> fetch_Transactions() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl?action=getTransactions"));
      print("Response: ${response.body}"); // Log the raw response

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        print("Decoded Data: $data"); // Log the decoded data

        if (data != null && data.isNotEmpty) {
          return data.map((json) => Transaction.fromJson(json)).toList();
        } else {
          throw Exception("No transactions found or malformed data");
        }
      } else {
        throw Exception("Failed to load transactions. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching transactions: $e");
      return [];
    }
  }



}
