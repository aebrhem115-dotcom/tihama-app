class ApiConfig {
  ApiConfig._();

  static const String appName = 'تهامة يمن';
  static const String appNameEn = 'Tihama Yemen';

  static String _baseUrl = 'http://10.0.2.2:8000/api';
  static String get baseUrl => _baseUrl;

  static void setBaseUrl(String url) {
    _baseUrl = url;
  }

  static const Duration timeout = Duration(seconds: 30);

  static const String storageTokenKey = 'auth_token';
  static const String storageRefreshKey = 'refresh_token';
  static const String storageUserKey = 'user_data';
  static const String storageThemeKey = 'theme_mode';
  static const String storageLangKey = 'language';
  static const String storageBaseurlKey = 'base_url';

  static const List<Map<String, String>> defaultProviders = [
    {'label': 'الخادم المحلي', 'value': 'http://10.0.2.2:8000/api'},
    {'label': 'الإنتاج', 'value': 'https://api.tihama.ye/api'},
  ];
}