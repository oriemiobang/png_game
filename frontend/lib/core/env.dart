class AppEnv {
	static const String _configuredBackendUrl = String.fromEnvironment('BACKEND_URL');

	static String get backendBaseUrl {
		if (_configuredBackendUrl.isNotEmpty) {
			return _configuredBackendUrl;
		}
		
		// Use the host machine's local IP address and correct backend port (3002)
		// This ensures physical devices, emulators, and Chrome can all reach the local backend.
		// If your IP address changes, update this value or use --dart-define=BACKEND_URL=http://<YOUR_IP>:3002
		const String hostIp = '10.187.113.68';
		const String port = '3002';
		
		return 'http://$hostIp:$port';
	}
}
