import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'apiservice.dart';
import 'InvoiceData.dart';

class InvoicePage extends StatefulWidget {
  final Map<String, dynamic>? invoice; // Accept an optional invoice for editing

  const InvoicePage({super.key, this.invoice});

  @override
  State<InvoicePage> createState() => _InvoicePageState();
}

class _InvoicePageState extends State<InvoicePage> {
  @override
  Widget build(BuildContext context) {
    return CreateInvoicePage(invoice: widget.invoice);
  }
}

class CreateInvoicePage extends StatefulWidget {
  final Map<String, dynamic>? invoice; // Receive the invoice for editing

  const CreateInvoicePage({super.key, this.invoice});

  @override
  State<CreateInvoicePage> createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends State<CreateInvoicePage> {
  List<Map<String, dynamic>> _items = [
    {"name": "", "qty": 1, "price": 0.0}
  ];
  final List<FocusNode> _nameFocusNodes = [];

  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _paidController = TextEditingController();
  final TextEditingController _customerNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  double _discount = 0.0;
  double _paid = 0.0;

  DateTime _selectedDate = DateTime.now();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    
    // If an invoice was passed, pre-populate the fields for editing
    if (widget.invoice != null) {
      _isEditing = true;
      final inv = widget.invoice!;
      _customerNameController.text = inv['customer'] ?? "";
      _phoneController.text = inv['phone'] ?? "";
      _addressController.text = inv['address'] ?? "";
      
      // Parse numbers carefully as they might be int or double from backend
      _discount = (inv['discount'] as num? ?? 0.0).toDouble();
      _paid = (inv['paid'] as num? ?? 0.0).toDouble();
      _discountController.text = _discount.toString();
      _paidController.text = _paid.toString();

      // Parse Date
      if (inv['date'] != null) {
        // Try parsing standard date string if possible, else keep current
        try {
           _selectedDate = DateTime.parse(inv['date']);
        } catch (e) {
           // ignore if format doesn't match
        }
      }

      // Parse Items
      if (inv['items'] != null) {
        _items = List<Map<String, dynamic>>.from((inv['items'] as List).map((item) => {
          "name": item['name'],
          "qty": item['qty'],
          "price": (item['price'] as num).toDouble()
        }));
      }
    }

    // Initialize focus nodes for items
    for (int i = 0; i < _items.length; i++) {
      _nameFocusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (var node in _nameFocusNodes) {
      node.dispose();
    }
    _discountController.dispose();
    _paidController.dispose();
    _customerNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() {
      _items.add({"name": "", "qty": 1, "price": 0.0});
      _nameFocusNodes.add(FocusNode());
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _nameFocusNodes.last.requestFocus();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
      _nameFocusNodes[index].dispose();
      _nameFocusNodes.removeAt(index);
    });
  }

  double get _subtotal {
    return _items.fold(0.0, (sum, item) => sum + ((item['qty'] as int) * (item['price'] as double)));
  }

  double get _total => _subtotal - _discount;
  double get _due => _total - _paid;

  String _formatDate(DateTime date) {
    const List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0066CC),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0066CC),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _showPhoneSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Search by Mobile"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 5, // Mock data
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF0066CC).withValues(alpha: 0.1),
                  child: const Icon(Icons.phone, color: Color(0xFF0066CC)),
                ),
                title: Text("+880171234567$index", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text("Customer ${index + 1}"),
                onTap: () {
                  setState(() {
                    _customerNameController.text = "Customer ${index + 1}";
                    _phoneController.text = "+880171234567$index";
                    _addressController.text = "House #${index + 1}, Road #5, Dhaka";
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Future<Uint8List> _generatePdf(Map<String, dynamic> invoice) async {
    final pdf = pw.Document();

    // Colors
    final PdfColor baseColor = PdfColor.fromHex("#0066CC");
    final PdfColor accentColor = PdfColor.fromHex("#F0F4F8");

    final logoImage = await imageFromAssetBundle('assets/images/logo.jpg');

    // Explicitly cast items to the correct type for PDF generation
    final List<Map<String, dynamic>> items = List<Map<String, dynamic>>.from(
      (invoice['items'] as List).map((item) => Map<String, dynamic>.from(item))
    );

    pdf.addPage(
      pw.MultiPage( // Use MultiPage for automatic pagination
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Header Section - Responsive Layout
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 60,
                        height: 60,
                        child: pw.Image(logoImage),
                      ),
                      pw.SizedBox(width: 10),
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text("Your Company Name", style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: baseColor)),
                          pw.SizedBox(height: 4),
                          pw.Text("123 Street Name, Dhaka, Bangladesh", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                          pw.Text("Phone: +880171234567 | Email: info@company.com", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text("INVOICE", style: pw.TextStyle(fontSize: 28, fontWeight: pw.FontWeight.bold, color: baseColor)),
                      pw.SizedBox(height: 4),
                      pw.Text("#${invoice['id']}", style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
                      pw.Text("Date: ${invoice['date']}", style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
                    ],
                  ),
                ),
              ],
            ),
            pw.SizedBox(height: 30),

            // Bill To Section - Responsive Box
            pw.Container(
              padding: const pw.EdgeInsets.all(15),
              decoration: pw.BoxDecoration(
                color: accentColor,
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
              ),
              width: double.infinity, // Make it span full width
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("INVOICE TO:", style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.grey600)),
                        pw.SizedBox(height: 4),
                        pw.Text(invoice['customer'], style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                        if (invoice['phone'] != null && invoice['phone'].toString().isNotEmpty)
                          pw.Text(invoice['phone'], style: const pw.TextStyle(fontSize: 10)),
                        if (invoice['address'] != null && invoice['address'].toString().isNotEmpty)
                          pw.Text(invoice['address'], style: const pw.TextStyle(fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 20),

            // Table Section - Responsive Table
            pw.Table.fromTextArray(
              context: context,
              border: null, // Remove default border for cleaner look
              headerStyle: pw.TextStyle(color: PdfColors.white, fontWeight: pw.FontWeight.bold, fontSize: 10),
              headerDecoration: pw.BoxDecoration(
                color: baseColor,
                borderRadius: const pw.BorderRadius.vertical(top: pw.Radius.circular(4)),
              ),
              cellPadding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              rowDecoration: const pw.BoxDecoration(
                border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5)),
              ),
              columnWidths: {
                0: const pw.FlexColumnWidth(1), // SL
                1: const pw.FlexColumnWidth(4), // Item Description
                2: const pw.FlexColumnWidth(2), // Qty
                3: const pw.FlexColumnWidth(2), // Price
                4: const pw.FlexColumnWidth(2), // Total
              },
              headerAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerRight,
              },
              cellAlignments: {
                0: pw.Alignment.centerLeft,
                1: pw.Alignment.centerLeft,
                2: pw.Alignment.center,
                3: pw.Alignment.centerRight,
                4: pw.Alignment.centerRight,
              },
              data: <List<String>>[
                <String>['SL', 'ITEM DESCRIPTION', 'QTY', 'PRICE', 'TOTAL'],
                ...items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return [
                    (index + 1).toString(),
                    item['name'].toString(),
                    item['qty'].toString(),
                    item['price'].toString(),
                    ((item['qty'] as int) * (item['price'] as double)).toStringAsFixed(2)
                  ];
                }),
              ],
            ),
            pw.SizedBox(height: 20),

            // Totals Section - Responsive Alignment
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Expanded(
                  flex: 1,
                  child: pw.Container(), // Spacer
                ),
                pw.Expanded(
                  flex: 1,
                  child: pw.Column(
                    children: [
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text("Subtotal:", style: const pw.TextStyle(fontSize: 10)),
                          pw.Text(invoice['subtotal']?.toString() ?? '0.00', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold)),
                        ],
                      ),
                      pw.SizedBox(height: 4),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text("Discount:", style: const pw.TextStyle(fontSize: 10, color: PdfColors.red)),
                          pw.Text("- ${invoice['discount']?.toString() ?? '0.00'}", style: const pw.TextStyle(fontSize: 10, color: PdfColors.red)),
                        ],
                      ),
                      pw.Divider(color: PdfColors.grey300),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text("Grand Total:", style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: baseColor)),
                          pw.Text(invoice['amount'].toStringAsFixed(2), style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, color: baseColor)),
                        ],
                      ),
                      pw.SizedBox(height: 8),
                       pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text("Paid:", style: const pw.TextStyle(fontSize: 10, color: PdfColors.green)),
                          pw.Text(invoice['paid']?.toString() ?? '0.00', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.green)),
                        ],
                      ),
                      pw.SizedBox(height: 2),
                       pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text("Balance Due:", style: const pw.TextStyle(fontSize: 10, color: PdfColors.red)),
                          pw.Text(invoice['due']?.toString() ?? '0.00', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, color: PdfColors.red)),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            pw.Spacer(),
            
            // Footer Section
            pw.Container(
              width: double.infinity,
              decoration: pw.BoxDecoration(
                border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300)),
              ),
              padding: const pw.EdgeInsets.only(top: 10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text("Thank you for your business!", style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600, fontStyle: pw.FontStyle.italic)),
                  pw.SizedBox(height: 4),
                  pw.Text("For any inquiries, please contact info@company.com", style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey500)),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _saveInvoice() async {
    // Validate
    if (_customerNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter customer name"), backgroundColor: Colors.red),
      );
      return;
    }

    // Validate phone number: Must be 11 digits if provided
    if (_phoneController.text.isNotEmpty && _phoneController.text.length != 11) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mobile number must be 11 digits"), backgroundColor: Colors.red),
      );
      return;
    }

    if (_items.isEmpty || (_items.length == 1 && (_items[0]['name'] as String).isEmpty)) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one item"), backgroundColor: Colors.red),
      );
      return;
    }

    // Generate ID using Mobile Number if available, else fallback to random
    String generatedId;
    if (_phoneController.text.isNotEmpty) {
      generatedId = _phoneController.text; // Use exact mobile number as ID
    } else {
      generatedId = "INV-2023-00${100 + DateTime.now().millisecondsSinceEpoch % 1000}";
    }

    final invoiceData = {
      // Keep existing ID if editing, else generate new based on mobile
      "id": _isEditing ? widget.invoice!['id'] : generatedId,
      "customer": _customerNameController.text,
      "phone": _phoneController.text,
      "address": _addressController.text,
      "date": DateTime.now().toIso8601String(),
      "subtotal": _subtotal,
      "discount": _discount,
      "amount": _total,
      "paid": _paid,
      "due": _due,
      "isPaid": _due <= 0,
      "items": List.from(_items),
    };

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Processing Invoice..."), duration: Duration(seconds: 2)),
    );

    try {
      if (_isEditing) {
        // Update Existing Invoice
        final mongoId = widget.invoice!['_id'];
        if (mongoId != null) {
           await ApiService.updateInvoice(mongoId, invoiceData);
        } else {
           // Fallback if _id is missing (e.g. local mock data)
           await ApiService.createInvoice(invoiceData);
        }
      } else {
        // Create New Invoice
        await ApiService.createInvoice(invoiceData);
      }

      // Refresh InvoiceData list for ReportsPage
      await InvoiceData.fetchInvoices();

      // Generate PDF for user
      final pdfInvoice = Map<String, dynamic>.from(invoiceData);
      pdfInvoice['date'] = _formatDate(DateTime.now());
      pdfInvoice['subtotal'] = _subtotal.toStringAsFixed(2);
      pdfInvoice['discount'] = _discount.toStringAsFixed(2);
      pdfInvoice['paid'] = _paid.toStringAsFixed(2);
      pdfInvoice['due'] = _due.toStringAsFixed(2);

      final pdfBytes = await _generatePdf(pdfInvoice);
      await Printing.sharePdf(bytes: pdfBytes, filename: 'Invoice_${invoiceData['id']}.pdf');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invoice Saved Successfully"), backgroundColor: Colors.green),
        );
        Navigator.pop(context); // Go back to previous screen (e.g. ReportsPage)
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
        title: Text(_isEditing ? "Edit Invoice" : "Create Invoice"),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: "Print Invoice",
            onPressed: () async {
              _saveInvoice();
            },
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Download PDF",
            onPressed: () {
              _saveInvoice();
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 8),
            child: InkWell(
              onTap: () => _selectDate(context),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(_selectedDate),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Customer Details Section
            Card( 
              elevation: 2,
              shadowColor: Colors.black.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Customer Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0066CC))),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _customerNameController,
                            label: "Customer Name",
                            icon: Icons.person_outline,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _phoneController,
                            label: "Mobile Number",
                            icon: Icons.phone_outlined,
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.search, color: Color(0xFF0066CC)),
                              onPressed: _showPhoneSearchDialog,
                              tooltip: "Search by Phone",
                            ),
                            keyboardType: TextInputType.phone,
                            // Limit to 11 digits
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(11),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _addressController,
                      label: "Customer Address",
                      icon: Icons.location_on_outlined,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Items Section Header with Add Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 const Text("Items List", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
                 ElevatedButton.icon(
                   onPressed: _addItem,
                   icon: const Icon(Icons.add, size: 18),
                   label: const Text("Add Item"),
                   style: ElevatedButton.styleFrom(
                     backgroundColor: const Color(0xFF0066CC),
                     foregroundColor: Colors.white,
                     elevation: 2,
                     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                   ),
                 ),
              ],
            ),
            const SizedBox(height: 12),

            // Items Table
            Card(
              elevation: 2,
              shadowColor: Colors.black.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: Column(
                children: [
                  // Table Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: const Row(
                      children: [
                        Expanded(flex: 1, child: Text("Sl", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                        Expanded(flex: 4, child: Text("Item Name", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                        Expanded(flex: 2, child: Text("Qty", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                        Expanded(flex: 3, child: Text("Price", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                        Expanded(flex: 3, child: Text("Total", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))),
                        SizedBox(width: 32), // Space for delete icon
                      ],
                    ),
                  ),

                  // List Items
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
                    itemBuilder: (context, index) {
                      double qty = (_items[index]["qty"] as int).toDouble();
                      double price = _items[index]["price"] as double;
                      double total = qty * price;

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 1,
                              child: Text("${index + 1}", textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                            ),
                            Expanded(
                              flex: 4,
                              child: TextField(
                                focusNode: _nameFocusNodes[index],
                                textInputAction: TextInputAction.next,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: "Product Name",
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                ),
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                onChanged: (val) {
                                  _items[index]["name"] = val;
                                },
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                textInputAction: TextInputAction.next,
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: "0",
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                ),
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                style: const TextStyle(fontSize: 13),
                                onChanged: (val) {
                                  setState(() {
                                    _items[index]["qty"] = int.tryParse(val) ?? 1;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: TextField(
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _addItem(),
                                textAlign: TextAlign.center,
                                decoration: const InputDecoration(
                                  hintText: "0.0",
                                  border: InputBorder.none,
                                  isDense: true,
                                  contentPadding: EdgeInsets.symmetric(vertical: 8),
                                ),
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
                                style: const TextStyle(fontSize: 13),
                                onChanged: (val) {
                                  setState(() {
                                    _items[index]["price"] = double.tryParse(val) ?? 0.0;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                "৳${total.toStringAsFixed(0)}",
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () => _removeItem(index),
                              splashRadius: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Footer / Totals
            Card(
              elevation: 2,
              shadowColor: Colors.black.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildSummaryRow("Subtotal", "৳ ${_subtotal.toStringAsFixed(2)}"),
                    const SizedBox(height: 24),
                    _buildInputRow("Discount", _discountController, (val) {
                        setState(() {
                          _discount = double.tryParse(val) ?? 0.0;
                        });
                    }, color: Colors.red, prefix: "- ৳ ", width: 160, verticalPadding: 14),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(),
                    ),
                    _buildSummaryRow("Total", "৳ ${_total.toStringAsFixed(2)}", isTotal: true),
                    const SizedBox(height: 24),
                    _buildInputRow("Paid", _paidController, (val) {
                        setState(() {
                          _paid = double.tryParse(val) ?? 0.0;
                        });
                    }, color: Colors.green, prefix: "৳ ", width: 160, verticalPadding: 14),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Due", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
                        Text("৳ ${_due.toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.red)),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _saveInvoice,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066CC),
                  foregroundColor: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  shadowColor: const Color(0xFF0066CC).withValues(alpha: 0.4),
                ),
                child: Text(_isEditing ? "UPDATE INVOICE" : "SAVE INVOICE", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide(color: Color(0xFF0066CC), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        filled: true,
        fillColor: Colors.grey[50],
        isDense: true,
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: isTotal ? Colors.black87 : Colors.grey, fontSize: isTotal ? 18 : 16, fontWeight: isTotal ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isTotal ? 24 : 16, color: isTotal ? const Color(0xFF0066CC) : Colors.black87)),
      ],
    );
  }

  Widget _buildInputRow(String label, TextEditingController controller, Function(String) onChanged, {Color? color, String prefix = "৳ ", double width = 120, double verticalPadding = 8}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        SizedBox(
          width: width,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.right,
            inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
            decoration: InputDecoration(
              hintText: "0.00",
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: verticalPadding),
              prefixText: prefix,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF0066CC)),
              ),
            ),
            style: TextStyle(fontWeight: FontWeight.bold, color: color ?? Colors.black87),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
