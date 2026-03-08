import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/theme/theme_provider.dart';

import 'package:sneak_fit/core/api/api_endpoints.dart';
import 'package:sneak_fit/features/auth/presentation/state/auth_state.dart';
import 'package:sneak_fit/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:sneak_fit/features/notification/presentation/pages/notification_screen.dart';
import 'package:sneak_fit/features/auth/presentation/pages/edit_profile_screen.dart';
import 'package:sneak_fit/features/item/presentation/pages/my_items_page.dart';
import 'package:sneak_fit/features/item/presentation/pages/seller_analytics_screen.dart';
import 'package:sneak_fit/screens/orders_screen.dart';
import 'package:sneak_fit/screens/experimental_features_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {

  @override
  void initState() {
    super.initState();
    // Fetch user profile when screen loads to ensure we have current role/data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authViewModelProvider.notifier).getUserProfile();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }






  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final user = authState.authEntity;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey[50],
      body: authState.status == AuthStatus.loading && user == null
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: _premiumProfileHeader(user),
                ),
                SliverPadding(
                  padding: const EdgeInsets.all(16),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      const SizedBox(height: 8),
                      const Text(
                        "Account Settings",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _menuItem(
                        Icons.shopping_bag_outlined,
                        'My Orders',
                        Colors.blue,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const OrdersScreen()),
                          );
                        },
                      ),
                      _menuItem(Icons.location_on_outlined, 'Shipping Address',
                          Colors.orange),
                      _menuItem(Icons.payment_outlined, 'Payment Methods',
                          Colors.green),
                      _menuItem(Icons.notifications_none, 'Notifications',
                          Colors.purple, onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const NotificationScreen()),
                        );
                      }),
                      

                      const SizedBox(height: 24),
                      const Text(
                        "Appearance",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _themeSettingsTile(),
                      
                      const SizedBox(height: 24),
                      const Text(
                        "App Features",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      
                      // Seller Side Check
                      if (user?.role == 'seller') ...[
                        _menuItem(
                          Icons.storefront_outlined,
                          'Seller Dashboard',
                          Colors.teal,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const MyItemsPage()),
                            );
                          },
                        ),
                        _menuItem(
                          Icons.analytics_outlined,
                          'Sales Analytics',
                          Colors.indigo,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const SellerAnalyticsScreen()),
                            );
                          },
                        ),
                      ],

                      _menuItem(
                        Icons.science_outlined,
                        'Security & Features',
                        Colors.deepPurple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const ExperimentalFeaturesScreen()),
                          );
                        },
                      ),
                      _logoutButton(context, ref),
                      const SizedBox(height: 40),
                    ]),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _premiumProfileHeader(dynamic user) {
    final String? imageUrl = user?.profileImage != null
        ? "${ApiEndpoints.baseImageUrl}${user?.profileImage}"
        : null;

    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Accent
        Container(
          height: 280,
          margin: const EdgeInsets.only(bottom: 60),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.black, Color(0xFF2C2C2C)],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(40),
              bottomRight: Radius.circular(40),
            ),
          ),
        ),
        Column(
          children: [
            const SizedBox(height: 60),
            // Big Profile Picture
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: ClipOval(
                child: imageUrl != null
                    ? Image(
                        image: CachedNetworkImageProvider(imageUrl),
                        width: 130,
                        height: 130,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person, size: 70, color: Colors.grey),
                      )
                    : Container(
                        width: 130,
                        height: 130,
                        color: Colors.grey[200],
                        child: const Icon(Icons.person, size: 70, color: Colors.grey),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user?.name ?? user?.userName ?? 'SneakFit User',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user?.email ?? 'user@sneakfit.com',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            // Improved Role Badge
            if (user?.role != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: user?.role?.toLowerCase() == 'seller' 
                      ? Colors.teal 
                      : (user?.role?.toLowerCase() == 'admin' ? Colors.redAccent : Colors.blue),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user?.role?.toLowerCase() == 'seller' 
                      ? "Seller Account" 
                      : (user?.role?.toLowerCase() == 'admin' ? "Admin Account" : "Buyer Account"),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text("Edit Profile"),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _menuItem(IconData icon, String title, Color color, {VoidCallback? onTap}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(title,
            style: TextStyle(
                fontWeight: FontWeight.w500, 
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black,
            )),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: isDark ? Colors.grey[600] : Colors.grey),
        onTap: onTap ?? () {},
      ),
    );
  }

  Widget _themeSettingsTile() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeState = ref.watch(themeViewModelProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _themeOption(
                icon: Icons.light_mode_outlined,
                label: 'Light',
                mode: AppThemeMode.light,
                isSelected: themeState.themeMode == AppThemeMode.light,
              ),
              _themeOption(
                icon: Icons.dark_mode_outlined,
                label: 'Dark',
                mode: AppThemeMode.dark,
                isSelected: themeState.themeMode == AppThemeMode.dark,
              ),
              _themeOption(
                icon: Icons.sensors_outlined,
                label: 'Sensor',
                mode: AppThemeMode.sensor,
                isSelected: themeState.themeMode == AppThemeMode.sensor,
              ),
            ],
          ),
          if (themeState.isAutoThemeEnabled) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Theme will automatically switch based on your light sensor readings.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _themeOption({
    required IconData icon,
    required String label,
    required AppThemeMode mode,
    required bool isSelected,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = Colors.green;
    
    return GestureDetector(
      onTap: () => ref.read(themeViewModelProvider.notifier).setThemeMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? activeColor.withValues(alpha: 0.1) 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? activeColor : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? activeColor : (isDark ? Colors.grey[400] : Colors.grey[600]),
              size: 28,
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? activeColor : (isDark ? Colors.grey[400] : Colors.grey[600]),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _logoutButton(BuildContext context, WidgetRef ref) {
    return SizedBox(
      width: double.infinity,
      child: TextButton.icon(
        onPressed: () {
          ref.read(authViewModelProvider.notifier).logout();
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        },
        icon: const Icon(Icons.logout, color: Colors.redAccent),
        label: const Text(
          'Logout Account',
          style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
        ),
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.redAccent.withValues(alpha: 0.2)),
          ),
        ),
      ),
    );
  }
}
