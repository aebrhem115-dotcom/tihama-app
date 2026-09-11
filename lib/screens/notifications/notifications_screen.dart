import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _api = ApiService();
  bool _loading = true;
  List<NotificationModel> _notifications = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (!_api.isLoggedIn) { setState(() => _loading = false); return; }
    try {
      final n = await _api.getNotifications();
      setState(() { _notifications = n; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          if (_notifications.any((n) => !n.read))
            TextButton(
              onPressed: () async {
                await _api.markAllNotificationsRead();
                _load();
              },
              child: const Text(' قراءة الكل', style: TextStyle(fontSize: 12)),
            ),
        ],
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : !_api.isLoggedIn
          ? const Center(child: Text('سجّل دخولك لعرض الإشعارات'))
          : _notifications.isEmpty
            ? const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('لا توجد إشعارات')))
            : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notifications.length,
              itemBuilder: (ctx, i) => _notifTile(_notifications[i]),
            ),
    );
  }

  Widget _notifTile(NotificationModel n) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: n.read ? Colors.white : AppTheme.primary.withAlpha(8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: n.read ? AppTheme.border : AppTheme.primary.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (!n.read) Container(
                width: 8, height: 8,
                decoration: const BoxDecoration(color: AppTheme.primary, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(child: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w600))),
              Text(n.createdAt ?? '', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ],
          ),
          if (n.body != null) ...[
            const SizedBox(height: 8),
            Text(n.body!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ],
        ],
      ),
    );
  }
}