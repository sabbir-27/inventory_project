import 'package:flutter/material.dart';
import 'InvoiceData.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'InvoicePage.dart'; // Import InvoicePage

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final TextEditingController _searchController = TextEditingController();
  
  List<Map<String, dynamic>> _filteredInvoices = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInvoices() async {
    setState(() {
      _isLoading = true;
    });
    await InvoiceData.fetchInvoices(); // Fetch latest from backend (sorted by date desc)
    if (mounted) {
      setState(() {
        _filteredInvoices = List.from(InvoiceData.invoices);
        if (_searchController.text.isNotEmpty) {
          _onSearchChanged();
        }
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged() {
    setState(() {
      String query = _searchController.text.toLowerCase();
      _filteredInvoices = InvoiceData.invoices.where((invoice) {
        return invoice["id"].toString().toLowerCase().contains(query) ||
               invoice["customer"].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  Future<void> _generateAndOpenPdf(Map<String, dynamic> invoice) async {
    final pdf = pw.Document();

    // Prepare items logic
    List<Map<String, dynamic>> items = [];
    if (invoice['items'] != null) {
      items = List<Map<String, dynamic>>.from(invoice['items']);
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text(invoice['date'].toString(), style: const pw.TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Billed To:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                      pw.Text(invoice['customer']),
                      pw.Text(invoice['phone'] ?? ""),
                      pw.Text(invoice['address'] ?? ""),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text("Invoice ID: ${invoice['id']}"),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Table.fromTextArray(
                context: context,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                data: <List<String>>[
                  <String>['Item Name', 'Qty', 'Price', 'Total'],
                  if (items.isNotEmpty)
                    ...items.map((item) => [
                      item['name']?.toString() ?? "Item",
                      (item['qty'] ?? 1).toString(),
                      (item['price'] ?? 0).toString(),
                      ((item['qty'] ?? 1) * (item['price'] ?? 0)).toStringAsFixed(2)
                    ])
                  else
                    ['Item Name', '1', invoice['amount'].toString(), invoice['amount'].toString()] 
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("Subtotal: ${invoice['subtotal'] ?? invoice['amount']}"),
                      pw.Text("Discount: ${invoice['discount'] ?? '0.00'}"),
                      pw.SizedBox(height: 4),
                      pw.Text("Total: ${invoice['amount']}", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 2),
                      pw.Text("Paid: ${invoice['paid'] ?? invoice['amount']}"),
                      pw.Text("Due: ${invoice['due'] ?? '0.00'}", style: pw.TextStyle(color: PdfColors.red)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Center(child: pw.Text("Thank you for your business!", style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey))),
            ],
          );
        },
      ),
    );

    // Open the PDF preview
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: 'Invoice_${invoice['id']}.pdf',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        elevation: 4,
        shadowColor: Colors.black26,
        backgroundColor: const Color(0xFF0066CC), 
        foregroundColor: Colors.white,
        title: const Text("Reports", style: TextStyle(fontWeight: FontWeight.w600)),
      ),
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: const TabBar(
                labelColor: Color(0xFF0066CC),
                unselectedLabelColor: Colors.grey,
                indicatorColor: Color(0xFF0066CC),
                tabs: [
                  Tab(text: "Sales"),
                  Tab(text: "Inventory"),
                  Tab(text: "Invoices"),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildSalesTab(),
                  _buildInventoryTab(),
                  _buildInvoicesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSalesTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCard("Total Sales", "৳ 1,25,430", Icons.payments, Colors.green),
        const SizedBox(height: 16),
        _buildSummaryCard("Total Orders", "342", Icons.shopping_bag, Colors.blue),
        const SizedBox(height: 16),
        const Text("Monthly Sales Trend", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: const Center(child: Text("Chart Placeholder", style: TextStyle(color: Colors.grey))),
        ),
      ],
    );
  }

  Widget _buildInventoryTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildSummaryCard("Total Items", "1,250", Icons.category, Colors.orange),
        const SizedBox(height: 16),
        _buildSummaryCard("Low Stock Items", "12", Icons.warning, Colors.red),
        const SizedBox(height: 16),
        const Text("Stock Value", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
         _buildSummaryCard("Total Value", "৳ 5,40,000", Icons.monetization_on, Colors.purple),
      ],
    );
  }

  Widget _buildInvoicesTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: "Search invoices or customers...",
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () => _searchController.clear(),
                    ) 
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
              ),
            ),
          ),
        ),
        Expanded(
          child: _filteredInvoices.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text("No invoices found", style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadInvoices,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _filteredInvoices.length,
                    itemBuilder: (context, index) {
                      final invoice = _filteredInvoices[index];
                      final isPaid = invoice['isPaid'] as bool? ?? false;
                      final amount = (invoice['amount'] as num? ?? 0).toDouble();
                      
                      // Calculate due amount logic
                      double due = 0.0;
                      if (invoice['due'] != null) {
                         due = double.tryParse(invoice['due'].toString()) ?? 0.0;
                      } else {
                         due = isPaid ? 0.0 : amount;
                      }

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () async {
                              // Navigate to InvoicePage for editing, passing the invoice
                              // Await for return to refresh list (in case it was updated)
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InvoicePage(invoice: invoice),
                                ),
                              );
                              _loadInvoices(); // Refresh list on return
                            },
                            borderRadius: BorderRadius.circular(12),
                            hoverColor: const Color(0xFF0066CC).withValues(alpha: 0.05),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0066CC).withValues(alpha: 0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.receipt_long, color: Color(0xFF0066CC), size: 24),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(invoice['id']?.toString() ?? "N/A", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${invoice['customer']}", 
                                          style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w500)
                                        ),
                                        if (invoice['phone'] != null && (invoice['phone'] as String).isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2.0),
                                            child: Row(
                                              children: [
                                                Icon(Icons.phone, size: 12, color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text("${invoice['phone']}", style: TextStyle(fontSize: 12, color: Colors.grey[700])),
                                              ],
                                            ),
                                          ),
                                        if (invoice['address'] != null && (invoice['address'] as String).isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(top: 2.0),
                                            child: Row(
                                              children: [
                                                Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    "${invoice['address']}", 
                                                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "${invoice['date']}", 
                                          style: TextStyle(fontSize: 11, color: Colors.grey[500])
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("৳ ${amount.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                      if (due > 0)
                                         Padding(
                                           padding: const EdgeInsets.only(top: 2.0),
                                           child: Text("Due: ৳ ${due.toStringAsFixed(2)}", style: const TextStyle(fontSize: 11, color: Colors.red, fontWeight: FontWeight.w600)),
                                         ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isPaid ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          isPaid ? "PAID" : "UNPAID",
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isPaid ? Colors.green : Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ),
        // Summary Footer
        if (_filteredInvoices.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -5)),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("${_filteredInvoices.length} Invoices", style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold)),
                Text(
                  "Total: ৳ ${_filteredInvoices.fold<double>(0, (sum, item) => sum + (item['amount'] as num? ?? 0).toDouble()).toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0066CC)),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          hoverColor: color.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                    const SizedBox(height: 4),
                    Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
