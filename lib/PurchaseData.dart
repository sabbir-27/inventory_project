class PurchaseData {
  static final List<Map<String, dynamic>> purchases = [
    // Initial mock data
    ...List.generate(5, (index) => {
      "id": "PO-2023-00${index + 1}",
      "supplier": index % 2 == 0 ? "ABC Traders" : "XYZ Supplies", 
      "phone": "0171234567$index", // Mock BD Number
      "address": "Shop #${index + 10}, Market Road, Dhaka", // Mock Address
      "date": "Oct 2${index + 1}, 2023",
      "amount": 5000.0 + (index * 500),
      "status": index % 3 == 0 ? "Pending" : "Completed",
    })
  ];

  static void addPurchase(Map<String, dynamic> purchase) {
    purchases.insert(0, purchase);
  }
}
