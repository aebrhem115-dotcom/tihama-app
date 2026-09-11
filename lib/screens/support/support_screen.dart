import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});
  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _api = ApiService();
  bool _loading = true;
  List<SupportTicket> _tickets = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (!_api.isLoggedIn) { setState(() => _loading = false); return; }
    try {
      final t = await _api.getTickets();
      setState(() { _tickets = t; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  void _newTicket() {
    final subject = TextEditingController();
    final message = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تذكرة دعم جديدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: subject, decoration: const InputDecoration(labelText: 'الموضوع')),
            const SizedBox(height: 12),
            TextField(controller: message, maxLines: 3, decoration: const InputDecoration(labelText: 'الرسالة')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          ElevatedButton(
            onPressed: () async {
              if (subject.text.isEmpty || message.text.isEmpty) return;
              try {
                await _api.createTicket(subject: subject.text, message: message.text);
                Navigator.pop(ctx);
                _load();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('فشل إنشاء التذكرة')));
              }
            },
            child: const Text('إرسال'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الدعم الفني'), actions: [
        if (_api.isLoggedIn)
          IconButton(onPressed: _newTicket, icon: const Icon(Icons.add)),
      ]),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : !_api.isLoggedIn
          ? const Center(child: Text('سجّل دخولك لعرض التذاكر'))
          : _tickets.isEmpty
            ? const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('لا توجد تذاكر بعد')))
            : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tickets.length,
              itemBuilder: (ctx, i) => _ticketCard(_tickets[i]),
            ),
    );
  }

  Widget _ticketCard(SupportTicket t) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(t.subject, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1, overflow: TextOverflow.ellipsis)),
              _statusBadge(t.status),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t.priorityLabel, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              Text(t.createdAt ?? '', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final color = switch (status) { 'open' => AppTheme.success, 'closed' => AppTheme.textSecondary, _ => AppTheme.warning };
    final label = switch (status) { 'open' => 'مفتوحة', 'closed' => 'مغلقة', _ => status };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}