import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/api/api_client.dart';
import 'package:sneak_fit/core/api/api_endpoints.dart';


class ShopStats {
  final int totalOrders;
  final int pendingOrders;
  final int shippedOrders;
  final int deliveredOrders;
  final int totalProducts;
  final int totalReviews;
  final double totalRevenue;

  ShopStats({
    required this.totalOrders,
    required this.pendingOrders,
    required this.shippedOrders,
    required this.deliveredOrders,
    required this.totalProducts,
    required this.totalReviews,
    required this.totalRevenue,
  });

  factory ShopStats.fromJson(Map<String, dynamic> json) {
    return ShopStats(
      totalOrders: json['totalOrders'] ?? 0,
      pendingOrders: json['pendingOrders'] ?? 0,
      shippedOrders: json['shippedOrders'] ?? 0,
      deliveredOrders: json['deliveredOrders'] ?? 0,
      totalProducts: json['totalProducts'] ?? 0,
      totalReviews: json['totalReviews'] ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ShopStatsState {
  final ShopStats? stats;
  final bool isLoading;
  final String? error;

  ShopStatsState({this.stats, this.isLoading = false, this.error});

  ShopStatsState copyWith({ShopStats? stats, bool? isLoading, String? error}) {
    return ShopStatsState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ShopStatsViewModel extends StateNotifier<ShopStatsState> {
  final ApiClient _apiClient;

  ShopStatsViewModel(this._apiClient) : super(ShopStatsState()) {
    fetchStats();
  }

  Future<void> fetchStats() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.get(ApiEndpoints.shopStats);
      if (response.data['success'] == true) {
        state = state.copyWith(
          stats: ShopStats.fromJson(response.data['data']),
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final shopStatsViewModelProvider =
    StateNotifierProvider<ShopStatsViewModel, ShopStatsState>((ref) {
  return ShopStatsViewModel(ref.read(apiClientProvider));
});

// ---------------------------------------------------------------------------
// UI
// ---------------------------------------------------------------------------
class ShopAnalysisScreen extends ConsumerWidget {
  const ShopAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(shopStatsViewModelProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F7),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black),
        title: Text(
          'Shop Analysis',
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => ref.read(shopStatsViewModelProvider.notifier).fetchStats(),
            icon: Icon(Icons.refresh, color: isDark ? Colors.white : Colors.black),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator(color: isDark ? Colors.tealAccent : Colors.black))
          : state.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
                      const SizedBox(height: 16),
                      Text('Failed to load stats', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () => ref.read(shopStatsViewModelProvider.notifier).fetchStats(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? Colors.tealAccent : Colors.black,
                        ),
                        child: Text('Retry', style: TextStyle(color: isDark ? Colors.black : Colors.white)),
                      ),
                    ],
                  ),
                )
              : _buildContent(context, state.stats!),
    );
  }

  Widget _buildContent(BuildContext context, ShopStats stats) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Revenue Hero Card
          _buildRevenueCard(stats.totalRevenue),
          const SizedBox(height: 20),

          // Order breakdowns
          Text(
            'Orders',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statCard(context, 'Total Orders', stats.totalOrders, Icons.receipt_long_outlined, Colors.indigo),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(context, 'Pending', stats.pendingOrders, Icons.hourglass_empty_outlined, Colors.orange),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statCard(context, 'Shipped', stats.shippedOrders, Icons.local_shipping_outlined, Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(context, 'Delivered', stats.deliveredOrders, Icons.check_circle_outline, Colors.green),
              ),
            ],
          ),

          const SizedBox(height: 20),
          Text(
            'Store',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _statCard(context, 'Products', stats.totalProducts, Icons.inventory_2_outlined, Colors.teal),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _statCard(context, 'Reviews', stats.totalReviews, Icons.star_outline, Colors.amber),
              ),
            ],
          ),

          const SizedBox(height: 20),
          // Order completion rate bar
          _buildCompletionRate(context, stats),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(double revenue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.attach_money, color: Colors.greenAccent, size: 20),
              ),
              const SizedBox(width: 10),
              const Text('Total Revenue', style: TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Rs. ${revenue.toStringAsFixed(0)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'From delivered orders',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _statCard(BuildContext context, String label, int value, IconData icon, Color color) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            '$value',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[500], fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildCompletionRate(BuildContext context, ShopStats stats) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completionRate = stats.totalOrders == 0
        ? 0.0
        : stats.deliveredOrders / stats.totalOrders;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.05 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: isDark ? Colors.white10 : Colors.transparent),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Order Completion Rate',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDark ? Colors.white : Colors.black87),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: completionRate,
              minHeight: 10,
              backgroundColor: isDark ? Colors.black26 : Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(isDark ? Colors.tealAccent : Colors.green),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(completionRate * 100).toStringAsFixed(1)}% of orders successfully delivered',
            style: TextStyle(color: isDark ? Colors.grey[600] : Colors.grey[500], fontSize: 12),
          ),
        ],
      ),
    );
  }
}
