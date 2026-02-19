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

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;
  String? _userRole;

  final List<Widget> _pages = const [
    HomeScreen(),
    ThriftsScreen(),
    WishlistScreen(), // New Middle Page
    CartScreen(),
    ProfileScreen(),
  ];

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
    
    // Use session service as fallback if authState hasn't loaded yet
    final String? role = user?.role ?? _userRole;
    
    // Only show FAB if user is admin or seller 
    final bool showFab = role?.toLowerCase() == 'admin' || role?.toLowerCase() == 'seller';

    return Scaffold(
      appBar: AppBar(
        title: const Text("SneakFit"),
        centerTitle: true,
        elevation: 4,
      ),
      body: _pages[_currentIndex],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (showFab) {
            // Admin/Seller adds product
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddItemScreen()),
            );
          } else {
            // Buyer goes to Wishlist
            setState(() {
              _currentIndex = 2; // Index of WishlistScreen
            });
          }
        },
        backgroundColor: Colors.black,
        child: Icon(
          showFab ? Icons.add : Icons.favorite,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        elevation: 12,
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: SizedBox(
          height: 64, 
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_outlined, 'Home', 0),
              _navItem(Icons.eco_outlined, 'Thrifts', 1),
              const SizedBox(width: 48), // Gap for FAB
              _navItem(Icons.shopping_cart_outlined, 'Cart', 3),
              _navItem(Icons.person_outline, 'Profile', 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;

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
              color: isSelected ? Colors.black : Colors.grey,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11, 
                color: isSelected ? Colors.black : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
