import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sneak_fit/core/api/api_client.dart';
import 'package:sneak_fit/core/api/api_endpoints.dart';
import 'package:sneak_fit/features/item/data/models/item_api_model.dart';

final itemRemoteDataSourceProvider = Provider<ItemRemoteDataSource>((ref) {
  return ItemRemoteDataSource(ref.read(apiClientProvider));
});

class ItemRemoteDataSource {
  final ApiClient _apiClient;

  ItemRemoteDataSource(this._apiClient);

  Future<List<ItemApiModel>> getAllItems() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.products);
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => ItemApiModel.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load products");
      }
    } catch (e) {
      throw Exception("Error fetching products: $e");
    }
  }

  Future<bool> createProduct(
    String name,
    String description,
    String condition,
    String imagePath,
    double price,
    String brand,
    String? size,
    String? color,
  ) async {
    try {
      final formData = FormData.fromMap({
        'name': name,
        'description': description,
        'condition': condition.toLowerCase(),
        'price': price.toString(),
        'brand': brand,
        'size': size,
        'color': color,
        'image': await MultipartFile.fromFile(
          imagePath,
          filename: imagePath.split('/').last,
        ),
      });

      final response = await _apiClient.uploadFile(
        ApiEndpoints.products,
        formData: formData,
      );

      return response.statusCode == 201;
    } catch (e) {
      throw Exception("Error creating product: $e");
    }
  }

  Future<ItemApiModel?> getItemById(String id) async {
    try {
      final response = await _apiClient.get("${ApiEndpoints.products}/$id");
      if (response.statusCode == 200) {
        return ItemApiModel.fromJson(response.data);
      }
      return null;
    } catch (e) {
      throw Exception("Error fetching product by ID: $e");
    }
  }

  Future<bool> deleteProduct(String id) async {
    try {
      final response = await _apiClient.delete("${ApiEndpoints.products}/$id");
      return response.statusCode == 200;
    } catch (e) {
      throw Exception("Error deleting product: $e");
    }
  }
}
