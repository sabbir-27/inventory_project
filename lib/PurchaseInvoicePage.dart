import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'PurchaseData.dart';

class PurchaseInvoicePage extends StatefulWidget {
  const PurchaseInvoicePage({super.key});

  @override
  State<PurchaseInvoicePage> createState() => _PurchaseInvoicePageState();
}

class _PurchaseInvoicePageState extends State<PurchaseInvoicePage> {
  final List<Map<String, dynamic>> _items = [
    {"name": "", "qty": 1, "price": 0.0}
  ];
  final List<FocusNode> _nameFocusNodes = [];
  
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _transportController = TextEditingController();
  final TextEditingController _laborController = TextEditingController();
  final TextEditingController _paidController = TextEditingController();
  
  // Supplier Controllers
  final TextEditingController _supplierNameController = TextEditingController();
  final TextEditingController _supplierPhoneController = TextEditingController();
  final TextEditingController _supplierAddressController = TextEditingController();
  
  double _discount = 0.0;
  double _transportCost = 0.0;
  double _laborCost = 0.0;
  double _paid = 0.0;
  
  DateTime _selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
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
    _transportController.dispose();
    _laborController.dispose();
    _paidController.dispose();
    _supplierNameController.dispose();
    _supplierPhoneController.dispose();
    _supplierAddressController.dispose();
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

  double get _total => _subtotal - _discount + _transportCost + _laborCost;
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

  void _showSupplierPhoneSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Search Supplier by Mobile"),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: 5, // Mock data
            itemBuilder: (context, index) {
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF0066CC).withOpacity(0.1),
                  child: const Icon(Icons.phone, color: Color(0xFF0066CC)),
                ),
                title: Text("+880171234567$index", style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(index % 2 == 0 ? "ABC Traders" : "XYZ Supplies"),
                onTap: () {
                  setState(() {
                    _supplierNameController.text = index % 2 == 0 ? "ABC Traders" : "XYZ Supplies";
                    _supplierPhoneController.text = "+880171234567$index";
                    _supplierAddressController.text = "Shop #${index + 10}, Market Road, Dhaka";
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

  void _savePurchase() {
    // Validate Supplier Name
    if (_supplierNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter supplier name"), backgroundColor: Colors.red),
      );
      return;
    }
    // Validate Items
    if (_items.isEmpty || (_items.length == 1 && (_items[0]['name'] as String).isEmpty)) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one item"), backgroundColor: Colors.red),
      );
      return;
    }

    // Create Purchase Object
    final newPurchase = {
      "id": "PO-2023-${1000 + DateTime.now().millisecondsSinceEpoch % 1000}",
      "supplier": _supplierNameController.text,
      "phone": _supplierPhoneController.text,
      "address": _supplierAddressController.text,
      "date": _formatDate(_selectedDate),
      "amount": _total,
      "paid": _paid,
      "due": _due,
      "status": _due <= 0 ? "Completed" : "Pending",
      "items": List.from(_items),
    };

    // Add to shared data
    PurchaseData.addPurchase(newPurchase);

    // Show success and pop
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Purchase Recorded Successfully"),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Purchase Invoice", style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
             icon: const Icon(Icons.print_outlined),
             tooltip: "Print",
             onPressed: () {},
           ),
           IconButton(
             icon: const Icon(Icons.download_outlined),
             tooltip: "Download",
             onPressed: () {},
           ),
           const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card with Date and Supplier Info
            Card(
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Supplier Details",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0066CC)),
                        ),
                        InkWell(
                          onTap: () => _selectDate(context),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0066CC).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_month, size: 16, color: Color(0xFF0066CC)),
                                const SizedBox(width: 8),
                                Text(
                                  _formatDate(_selectedDate),
                                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF0066CC)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            label: "Supplier Name",
                            icon: Icons.store,
                            controller: _supplierNameController,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            label: "Contact Number",
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            controller: _supplierPhoneController,
                            onSearch: _showSupplierPhoneSearchDialog, // Added search capability
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      label: "Address",
                      icon: Icons.location_on,
                      controller: _supplierAddressController,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Items Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Items",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
                ElevatedButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text("Add Item"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066CC),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Items List
            Card(
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: Column(
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
                    ),
                    child: const Row(
                      children: [
                        Expanded(flex: 1, child: Text("Sl", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))), // Flex 1
                        Expanded(flex: 5, child: Text("Item Name", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))), // Flex 5
                        Expanded(flex: 2, child: Text("Qty", textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))), // Flex 2
                        Expanded(flex: 3, child: Text("Price", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))), // Flex 3
                        Expanded(flex: 3, child: Text("Total", textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey))), // Flex 3
                        SizedBox(width: 32),
                      ],
                    ),
                  ),
                  
                  // List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    separatorBuilder: (context, index) => const Divider(height: 1),
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
                              child: Text(
                                "${index + 1}",
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ),
                            Expanded(
                              flex: 5,
                              child: TextField(
                                focusNode: _nameFocusNodes[index],
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  hintText: "Product Name",
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                style: const TextStyle(fontWeight: FontWeight.w500),
                                onChanged: (val) => _items[index]["name"] = val,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: TextField(
                                textInputAction: TextInputAction.next,
                                decoration: const InputDecoration(
                                  hintText: "0",
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
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
                                decoration: const InputDecoration(
                                  hintText: "0.0",
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                textAlign: TextAlign.right,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                                ],
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
                                textAlign: TextAlign.right,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                              onPressed: () => _removeItem(index),
                              splashRadius: 20,
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

            // Footer Calculation
            Card(
              elevation: 2,
              shadowColor: Colors.black.withOpacity(0.05),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _buildSummaryRow("Subtotal", "৳ ${_subtotal.toStringAsFixed(2)}"),
                    const SizedBox(height: 12),
                    _buildCostInputRow("Discount", _discountController, (val) {
                        setState(() {
                            _discount = double.tryParse(val) ?? 0.0;
                        });
                    }, prefix: "- ৳ ", color: Colors.red),
                    const SizedBox(height: 12),
                    _buildCostInputRow("Transport Cost", _transportController, (val) {
                        setState(() {
                            _transportCost = double.tryParse(val) ?? 0.0;
                        });
                    }, prefix: "+ ৳ "),
                    const SizedBox(height: 12),
                    _buildCostInputRow("Labor Cost", _laborController, (val) {
                        setState(() {
                            _laborCost = double.tryParse(val) ?? 0.0;
                        });
                    }, prefix: "+ ৳ "),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Divider(),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Payable",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        Text(
                          "৳ ${_total.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF0066CC)),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    // Paid Amount
                    _buildCostInputRow("Paid Amount", _paidController, (val) {
                        setState(() {
                            _paid = double.tryParse(val) ?? 0.0;
                        });
                    }, prefix: "৳ ", color: Colors.green),
                    
                    const SizedBox(height: 8),
                    // Due Amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Due Amount",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
                        Text(
                          "৳ ${_due.toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                        ),
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
                onPressed: _savePurchase,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066CC),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 4,
                  shadowColor: const Color(0xFF0066CC).withOpacity(0.4),
                ),
                child: const Text("SAVE PURCHASE", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label, 
    required IconData icon, 
    TextInputType? keyboardType, 
    List<TextInputFormatter>? inputFormatters, 
    TextEditingController? controller,
    VoidCallback? onSearch,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: Colors.grey),
        suffixIcon: onSearch != null 
            ? IconButton(
                icon: const Icon(Icons.search, color: Color(0xFF0066CC)),
                onPressed: onSearch,
                tooltip: "Search",
              )
            : null,
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

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  Widget _buildCostInputRow(String label, TextEditingController controller, Function(String) onChanged, {String prefix = "৳ ", Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        SizedBox(
          width: 120,
          child: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.right,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
            ],
            decoration: InputDecoration(
              hintText: "0.00",
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
