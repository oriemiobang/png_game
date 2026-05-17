import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class AppEnv {
	static const String _configuredBackendUrl = String.fromEnvironment('BACKEND_URL');

	static String get backendBaseUrl {
		if (_configuredBackendUrl.isNotEmpty) {
			return _configuredBackendUrl;
		}
		if (kIsWeb) {
			return 'http://127.0.0.1:3000';
		}
		if (Platform.isAndroid) {
			return 'http://10.0.2.2:3000';
		}
		return 'http://127.0.0.1:3000';
	}
}
