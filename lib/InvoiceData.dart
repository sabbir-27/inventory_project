import 'apiservice.dart';

class InvoiceData {
  static List<Map<String, dynamic>> invoices = [];

  // Fetch data from API
  static Future<void> fetchInvoices() async {
    try {
      final List<dynamic> data = await ApiService.getInvoices();
      invoices = data.map((item) {
        return Map<String, dynamic>.from(item);
      }).toList();

      // Sort by date descending (recent first)
      invoices.sort((a, b) {
        final aDate = DateTime.tryParse(a['date'] ?? '') ?? DateTime(0);
        final bDate = DateTime.tryParse(b['date'] ?? '') ?? DateTime(0);
        return bDate.compareTo(aDate);
      });
    } catch (e) {
      print("Error fetching invoices: $e");
      invoices = [];
    }
  }

  static void addInvoice(Map<String, dynamic> invoice) {
    invoices.insert(0, invoice);
  }
}
