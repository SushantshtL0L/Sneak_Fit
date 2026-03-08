import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sneak_fit/core/api/api_client.dart';
import 'package:sneak_fit/features/order/presentation/view_model/orders_view_model.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late OrdersViewModel viewModel;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    viewModel = OrdersViewModel(mockApiClient);
  });

  group('OrdersViewModel', () {
    test('initial state should be empty and not loading', () {
      expect(viewModel.state.orders, isEmpty);
      expect(viewModel.state.isLoading, isFalse);
    });


  });
}
