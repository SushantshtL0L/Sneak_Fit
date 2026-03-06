import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/utils/my_snack_bar.dart';
import 'package:sneak_fit/features/item/presentation/pages/my_items_page.dart';
import 'package:sneak_fit/screens/seller_orders_screen.dart';
import 'package:sneak_fit/screens/shop_analysis_screen.dart';
import 'package:sneak_fit/features/notification/presentation/view_model/notification_view_model.dart';

class SellerDashboardHome extends ConsumerStatefulWidget {
  const SellerDashboardHome({super.key});

  @override
  ConsumerState<SellerDashboardHome> createState() => _SellerDashboardHomeState();
}

class _SellerDashboardHomeState extends ConsumerState<SellerDashboardHome> {
  void _showSendAnnouncementDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedType = 'Announcement';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: Text("Send Announcement", style: TextStyle(color: isDark ? Colors.white : Colors.black)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: titleController,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: "Title (e.g. Flash Sale!)",
                      labelStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[700]),
                      filled: true,
                      fillColor: isDark ? Colors.black26 : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: messageController,
                    maxLines: 3,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: "Message",
                      labelStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[700]),
                      filled: true,
                      fillColor: isDark ? Colors.black26 : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    dropdownColor: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      labelText: "Type",
                      labelStyle: TextStyle(color: isDark ? Colors.grey[500] : Colors.grey[700]),
                      filled: true,
                      fillColor: isDark ? Colors.black26 : Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    items: ['Offer', 'Announcement', 'General']
                        .map((type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setDialogState(() => selectedType = val);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel", style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.tealAccent : Colors.black,
                    foregroundColor: isDark ? Colors.black : Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () async {
                    if (titleController.text.isNotEmpty && messageController.text.isNotEmpty) {
                      await ref.read(notificationViewModelProvider.notifier).createNotification(
                            titleController.text.trim(),
                            messageController.text.trim(),
                            selectedType,
                          );
                      if (mounted) {
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                        showMySnackBar(
                          // ignore: use_build_context_synchronously
                          context: context,
                          message: "Announcement sent successfully!",
                          type: SnackBarType.success,
                        );
                      }
                    }
                  },
                  child: const Text("Send Now"),
                ),
              ],
            );
          },
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  "Seller Dashboard",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.verified, color: Colors.indigo, size: 24),
              ],
            ),
            const SizedBox(height: 32),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9,
              children: [
                _sellerActionCard(
                  "Manage Sales",
                  "Track & update orders",
                  Icons.assessment_outlined,
                  Colors.indigo,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SellerOrdersScreen())),
                ),
                _sellerActionCard(
                  "My Products",
                  "Edit or add inventory",
                  Icons.inventory_2_outlined,
                  Colors.teal,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyItemsPage())),
                ),
                _sellerActionCard(
                  "Marketing",
                  "Send announcements",
                  Icons.campaign_outlined,
                  Colors.orange,
                  onTap: _showSendAnnouncementDialog,
                ),
                _sellerActionCard(
                  "Shop Analysis",
                  "View store growth",
                  Icons.insights_outlined,
                  Colors.purple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ShopAnalysisScreen()),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _sellerActionCard(String title, String subtitle, IconData icon, Color color, {required VoidCallback onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: isDark ? 0.05 : 0.08),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: isDark ? Colors.white12 : Colors.transparent),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[500], fontSize: 11),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}
