import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - Updated to match backend port (5050) and current IP (192.168.18.152)
  // static const String baseUrl = 'http://192.168.18.152:5050/api/';
  // static const String baseUrl = 'http://10.0.2.2:5050/api/'; // Android Emulator
  // static const String baseUrl = 'http://localhost:5050/api/'; // iOS Simulator
  static const bool isPhysicalDevice = false;

  static const String compIpAddress = "192.168.18.152";
  static String get baseUrl {
    if (isPhysicalDevice) {
      return 'http://$compIpAddress:5050/api/';
    }

    //yad android emulator
    if (kIsWeb) {
      return 'http://$compIpAddress:5050/api/';
    } else if(Platform.isAndroid) {
      return 'http://10.0.2.2:5050/api/';
    } else if (Platform.isIOS) {
      return 'http://localhost:5050/api/';
    } else {
      return 'http://localhost:5050/api/';
    }
  }

  static String get baseImageUrl {
    final url = baseUrl.replaceAll('/api/', '');
    return url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // ============ Auth Endpoints ============
  static const String auth = 'auth';
  static const String userLogin = 'auth/login';
  static const String userRegister = 'auth/register';
  static const String forgotPassword = 'auth/forgot-password';
  static const String resetPassword = 'auth/reset-password';

  static const String users = 'users';
  static const String currentUser = 'users/me';
  static const String updateProfile = 'users/profile';
  static String userById(String id) => 'users/$id';
  static String userPhoto(String id) => 'users/$id/photo';

  // ============ Item Endpoints ============
  // static const String items = '/items';
  // static String itemById(String id) => '/items/$id';
  // static String itemClaim(String id) => '/items/$id/claim';

  // ============ Comment Endpoints ============
  // static const String comments = '/comments';
  // static String commentById(String id) => '/comments/$id';
  // static String commentsByItem(String itemId) => '/comments/item/$itemId';
  // static String commentLike(String id) => '/comments/$id/like';

  // ============ Product Endpoints ============
  static const String products = 'products';
}