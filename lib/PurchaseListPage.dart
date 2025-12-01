import 'package:flutter/material.dart';
import 'PurchaseData.dart';

class PurchaseListPage extends StatefulWidget {
  const PurchaseListPage({super.key});

  @override
  State<PurchaseListPage> createState() => _PurchaseListPageState();
}

class _PurchaseListPageState extends State<PurchaseListPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredPurchases = [];

  @override
  void initState() {
    super.initState();
    _filteredPurchases = List.from(PurchaseData.purchases);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      String query = _searchController.text.toLowerCase();
      _filteredPurchases = PurchaseData.purchases.where((purchase) {
        final supplier = purchase["supplier"].toString().toLowerCase();
        final phone = (purchase["phone"] ?? "").toString().toLowerCase();
        final id = purchase["id"].toString().toLowerCase();
        
        return supplier.contains(query) || phone.contains(query) || id.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Purchase List", style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search by Supplier or Mobile...",
                  hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
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
                  contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFF0066CC), width: 1.5),
                  ),
                ),
              ),
            ),
          ),
          
          // List
          Expanded(
            child: _filteredPurchases.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text("No purchases found", style: TextStyle(fontSize: 16, color: Colors.grey[500])),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    itemCount: _filteredPurchases.length,
                    itemBuilder: (context, index) {
                      final purchase = _filteredPurchases[index];
                      
                      // Determine Due Amount
                      double due = 0.0;
                      if (purchase['due'] != null) {
                        due = double.tryParse(purchase['due'].toString()) ?? 0.0;
                      } else if (purchase['status'] == 'Pending') {
                        due = double.tryParse(purchase['amount'].toString()) ?? 0.0;
                      }

                      bool isPaid = purchase['status'] == "Completed" || purchase['status'] == "Paid";

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () {}, // Enable tap splash
                            borderRadius: BorderRadius.circular(12),
                            hoverColor: const Color(0xFF0066CC).withOpacity(0.05),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0), // Increased padding
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0066CC).withOpacity(0.1),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF0066CC), size: 24),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          purchase['supplier'], 
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87)
                                        ),
                                        const SizedBox(height: 4),
                                        // Show Mobile Number if available
                                        if (purchase['phone'] != null && (purchase['phone'] as String).isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Row(
                                              children: [
                                                Icon(Icons.phone, size: 12, color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Text(
                                                  purchase['phone'],
                                                  style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                                                ),
                                              ],
                                            ),
                                          ),
                                        // Show Address if available
                                        if (purchase['address'] != null && (purchase['address'] as String).isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(bottom: 4),
                                            child: Row(
                                              children: [
                                                Icon(Icons.location_on, size: 12, color: Colors.grey[600]),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    purchase['address'],
                                                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        Text(
                                          "${purchase['date']}", 
                                          style: TextStyle(fontSize: 12, color: Colors.grey[500], height: 1.3)
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text("Total: ৳ ${purchase['amount']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                      
                                      if (due > 0 && !isPaid)
                                        Padding(
                                          padding: const EdgeInsets.only(top: 4, bottom: 6),
                                          child: Text("Due: ৳ ${due.toStringAsFixed(2)}", style: const TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.w600)),
                                        )
                                      else
                                        const SizedBox(height: 8),

                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: isPaid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(20), // Pill shape
                                        ),
                                        child: Text(
                                          isPaid ? "PAID" : "UNPAID",
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                            color: isPaid ? Colors.green : Colors.red,
                                            letterSpacing: 0.5,
                                          ),
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
        ],
      ),
    );
  }
}
