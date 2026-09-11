import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final _api = ApiService();
  bool _loading = true;
  List<Order> _orders = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (!_api.isLoggedIn) { setState(() => _loading = false); return; }
    try {
      final o = await _api.getOrders();
      setState(() { _orders = o; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('طلباتي')),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : !_api.isLoggedIn
          ? const Center(child: Text('سجّل دخولك لعرض الطلبات'))
          : RefreshIndicator(
            onRefresh: _load,
            child: _orders.isEmpty
              ? const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('لا توجد طلبات بعد')))
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _orders.length,
                itemBuilder: (ctx, i) => _orderCard(_orders[i]),
              ),
          ),
    );
  }

  Widget _orderCard(Order o) {
    final color = switch (o.status) {
      'success' => AppTheme.success,
      'failed' => AppTheme.danger,
      'pending' => AppTheme.warning,
      _ => AppTheme.textSecondary,
    };
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
              Text('#${o.uuid.substring(0, 8)}', style: const TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(8)),
                child: Text(o.statusLabel, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('المبلغ', style: TextStyle(color: AppTheme.textSecondary)),
              Text('${o.amount} YER', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Text(o.createdAt ?? '', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }
}