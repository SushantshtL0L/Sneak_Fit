import 'package:hive_flutter/hive_flutter.dart';
import '../constants/hive_constants.dart';

class HiveHelper {
  static Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox(HiveConstants.userBox);
  }

  static Box getUserBox() => Hive.box(HiveConstants.userBox);
}
