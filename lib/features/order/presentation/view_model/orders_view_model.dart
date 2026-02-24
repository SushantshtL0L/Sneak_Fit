import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/api/api_client.dart';
import 'package:sneak_fit/core/api/api_endpoints.dart';
import 'package:sneak_fit/features/order/domain/entities/order_entity.dart';

final ordersViewModelProvider = StateNotifierProvider<OrdersViewModel, OrdersState>((ref) {
  return OrdersViewModel(ref.read(apiClientProvider));
});

class OrdersState {
  final List<OrderEntity> orders;
  final bool isLoading;
  final String? error;

  OrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  OrdersState copyWith({
    List<OrderEntity>? orders,
    bool? isLoading,
    String? error,
  }) {
    return OrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class OrdersViewModel extends StateNotifier<OrdersState> {
  final ApiClient _apiClient;

  OrdersViewModel(this._apiClient) : super(OrdersState());

  Future<void> fetchOrders() async {
    state = state.copyWith(isLoading: true, error: null);
    final url = ApiEndpoints.getUserOrders;
    try {
      final response = await _apiClient.get(url);
      
      if (response.data['success'] == true) {
        debugPrint("[OrdersVM] Fetch Success: ${response.data['data']?.length} items");
        final List<dynamic> data = response.data['data'] ?? [];
        final orders = data.map((json) => _mapOrderV4(json)).toList();
        state = state.copyWith(orders: orders, isLoading: false, error: null);
      } else {
        final msg = response.data['message'] ?? "Unknown API Error";
        debugPrint("[OrdersVM] API Error: $msg");
        state = state.copyWith(isLoading: false, error: msg);
      }
    } catch (e) {
      debugPrint("[OrdersVM] Exception: $e");
      state = state.copyWith(
        isLoading: false, 
        error: "COMMUNICATION_ERROR: ${e.toString()}"
      );
    }
  }

  Future<void> fetchAllOrders() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.get('orders/all');
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        final orders = data.map((json) => _mapOrderV4(json)).toList();
        state = state.copyWith(orders: orders, isLoading: false, error: null);
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "FETCH_ALL_ERROR: ${e.toString()}");
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.put(
        'orders/$orderId/status',
        data: {'status': status.toLowerCase()},
      );
      
      if (response.data['success'] == true) {
        await fetchAllOrders();
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> cancelOrder(String orderId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.put(ApiEndpoints.cancelOrder(orderId));
      
      if (response.data['success'] == true) {
        // Refresh orders list
        await fetchOrders();
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  OrderEntity _mapOrderV4(dynamic jsonData) {
    try {
      if (jsonData == null || jsonData is! Map) {
        return _generateEmptyOrder();
      }

      final json = Map<String, dynamic>.from(jsonData);
      
      return OrderEntity(
        id: json['_id']?.toString() ?? '',
        totalAmount: _asDouble(json['totalAmount']),
        paymentMethod: json['paymentMethod']?.toString() ?? 'cod',
        status: json['status']?.toString() ?? 'pending',
        createdAt: json['createdAt'] != null 
            ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
        items: _mapOrderItems(json['items']),
        userName: _extractUserName(json['user']),
        shippingAddress: _mapShippingAddress(json['shippingAddress']),
      );
    } catch (e, stack) {
      debugPrint("MAP_ORDER_ERROR: $e\n$stack");
      return _generateEmptyOrder();
    }
  }

  double _asDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  int _asInt(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  String? _extractUserName(dynamic userData) {
    if (userData == null) return null;
    if (userData is Map) {
      return userData['name']?.toString() ?? userData['userName']?.toString();
    }
    return userData.toString();
  }

  ShippingAddressEntity? _mapShippingAddress(dynamic data) {
    if (data == null || data is! Map) return null;
    try {
      final json = Map<String, dynamic>.from(data);
      return ShippingAddressEntity(
        fullName: json['fullName']?.toString() ?? 'N/A',
        phone: json['phone']?.toString() ?? 'N/A',
        address: json['address']?.toString() ?? 'N/A',
        city: json['city']?.toString() ?? 'N/A',
      );
    } catch (e) {
      debugPrint("MAP_ADDRESS_ERROR: $e");
      return null;
    }
  }

  List<OrderItemEntity> _mapOrderItems(dynamic itemsData) {
    if (itemsData == null || itemsData is! List) return [];
    
    return itemsData.map((itemData) {
      try {
        if (itemData == null || itemData is! Map) {
          throw "Item data is not a map";
        }
        final item = Map<String, dynamic>.from(itemData);
        return OrderItemEntity(
          product: item['product']?.toString() ?? '',
          name: item['name']?.toString() ?? 'Unknown Product',
          price: _asDouble(item['price']),
          quantity: _asInt(item['quantity']),
          size: item['size']?.toString() ?? 'N/A',
          image: item['image']?.toString() ?? '',
        );
      } catch (e) {
        debugPrint("MAP_ITEM_ERROR: $e");
        return const OrderItemEntity(
          product: '',
          name: 'Error loading item',
          price: 0.0,
          quantity: 0,
          size: 'N/A',
          image: '',
        );
      }
    }).toList();
  }

  OrderEntity _generateEmptyOrder() {
    return OrderEntity(
      id: 'error_id',
      totalAmount: 0.0,
      paymentMethod: 'N/A',
      status: 'error',
      createdAt: DateTime.now(),
      items: const [],
    );
  }
}
