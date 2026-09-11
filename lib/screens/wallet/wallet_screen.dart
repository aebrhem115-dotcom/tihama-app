import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});
  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final _api = ApiService();
  bool _loading = true;
  Wallet? _wallet;
  List<TransactionModel> _transactions = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (!_api.isLoggedIn) { setState(() => _loading = false); return; }
    try {
      final w = await _api.getBalance();
      final t = await _api.getTransactions();
      setState(() { _wallet = w; _transactions = t; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('المحفظة')),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : !_api.isLoggedIn
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.account_balance_wallet_outlined, size: 64, color: AppTheme.textSecondary),
                  const SizedBox(height: 16),
                  const Text('سجّل دخولك لعرض المحفظة', style: TextStyle(color: AppTheme.textSecondary)),
                ],
              ),
            )
          : RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [AppTheme.primary, AppTheme.primaryDark]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('الرصيد الحالي', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      const SizedBox(height: 8),
                      Text(
                        '${_wallet?.balance ?? 0} ${_wallet?.currency ?? "YER"}',
                        style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      const Text('المحفظة نشطة',
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text('آخر المعاملات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                if (_transactions.isEmpty)
                  const Center(child: Padding(padding: EdgeInsets.all(32), child: Text('لا توجد معاملات بعد')))
                else
                  ..._transactions.map((t) => _transactionTile(t)),
              ],
            ),
          ),
    );
  }

  Widget _transactionTile(TransactionModel t) {
    final isCredit = t.isCredit;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: (isCredit ? AppTheme.success : AppTheme.danger).withAlpha(25),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: isCredit ? AppTheme.success : AppTheme.danger,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.description ?? t.type, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(t.createdAt, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'} ${t.amount}',
            style: TextStyle(fontWeight: FontWeight.bold, color: isCredit ? AppTheme.success : AppTheme.danger),
          ),
        ],
      ),
    );
  }
}