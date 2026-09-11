import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../models/models.dart';

class ApiService {
  late final Dio _dio;
  final _storage = const FlutterSecureStorage();
  String? _token;
  String? _refreshToken;
  User? _user;

  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  ApiService._internal() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.timeout,
      receiveTimeout: ApiConfig.timeout,
      headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) options.headers['Authorization'] = 'Bearer $_token';
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401 && _refreshToken != null) {
          try {
            await _refreshAccessToken();
            handler.resolve(await _dio.fetch(error.requestOptions));
            return;
          } catch (_) {
            await logout();
          }
        }
        handler.next(error);
      },
    ));
  }

  void setBaseUrl(String url) {
    _dio.options.baseUrl = url;
  }

  String? get token => _token;
  bool get isLoggedIn => _token != null;
  User? get currentUser => _user;

  Future<void> init() async {
    _token = await _storage.read(key: ApiConfig.storageTokenKey);
    _refreshToken = await _storage.read(key: ApiConfig.storageRefreshKey);
    final savedUrl = await _storage.read(key: ApiConfig.storageBaseurlKey);
    if (savedUrl != null) _dio.options.baseUrl = savedUrl;
  }

  Future<void> _saveTokens(String token, String? refresh) async {
    _token = token;
    _refreshToken = refresh;
    await _storage.write(key: ApiConfig.storageTokenKey, value: token);
    if (refresh != null) await _storage.write(key: ApiConfig.storageRefreshKey, value: refresh);
  }

  Future<void> _refreshAccessToken() async {
    final r = _d(await _dio.post('/auth/refresh-token', data: {'refresh_token': _refreshToken}));
    final d = _asMap(r['data']);
    await _saveTokens(d['access_token'], d['refresh_token'] ?? _refreshToken);
    if (d['user'] != null) _user = User.fromJson(_asMap(d['user']));
  }

  Future<void> logout() async {
    try { await _dio.post('/auth/logout', data: {'refresh_token': _refreshToken}); } catch (_) {}
    _token = null;
    _refreshToken = null;
    _user = null;
    await _storage.delete(key: ApiConfig.storageTokenKey);
    await _storage.delete(key: ApiConfig.storageRefreshKey);
  }

  Future<void> saveBaseUrl(String url) async {
    await _storage.write(key: ApiConfig.storageBaseurlKey, value: url);
    _dio.options.baseUrl = url;
  }

  Map<String, dynamic> _d(Response r) {
    final d = r.data;
    return d is Map ? Map<String, dynamic>.from(d) : <String, dynamic>{'data': d};
  }

  Map<String, dynamic> _asMap(dynamic v) => v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

  List _extractItems(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map) {
      return data['items'] ?? data['data'] ?? [];
    }
    return [];
  }

  // ---- Auth ----
  Future<Map<String, dynamic>> register({required String phone, required String name, required String password, int clientId = 1}) async {
    final r = _d(await _dio.post('/auth/register', data: {
      'client_id': clientId, 'name': name, 'phone': phone, 'password': password,
    }));
    final data = _asMap(r['data']);
    if (data['access_token'] != null) {
      await _saveTokens(data['access_token'], data['refresh_token']);
      if (data['user'] != null) _user = User.fromJson(_asMap(data['user']));
    }
    return data;
  }

  Future<Map<String, dynamic>> login({required String identifier, required String password}) async {
    final r = _d(await _dio.post('/auth/login', data: {'identifier': identifier, 'password': password}));
    final data = _asMap(r['data']);
    if (data['access_token'] != null) {
      await _saveTokens(data['access_token'], data['refresh_token']);
      if (data['user'] != null) _user = User.fromJson(_asMap(data['user']));
    }
    return data;
  }

  Future<void> sendOtp({required String identifier, String purpose = 'login'}) async {
    await _dio.post('/auth/otp/send', data: {'identifier': identifier, 'purpose': purpose});
  }

  Future<Map<String, dynamic>> forgotPassword({required String identifier}) async {
    final r = _d(await _dio.post('/auth/forgot-password', data: {'identifier': identifier, 'purpose': 'forgot'}));
    return _asMap(r['data']);
  }

  Future<bool> verifyOtp({required String identifier, required String code, String purpose = 'forgot'}) async {
    final r = _d(await _dio.post('/auth/otp/verify', data: {'identifier': identifier, 'code': code, 'purpose': purpose}));
    final data = _asMap(r['data']);
    if (data['access_token'] != null) {
      await _saveTokens(data['access_token'], data['refresh_token']);
      if (data['user'] != null) _user = User.fromJson(_asMap(data['user']));
      return true;
    }
    return data['verified'] == true;
  }

  Future<void> resetPassword({required String identifier, required String code, required String password}) async {
    await _dio.post('/auth/reset-password', data: {
      'identifier': identifier, 'code': code, 'password': password, 'password_confirmation': password,
    });
  }

  // ---- Profile ----
  Future<User> getProfile() async {
    final r = _d(await _dio.get('/user/profile'));
    final data = _asMap(r['data']);
    _user = User.fromJson(data);
    return _user!;
  }

  Future<User> updateProfile({String? name, String? email, String? lang}) async {
    final r = _d(await _dio.put('/user/profile', data: {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (lang != null) 'lang': lang,
    }));
    final data = _asMap(r['data']);
    _user = User.fromJson(data);
    return _user!;
  }

  // ---- Wallet ----
  Future<Wallet> getBalance() async {
    final r = _d(await _dio.get('/wallet/balance'));
    return Wallet.fromJson(_asMap(r['data']));
  }

  Future<List<TransactionModel>> getTransactions({int page = 1}) async {
    final r = _d(await _dio.get('/wallet/transactions', queryParameters: {'page': page}));
    final items = _extractItems(r);
    return items.map((e) => TransactionModel.fromJson(_asMap(e))).toList();
  }

  // ---- Catalog ----
  Future<Map<String, dynamic>> getHomeData() async {
    final r = _d(await _dio.get('/home'));
    return _asMap(r['data']);
  }

  Future<List<Service>> getServices() async {
    final r = _d(await _dio.get('/services'));
    return _extractItems(r).map((e) => Service.fromJson(_asMap(e))).toList();
  }

  Future<List<Game>> getGames() async {
    final r = _d(await _dio.get('/games'));
    return _extractItems(r).map((e) => Game.fromJson(_asMap(e))).toList();
  }

  Future<List<Product>> getGameProducts(int gameId) async {
    final r = _d(await _dio.get('/games/$gameId/products'));
    return _extractItems(r).map((e) => Product.fromJson(_asMap(e))).toList();
  }

  Future<List<App>> getApps() async {
    final r = _d(await _dio.get('/apps'));
    return _extractItems(r).map((e) => App.fromJson(_asMap(e))).toList();
  }

  Future<List<CardModel>> getCards() async {
    final r = _d(await _dio.get('/cards'));
    return _extractItems(r).map((e) => CardModel.fromJson(_asMap(e))).toList();
  }

  // ---- Orders ----
  Future<Map<String, dynamic>> purchase({required int productId, List<Map<String, dynamic>>? fields}) async {
    final r = _d(await _dio.post('/orders', data: {
      'product_id': productId,
      'fields': fields ?? [],
    }));
    return _asMap(r['data']);
  }

  Future<List<Order>> getOrders({int page = 1}) async {
    final r = _d(await _dio.get('/orders', queryParameters: {'page': page}));
    return _extractItems(r).map((e) => Order.fromJson(_asMap(e))).toList();
  }

  Future<Order> getOrder(String uuid) async {
    final r = _d(await _dio.get('/orders/$uuid'));
    return Order.fromJson(_asMap(r['data']));
  }

  // ---- Notifications ----
  Future<List<NotificationModel>> getNotifications({int page = 1}) async {
    final r = _d(await _dio.get('/notifications', queryParameters: {'page': page}));
    return _extractItems(r).map((e) => NotificationModel.fromJson(_asMap(e))).toList();
  }

  Future<int> getUnreadCount() async {
    final r = _d(await _dio.get('/notifications/unread-count'));
    final data = _asMap(r['data']);
    return (data['unread_count'] as num?)?.toInt() ?? 0;
  }

  Future<void> markNotificationRead(int id) async {
    await _dio.post('/notifications/read', data: {'notification_id': id});
  }

  Future<void> markAllNotificationsRead() async {
    await _dio.post('/notifications/read-all');
  }

  // ---- Support ----
  Future<List<SupportTicket>> getTickets() async {
    final r = _d(await _dio.get('/support/tickets'));
    return _extractItems(r).map((e) => SupportTicket.fromJson(_asMap(e))).toList();
  }

  Future<SupportTicket> createTicket({required String subject, required String message, String priority = 'normal'}) async {
    final r = _d(await _dio.post('/support/tickets', data: {'subject': subject, 'message': message, 'priority': priority}));
    return SupportTicket.fromJson(_asMap(r['data']));
  }

  Future<List<SupportMessage>> getTicketMessages(int ticketId) async {
    final r = _d(await _dio.get('/support/tickets/$ticketId/messages'));
    final data = _asMap(r['data']);
    final items = data['items'];
    return (items as List? ?? []).map((e) => SupportMessage.fromJson(_asMap(e))).toList();
  }

  Future<void> sendTicketMessage({required int ticketId, required String message}) async {
    await _dio.post('/support/tickets/$ticketId/reply', data: {'body': message});
  }
}