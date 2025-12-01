import 'package:flutter/material.dart';
import 'LoginPage.dart';
import 'InvoicePage.dart';
import 'UsersListPage.dart';
import 'SettingsPage.dart';
import 'ReportsPage.dart';
import 'StockPage.dart';
import 'AddItemPage.dart';
import 'POSPage.dart';
import 'ProfilePage.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Softer, modern background
      appBar: AppBar(
        toolbarHeight: 80, // Increased height
        elevation: 4, // Added shadow
        shadowColor: Colors.black26, // Defined shadow color
        backgroundColor: const Color(0xFF0066CC), // App Theme Color
        foregroundColor: Colors.white,
        title: const Text(
          "Hardware & Paint Store",
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text("Logout"),
                    content: const Text("Are you sure you want to logout?"),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => LoginPage()),
                                (route) => false,
                          );
                        },
                        child: const Text("Logout", style: TextStyle(color: Color(0xFF0066CC))),
                      ),
                    ],
                  ),
                );
              },
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.2),
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo
            Center(
              child: Container(
                height: 120, // Increased slightly for better visibility
                width: 120,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0), // Added padding for professional look
                  child: Image.asset(
                    'assets/images/logo.jpg',
                    fit: BoxFit.contain, // Changed to contain to avoid cropping
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.store,
                      size: 60,
                      color: Color(0xFF0066CC),
                    ),
                  ),
                ),
              ),
            ),

             // Quick Actions Section
            const Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.8, // Smaller cards
              padding: const EdgeInsets.symmetric(horizontal: 206), // Left & Right gap
              children: [
                _buildActionCard(context, "Invoices", Icons.receipt_long, Colors.purple, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const InvoicePage()));
                }),
                _buildActionCard(context, "Reports", Icons.bar_chart, Colors.orange, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsPage()));
                }),
                _buildActionCard(context, "Stock", Icons.warehouse_outlined, Colors.teal, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const StockPage()));
                }),
                _buildActionCard(context, "Add Item", Icons.add_box_outlined, Colors.blue, onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const AddItemPage()));
                }),
              ],
            ),

            const SizedBox(height: 24),

            // Welcome Section
            const Text(
              "Store Overview",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              "Live updates from your shop floor.",
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),

            // Summary Cards - Row 1
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: "Today's Sales",
                    value: "৳ 42,450",
                    icon: Icons.payments,
                    color: Colors.green,
                    trend: "+12%",
                    isPositive: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    title: "Total Orders",
                    value: "140",
                    icon: Icons.shopping_bag_outlined,
                    color: Colors.blue,
                    trend: "+5%",
                    isPositive: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Summary Cards - Row 2
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard(
                    title: "Pending Invoices",
                    value: "৳ 2,850",
                    icon: Icons.receipt_long_outlined,
                    color: Colors.purple,
                    trend: "4 Pending",
                    isPositive: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard(
                    title: "Low Stock",
                    value: "12 Items",
                    icon: Icons.warning_amber_rounded,
                    color: Colors.orange,
                    trend: "Urgent",
                    isPositive: false,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
// Low Stock Alerts (New Feature)
            _buildSectionTitle("Low Stock Alerts", actionText: "View All"),
            const SizedBox(height: 12),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildLowStockCard("Paint (White, 1L)", "5 cans left", Colors.orange),
                  _buildLowStockCard("Cement Bag (50kg)", "12 bags left", Colors.red),
                  _buildLowStockCard("Steel Rod 8mm", "30 pcs left", Colors.amber),
                  _buildLowStockCard("Hammer (Medium)", "4 pcs left", const Color(0xFF0066CC)),
                  _buildLowStockCard("PVC Pipe (1 inch)", "15 pcs left", Colors.blue),
                  _buildLowStockCard("Wall Putty (20kg)", "6 bags left", Colors.deepOrange),
                ],
              ),
            ),

            const SizedBox(height: 24),

             // Recent Orders (New Feature)
            _buildSectionTitle("Recent Invoices (Reports)"),
             const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 15, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  _buildRecentOrderTile("#ORD-2451", "Customer: John Doe", "৳ 1500.00", "Completed", Colors.green),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildRecentOrderTile("#ORD-2450", "Customer: Sarah Smith", "৳ 850.50", "Pending", Colors.orange),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildRecentOrderTile("#ORD-2449", "Customer: Mike Ross", "৳ 2100.25", "Processing", Colors.blue),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  _buildRecentOrderTile("#ORD-2448", "Customer: Walk-in", "৳ 450.00", "Completed", Colors.green),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF0066CC),
          unselectedItemColor: Colors.grey[400],
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: (index) {
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const POSPage()),
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            }
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined, size: 22), activeIcon: Icon(Icons.dashboard, size: 22), label: "Home"),
            BottomNavigationBarItem(icon: Icon(Icons.point_of_sale, size: 22), activeIcon: Icon(Icons.point_of_sale, size: 22), label: "POS"),
            // BottomNavigationBarItem(icon: Icon(Icons.inventory_2_outlined, size: 22), activeIcon: Icon(Icons.inventory_2, size: 22), label: "Stock"),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline, size: 22), activeIcon: Icon(Icons.person, size: 22), label: "Profile"),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {String? actionText, VoidCallback? onActionTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        if (actionText != null)
          GestureDetector(
            onTap: onActionTap,
            child: Text(
              actionText,
              style: const TextStyle(fontSize: 13, color: Color(0xFF0066CC), fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String trend,
    required bool isPositive,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {}, // Enable tap for hover effect
          borderRadius: BorderRadius.circular(12),
          hoverColor: color.withOpacity(0.15), // Colorful hover
          splashColor: color.withOpacity(0.3), // Colorful splash
          highlightColor: color.withOpacity(0.2), // Colorful highlight
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2), // Boosted color
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(icon, color: color, size: 24),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        color: isPositive ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2), // Boosted color
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 10,
                            color: isPositive ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            trend,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isPositive ? Colors.green : Colors.red,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon, Color color, {VoidCallback? onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap ?? () {},
          borderRadius: BorderRadius.circular(12),
          hoverColor: color.withOpacity(0.15), // Much more colorful hover
          splashColor: color.withOpacity(0.3), // Much more colorful splash
          highlightColor: color.withOpacity(0.2), // Much more colorful highlight
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10), // Increased padding
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2), // Boosted background color
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 32, color: color), // Increased size
                ),
                const SizedBox(height: 8), // Increased spacing
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13, // Increased font size
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLowStockCard(String productName, String stock, Color color) {
    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(12),
          hoverColor: color.withOpacity(0.15), // Colorful hover
          splashColor: color.withOpacity(0.3), // Colorful splash
          highlightColor: color.withOpacity(0.2), // Colorful highlight
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2), // Boosted color
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.warning_amber_rounded, size: 16, color: color),
                ),
                const Spacer(),
                Text(
                  productName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.2),
                ),
                const SizedBox(height: 4),
                Text(
                  stock,
                  style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentOrderTile(String orderId, String subtitle, String amount, String status, Color statusColor) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: Colors.grey[100],
        child: const Icon(Icons.shopping_bag, color: Colors.black54, size: 20),
      ),
      title: Text(orderId, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.2), // Boosted color
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(fontSize: 10, color: statusColor, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
