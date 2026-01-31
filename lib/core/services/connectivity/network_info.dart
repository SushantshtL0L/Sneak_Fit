import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract interface class INetworkInfo {
  Future<bool> get isConnected;
}

final networkInfoProvider = Provider<NetworkInfo>((ref) {
  return NetworkInfo(Connectivity());
});

class NetworkInfo implements INetworkInfo {
  final Connectivity _connnectivity;

  NetworkInfo(this._connnectivity);
  @override
  // todo implementation needed
  
  Future<bool> get isConnected async {
    //
    final result = await _connnectivity.checkConnectivity();

    /// wifi / moble connected orr not
    if (result.contains(ConnectivityResult.none)) {
      return false;
    }

    return await _isthereInternetOrNot();
    //return true; // use this for testiing locally
  }

  Future<bool> _isthereInternetOrNot() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }
}