import 'package:flutter/foundation.dart';
import 'fcm_service.dart';
import 'fcm_service_mobile.dart';
import 'fcm_service_web.dart';

class FCMServiceFactory {
  static FCMService create() {
    if (kIsWeb) {
      return FCMServiceWeb.instance;
    } else {
      return FCMServiceMobile.instance;
    }
  }
}
