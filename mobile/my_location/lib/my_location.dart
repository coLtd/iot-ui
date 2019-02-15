import 'dart:async';

import 'package:flutter/services.dart';

class MyLocation {
  static const MethodChannel _channel =
      const MethodChannel('my_location');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<Map<dynamic, dynamic>> get location async {
    final Map<dynamic, dynamic> str = await _channel.invokeMethod('getLocation');
    return str;
  }
}
