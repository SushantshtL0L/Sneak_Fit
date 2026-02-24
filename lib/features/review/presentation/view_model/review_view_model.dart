import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/api/api_client.dart';
import 'package:sneak_fit/core/api/api_endpoints.dart';
import 'package:sneak_fit/features/review/domain/entities/review_entity.dart';

final reviewViewModelProvider = StateNotifierProvider<ReviewViewModel, ReviewState>((ref) {
  return ReviewViewModel(ref.read(apiClientProvider));
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

  ReviewViewModel(this._apiClient) : super(ReviewState());

  Future<void> fetchProductReviews(String productId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _apiClient.get(ApiEndpoints.productReviews(productId));
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        final reviews = data.map((json) => ReviewEntity.fromJson(json)).toList();
        state = state.copyWith(reviews: reviews, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: response.data['message']);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
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
