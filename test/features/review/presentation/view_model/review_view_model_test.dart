import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:sneak_fit/core/api/api_client.dart';
import 'package:sneak_fit/core/services/hive/hive_service.dart';
import 'package:sneak_fit/features/review/presentation/view_model/review_view_model.dart';
import 'package:sneak_fit/features/review/domain/entities/review_entity.dart';

class MockApiClient extends Mock implements ApiClient {}
class MockHiveService extends Mock implements HiveService {}

void main() {
  late ReviewViewModel viewModel;
  late MockApiClient mockApiClient;
  late MockHiveService mockHiveService;

  setUp(() {
    mockApiClient = MockApiClient();
    mockHiveService = MockHiveService();
    
    // Default mocks
    when(() => mockHiveService.getReviews(any())).thenAnswer((_) async => null);
    
    viewModel = ReviewViewModel(mockApiClient, mockHiveService);
  });

  group('ReviewViewModel', () {
    const tProductId = 'p1';
    final tReview = ReviewEntity(
      id: 'r1',
      productId: tProductId,
      userId: 'u1',
      userName: 'Tester',
      rating: 5,
      comment: 'Great shoe!',
      createdAt: DateTime.now(),
    );

    test('initial state should be empty', () {
      expect(viewModel.state.reviews, isEmpty);
      expect(viewModel.state.isLoading, isFalse);
    });

    test('fetchProductReviews should update state with reviews from API on success', () async {
      // Arrange
      final responseData = {
        'success': true,
        'data': [
          {
            '_id': 'r1',
            'product': tProductId,
            'user': {'_id': 'u1', 'name': 'Tester'},
            'rating': 5,
            'comment': 'Best buy ever!',
            'createdAt': DateTime.now().toIso8601String(),
          }
        ]
      };
      
      when(() => mockApiClient.get(any())).thenAnswer(
        (_) async => Response(
          data: responseData,
          requestOptions: RequestOptions(path: ''),
        ),
      );
      when(() => mockHiveService.saveReviews(any(), any())).thenAnswer((_) async => {});

      // Act
      await viewModel.fetchProductReviews(tProductId);

      // Assert
      expect(viewModel.state.reviews.length, 1);
      expect(viewModel.state.reviews[0].id, 'r1');
      expect(viewModel.state.isLoading, isFalse);
      verify(() => mockHiveService.saveReviews(any(), any())).called(1);
    });

    test('postReview should return true on success', () async {
      // Arrange
      when(() => mockApiClient.post(any(), data: any(named: 'data'))).thenAnswer(
        (_) async => Response(
          data: {'success': true},
          requestOptions: RequestOptions(path: ''),
        ),
      );
      // Mock the subsequent fetch
      when(() => mockApiClient.get(any())).thenAnswer(
        (_) async => Response(
          data: {'success': true, 'data': []},
          requestOptions: RequestOptions(path: ''),
        ),
      );

      // Act
      final result = await viewModel.postReview(tReview);

      // Assert
      expect(result, isTrue);
      expect(viewModel.state.isSubmitting, isFalse);
    });
  });
}
