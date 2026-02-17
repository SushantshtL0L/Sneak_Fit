// import 'dart:io';
// import 'package:sneak_fit/features/item/data/models/item_api_model.dart';
// import 'package:sneak_fit/features/item/data/models/item_hive_model.dart';

// /// Local data source contract
// abstract interface class IItemLocalDataSource {
//   Future<List<ItemHiveModel>> getAllItems();
//   Future<ItemHiveModel?> getItemById(String itemId);
//   Future<bool> createItem(ItemHiveModel item);
//   Future<bool> updateItem(ItemHiveModel item);
//   Future<bool> deleteItem(String itemId);
// }

// /// Remote data source contract
// abstract interface class IItemRemoteDataSource {
//   Future<String> uploadPhoto(File photo);
//   Future<String> uploadVideo(File video); // optional if you allow videos
//   Future<ItemApiModel> createItem(ItemApiModel item);
//   Future<List<ItemApiModel>> getAllItems();
//   Future<ItemApiModel> getItemById(String itemId);
//   Future<bool> updateItem(ItemApiModel item);
//   Future<bool> deleteItem(String itemId);
// }
