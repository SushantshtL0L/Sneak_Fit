import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/api/api_client.dart';
import '../../../../core/api/api_endpoints.dart';
import '../../domain/entities/notification_entity.dart';

class NotificationState {
  final List<NotificationEntity> notifications;
  final bool isLoading;
  final String? error;
  final int unreadCount;

  NotificationState({
    required this.notifications,
    this.isLoading = false,
    this.error,
    this.unreadCount = 0,
  });

  NotificationState copyWith({
    List<NotificationEntity>? notifications,
    bool? isLoading,
    String? error,
    int? unreadCount,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      unreadCount: unreadCount ?? this.unreadCount,
    );
  }
}

class NotificationViewModel extends StateNotifier<NotificationState> {
  final ApiClient _apiClient;

  NotificationViewModel(this._apiClient) : super(NotificationState(notifications: [])) {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.get(ApiEndpoints.notifications);
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        final List<NotificationEntity> notifications = data
            .map((json) => NotificationEntity.fromJson(json))
            .toList();
        
        state = state.copyWith(
          notifications: notifications,
          isLoading: false,
          unreadCount: notifications.where((n) => !n.isRead).length, 
        );
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _friendlyError(e));
    }
  }

  Future<void> createNotification(String title, String message, String type) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.post(
        ApiEndpoints.notifications,
        data: {
          'title': title,
          'message': message,
          'type': type.toLowerCase(),
        },
      );
      if (response.data['success'] == true) {
        await fetchNotifications();
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: _friendlyError(e));
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await _apiClient.patch('${ApiEndpoints.notifications}/mark-read');
      if (response.data['success'] == true) {
        final updatedNotifications = state.notifications
            .map((n) => NotificationEntity(
                  id: n.id,
                  title: n.title,
                  message: n.message,
                  type: n.type,
                  isRead: true,
                  createdAt: n.createdAt,
                ))
            .toList();
        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: 0,
        );
      }
    } catch (e) {
      state = state.copyWith(error: _friendlyError(e));
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      final response = await _apiClient.delete('${ApiEndpoints.notifications}/$id');
      if (response.data['success'] == true) {
        final updatedNotifications = state.notifications.where((n) => n.id != id).toList();
        state = state.copyWith(
          notifications: updatedNotifications,
          unreadCount: updatedNotifications.where((n) => !n.isRead).length,
        );
      }
    } catch (e) {
      state = state.copyWith(error: _friendlyError(e));
    }
  }

  String _friendlyError(Object e) {
    if (e is DioException) {
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return 'Server not reachable. Make sure the backend is running and your phone is on the same Wi-Fi network.';
        case DioExceptionType.connectionError:
          return 'No connection to server. Check if the server is running at ${ApiEndpoints.compIpAddress}:5050.';
        case DioExceptionType.badResponse:
          final status = e.response?.statusCode;
          final msg = e.response?.data?['message'];
          return msg != null ? '$msg (HTTP $status)' : 'Server error (HTTP $status)';
        default:
          return e.message ?? 'Something went wrong. Please try again.';
      }
    }
    return e.toString();
  }
}

final notificationViewModelProvider =
    StateNotifierProvider<NotificationViewModel, NotificationState>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return NotificationViewModel(apiClient);
});
