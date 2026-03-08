import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/storage/user_session_service.dart';

import 'home_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';
import 'thrifts_screen.dart';
import 'wishlist_screen.dart';
import '../features/auth/presentation/view_model/auth_view_model.dart';
import '../features/item/presentation/pages/add_item_screen.dart';
import '../features/item/presentation/pages/my_items_page.dart';
import 'seller_dashboard_home.dart';
import '../features/notification/presentation/pages/notification_screen.dart';
import '../features/notification/presentation/view_model/notification_view_model.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;
  String? _userRole;


  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    final session = await ref.read(userSessionServiceProvider).getUserSession();
    setState(() {
      _userRole = session?.role;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.authEntity;
    final String? role = user?.role ?? _userRole;
    final normalizedRole = role?.toLowerCase().trim();
    final bool isSeller = normalizedRole?.contains('admin') == true || 
                         normalizedRole?.contains('seller') == true;

    // DYNAMIC PAGES BASED ON ROLE
    final List<Widget> pages = isSeller 
      ? [
          const SellerDashboardHome(), 
          const MyItemsPage(),         
          const SizedBox.shrink(),    
          const ThriftsScreen(),      
          const ProfileScreen(),     
        ]
      : const [
          HomeScreen(),
          ThriftsScreen(),
          WishlistScreen(),   // index 2 – accessible via nav
          CartScreen(),       // index 3 – FAB center
          ProfileScreen(),    // index 4
        ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(isSeller ? "Seller Dashboard" : "SneakFit"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? Colors.black : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final notificationState = ref.watch(notificationViewModelProvider);
              return Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      ref.read(notificationViewModelProvider.notifier).markAllAsRead();
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationScreen()),
                      );
                    },
                    icon: Icon(Icons.notifications_none, color: isDark ? Colors.white : Colors.black),
                  ),
                  if (notificationState.unreadCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${notificationState.unreadCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (isSeller) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddItemScreen()),
            );
          } else {
            setState(() => _currentIndex = 3); // Go to Cart
          }
        },
        backgroundColor: isDark ? Colors.white : Colors.black,
        child: Icon(
          isSeller ? Icons.add : Icons.shopping_cart_rounded,
          color: isDark ? Colors.black : Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        elevation: 12,
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 64, 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: isSeller 
              ? [
                  _navItem(Icons.grid_view_outlined, 'Dash', 0, isDark),
                  _navItem(Icons.inventory_2_outlined, 'Inventory', 1, isDark),
                  const SizedBox(width: 48), // Gap for FAB
                  _navItem(Icons.eco_outlined, 'Thrifts', 3, isDark), // Thrifts shifted
                  _navItem(Icons.person_outline, 'Profile', 4, isDark),
                ]
              : [
                  _navItem(Icons.home_outlined, 'Home', 0, isDark),
                  _navItem(Icons.eco_outlined, 'Thrifts', 1, isDark),
                  const SizedBox(width: 72), // Gap for FAB
                  _navItem(Icons.favorite_border_rounded, 'Wishlist', 2, isDark),
                  _navItem(Icons.person_outline, 'Profile', 4, isDark),
                ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index, bool isDark) {
    final isSelected = _currentIndex == index;
    final activeColor = isDark ? Colors.white : Colors.black;
    final inactiveColor = isDark ? Colors.grey[600] : Colors.grey;

    return InkWell(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24, 
              color: isSelected ? activeColor : inactiveColor,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11, 
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
