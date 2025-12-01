import 'package:flutter/material.dart';
import 'PurchaseInvoicePage.dart';
import 'PurchaseListPage.dart';

class StockPage extends StatelessWidget {
  const StockPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Light grey background like typical modern apps
      appBar: AppBar(
        title: const Text(
          "Stock Management",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Promo/Banner Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0066CC), // Changed to #0066CC
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: const NetworkImage("https://www.transparenttextures.com/patterns/cubes.png"), // Subtle texture
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.05), BlendMode.dstATop),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Inventory Overview",
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Manage your store items",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Grid Menu
            Expanded(
              child: GridView.count(
                crossAxisCount: 3, // 3 columns for a denser, app-like feel
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
                children: [
                  // Reordered as requested: Suppliers, Purchase List, Purchase Invoice, Sales
                  _buildShwapnoCard(context, "Suppliers", "assets/icons/supplier.png", Icons.local_shipping, () {}),
                  
                  _buildShwapnoCard(context, "Purchase List", "assets/icons/list.png", Icons.list_alt, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PurchaseListPage()),
                    );
                  }),

                  _buildShwapnoCard(context, "Purchase Invoice", "assets/icons/purchase.png", Icons.shopping_bag, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PurchaseInvoicePage()),
                    );
                  }),
                  
                  _buildShwapnoCard(context, "Sales", "assets/icons/sales.png", Icons.shopping_cart, () {}),
                  
                  _buildShwapnoCard(context, "Items", "assets/icons/items.png", Icons.category, () {}),
                  _buildShwapnoCard(context, "Adjustment", "assets/icons/adjustment.png", Icons.tune, () {}),
                  _buildShwapnoCard(context, "Low Stock", "assets/icons/alert.png", Icons.warning_amber_rounded, () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShwapnoCard(BuildContext context, String title, String assetPath, IconData fallbackIcon, VoidCallback onTap) {
    return Column(
      children: [
        Container(
          height: 80,
          width: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Center(
                // Using Icon for now, but named assetPath implies images could be used
                child: Icon(fallbackIcon, size: 32, color: const Color(0xFF0066CC)), // Changed to #0066CC
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
