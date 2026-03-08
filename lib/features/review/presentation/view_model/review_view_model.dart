import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/services/hive/hive_service.dart';
import 'package:sneak_fit/core/api/api_client.dart';
import 'package:sneak_fit/core/api/api_endpoints.dart';
import 'package:sneak_fit/features/review/domain/entities/review_entity.dart';

final reviewViewModelProvider = StateNotifierProvider<ReviewViewModel, ReviewState>((ref) {
  return ReviewViewModel(
    ref.read(apiClientProvider),
    ref.read(hiveServiceProvider),
  );
});

class ReviewState {
  final List<ReviewEntity> reviews;
  final bool isLoading;
  final String? error;
  final bool isSubmitting;

  ReviewState({
    this.reviews = const [],
    this.isLoading = false,
    this.error,
    this.isSubmitting = false,
  });

  ReviewState copyWith({
    List<ReviewEntity>? reviews,
    bool? isLoading,
    String? error,
    bool? isSubmitting,
  }) {
    return ReviewState(
      reviews: reviews ?? this.reviews,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSubmitting: isSubmitting ?? this.isSubmitting,
    );
  }
}

class ReviewViewModel extends StateNotifier<ReviewState> {
  final ApiClient _apiClient;
  final HiveService _hiveService;

  ReviewViewModel(this._apiClient, this._hiveService) : super(ReviewState());

  // Memory cache to make UI instant during session
  final Map<String, List<ReviewEntity>> _memoryCache = {};
  final Map<String, DateTime> _lastFetched = {};

  Future<void> fetchProductReviews(String productId) async {
    // 1. Check memory cache first (Instant)
    if (_memoryCache.containsKey(productId)) {
      state = state.copyWith(reviews: _memoryCache[productId], isLoading: false);
      
      // Throttle: If we fetched this in the last 60 seconds, don't hit the server
      final lastFetch = _lastFetched[productId];
      if (lastFetch != null && DateTime.now().difference(lastFetch).inSeconds < 60) {
        return;
      }
    }

    state = state.copyWith(error: null);

    // 2. Load from local/Hive if not in memory or to verify
    final localReviewsData = await _hiveService.getReviews(productId);
    if (localReviewsData != null && localReviewsData.isNotEmpty) {
      final localReviews = localReviewsData.map((json) => ReviewEntity.fromJson(json)).toList();
      _memoryCache[productId] = localReviews;
      state = state.copyWith(reviews: localReviews, isLoading: false);
    } else if (!_memoryCache.containsKey(productId)) {
      // Clear old reviews and show loading ONLY if we have NOTHING in memory
      state = state.copyWith(reviews: [], isLoading: true);
    }

    try {
      final response = await _apiClient.get(ApiEndpoints.productReviews(productId));
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        
        // 3. Save to Hive and Memory
        await _hiveService.saveReviews(productId, List<Map<String, dynamic>>.from(data));
        
        final reviews = data.map((json) => ReviewEntity.fromJson(json)).toList();
        _memoryCache[productId] = reviews;
        _lastFetched[productId] = DateTime.now();
        
        state = state.copyWith(reviews: reviews, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<bool> postReview(ReviewEntity review) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final response = await _apiClient.post(
        ApiEndpoints.reviews,
        data: review.toJson(),
      );
      
      if (response.data['success'] == true) {
        state = state.copyWith(isSubmitting: false);
        // Refresh reviews for this product
        await fetchProductReviews(review.productId);
        return true;
      } else {
        state = state.copyWith(isSubmitting: false, error: response.data['message']);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return false;
    }
  }
}
