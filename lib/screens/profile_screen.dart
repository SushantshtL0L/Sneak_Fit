import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sneak_fit/core/api/api_endpoints.dart';
import 'package:sneak_fit/core/services/biometric_service.dart';
import 'package:sneak_fit/features/auth/presentation/state/auth_state.dart';
import 'package:sneak_fit/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:sneak_fit/features/notification/presentation/pages/notification_screen.dart';
import 'package:sneak_fit/features/sensors/presentation/pages/sensor_lab_screen.dart';
import 'package:sneak_fit/features/auth/presentation/pages/edit_profile_screen.dart';
import 'package:sneak_fit/features/auth/presentation/pages/change_password_screen.dart';
import 'package:sneak_fit/features/item/presentation/pages/my_items_page.dart';
import 'package:sneak_fit/features/item/presentation/pages/seller_analytics_screen.dart';
import 'package:sneak_fit/screens/orders_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    // Fetch user profile when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(authViewModelProvider).authEntity;
      if (user == null) {
        ref.read(authViewModelProvider.notifier).getUserProfile();
      }
    });
    _loadBiometricPreference();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadBiometricPreference() async {
    final enabled = await ref.read(biometricServiceProvider).isBiometricLoginEnabled();
    if (mounted) setState(() => _biometricEnabled = enabled);
  }

  Future<void> _toggleBiometric(bool value) async {
    final service = ref.read(biometricServiceProvider);
    final isAvailable = await service.isAvailable();

    if (!isAvailable) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric authentication is not available on this device.')),
      );
      return;
    }

    if (value) {
      // Verify identity before enabling
      final authenticated = await service.authenticate(
        reason: 'Confirm your biometric to enable fingerprint login',
      );
      if (!authenticated) return;
    }

    await service.setBiometricLoginEnabled(value);
    if (mounted) setState(() => _biometricEnabled = value);
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
                        "Security",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _menuItem(Icons.lock_outline_rounded, 'Change Password',
                          Colors.redAccent, onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
                        );
                      }),
                      _biometricTile(),
                      _menuItem(Icons.delete_outline_rounded, 'Delete Account',
                          Colors.red, onTap: () {
                             ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Request to delete account sent. Please contact support.")),
                            );
                          }),

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
                        Icons.sensors_outlined,
                        'Sensor Lab',
                        Colors.deepPurple,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const SensorLabScreen()),
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
            // Role Badge
            if (user?.role != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: user?.role == 'seller' ? Colors.teal : Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  user?.role == 'seller' ? "Seller Account" : "Buyer Account",
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

  Widget _biometricTile() {
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
            color: (_biometricEnabled ? Colors.green : Colors.grey).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.fingerprint,
            color: _biometricEnabled ? Colors.green : Colors.grey,
            size: 22,
          ),
        ),
        title: Text(
          'Fingerprint Login',
          style: TextStyle(
              fontWeight: FontWeight.w500, 
              fontSize: 15,
              color: isDark ? Colors.white : Colors.black,
          ),
        ),
        subtitle: Text(
          _biometricEnabled ? 'Enabled — tap to disable' : 'Enable quick login with fingerprint',
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
        trailing: Switch(
          value: _biometricEnabled,
          onChanged: _toggleBiometric,
          activeThumbColor: Colors.green,
          activeTrackColor: Colors.green.withValues(alpha: 0.3),
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
