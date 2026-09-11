import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';

class ProductDetailScreen extends StatefulWidget {
  final String title;
  final List<Product> products;
  final String type;
  const ProductDetailScreen({super.key, required this.title, required this.products, required this.type});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _selected;
  bool _purchasing = false;
  final Map<String, TextEditingController> _fieldControllers = {};

  @override
  void dispose() { for (final c in _fieldControllers.values) c.dispose(); super.dispose(); }

  void _onProductSelected(Product p) {
    setState(() {
      _selected = p;
      for (final f in _fieldControllers.values) f.clear();
      _fieldControllers.clear();
      if (p.fields != null) {
        for (final f in p.fields!) {
          _fieldControllers[f.key] = TextEditingController();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('اختر المنتج', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ...widget.products.map((p) => _productTile(p)),

          if (_selected?.fields != null && _selected!.fields!.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text('بيانات الإدخال', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._selected!.fields!.map((f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: TextField(
                controller: _fieldControllers[f.key],
                decoration: InputDecoration(
                  labelText: f.labelAr ?? f.key,
                  hintText: f.placeholder,
                  prefixIcon: const Icon(Icons.edit_outlined),
                  suffixIcon: f.required ? null : const Text('(اختياري)', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                ),
              ),
            )),
          ],

          if (_selected != null) ...[
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primary.withAlpha(50)),
              ),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    const Text('السعر', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('${_selected!.unitPrice} ${_selected!.currency ?? "YER"}',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  ]),
                  if (_selected!.fee != null && _selected!.fee! > 0) ...[
                    const SizedBox(height: 4),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('العمولة', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                      Text('${_selected!.fee} ${_selected!.currency ?? "YER"}',
                        style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ]),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _purchasing ? null : _purchase,
              child: _purchasing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('شراء الآن'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _productTile(Product p) {
    final selected = _selected?.id == p.id;
    return GestureDetector(
      onTap: () => _onProductSelected(p),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.border, width: selected ? 2 : 1),
        ),
        child: Row(
          children: [
            Radio<int>(
              value: p.id, groupValue: _selected?.id,
              onChanged: (_) => _onProductSelected(p),
              activeColor: AppTheme.primary,
            ),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.nameAr, style: const TextStyle(fontWeight: FontWeight.w600)),
                if (p.game != null) Text(p.game!.nameAr, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ],
            )),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${p.unitPrice} ${p.currency ?? "YER"}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primary)),
                Text(p.productType ?? '', style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _purchase() async {
    final api = ApiService();
    if (!api.isLoggedIn) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سجّل دخولك أولاً')));
      return;
    }

    final fields = <Map<String, dynamic>>[];
    if (_selected?.fields != null) {
      for (final f in _selected!.fields!) {
        final val = _fieldControllers[f.key]?.text ?? '';
        fields.add({'key': f.key, 'value': val});
      }
    }

    setState(() => _purchasing = true);
    try {
      final res = await api.purchase(productId: _selected!.id, fields: fields);
      final orderData = res['order'];
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(res['success'] == true ? 'تم الشراء بنجاح' : 'فشلت العملية'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                res['success'] == true ? Icons.check_circle : Icons.error_outline,
                color: res['success'] == true ? AppTheme.success : AppTheme.danger,
                size: 64,
              ),
              const SizedBox(height: 16),
              if (orderData != null) Text('رقم الطلب: ${orderData['uuid']?.toString().substring(0, 8) ?? ''}'),
              Text(res['message'] ?? ''),
            ],
          ),
          actions: [TextButton(onPressed: () { Navigator.pop(ctx); if (res['success'] == true) Navigator.pop(ctx); }, child: const Text('تم'))],
        ),
      );
    } catch (e) {
      String msg = 'فشلت العملية';
      if (e is DioException && e.response?.data is Map) msg = e.response?.data['message'] ?? msg;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } finally {
      if (mounted) setState(() => _purchasing = false);
    }
  }
}