import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // Dynamic Base URL based on Platform
  static String get baseUrl {
    if (kIsWeb) return "http://localhost:3000";
    // Android Emulator uses 10.0.2.2 to access host localhost
    if (!kIsWeb && Platform.isAndroid) return "http://10.0.2.2:3000";
    // iOS Simulator, Windows, macOS, Linux use localhost
    return "http://localhost:3000";
  }

  // Login
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/auth/login"), 
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
        return {
          "success": false,
          "message": "Unexpected response format"
        };
      } else {
        return {
          "success": false,
          "message": "Invalid credentials or server error"
        };
      }
    } catch (e) {
      return {
        "success": false,
        "message": "Network error: $e"
      };
    }
  }

  // Fetch all invoices
  static Future<List<dynamic>> getInvoices() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/api/invoices")).timeout(const Duration(seconds: 30));
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Safety check: Ensure decoded response is actually a List
        if (decoded is List) {
          return decoded;
        } else {
          throw Exception("Expected a list of invoices but got ${decoded.runtimeType}");
        }
      } else {
        throw Exception("Failed to load invoices. Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // Create a new invoice
  static Future<Map<String, dynamic>> createInvoice(Map<String, dynamic> invoiceData) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/api/invoices"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(invoiceData),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 201) {
        final decoded = jsonDecode(response.body);
        // Safety check: Ensure decoded response is a Map
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
        throw Exception("Expected an invoice object but got ${decoded.runtimeType}");
      } else {
        throw Exception("Failed to create invoice. Status: ${response.statusCode}, Body: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // Update an invoice
  static Future<Map<String, dynamic>> updateInvoice(String id, Map<String, dynamic> invoiceData) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/api/invoices/$id"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(invoiceData),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
        throw Exception("Expected an invoice object but got ${decoded.runtimeType}");
      } else {
        throw Exception("Failed to update invoice. Status: ${response.statusCode}, Body: ${response.body}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }

  // Delete an invoice
  static Future<void> deleteInvoice(String id) async {
    try {
      final response = await http.delete(
        Uri.parse("$baseUrl/api/invoices/$id"),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode != 200) {
        throw Exception("Failed to delete invoice. Status: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Error: $e");
    }
  }
}
