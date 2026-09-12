import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../product/product_detail_screen.dart';
import '../support/support_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _api = ApiService();
  bool _loading = true;
  String? _error;
  List<Service> _services = [];
  List<Game> _games = [];
  List<App> _apps = [];
  List<CardModel> _cards = [];
  List<BannerModel> _banners = [];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await _api.getHomeData();
      setState(() {
        _services = (res['services'] as List?)?.map((e) => Service.fromJson(e)).toList() ?? [];
        _games = (res['games'] as List?)?.map((e) => Game.fromJson(e)).toList() ?? [];
        _apps = (res['apps'] as List?)?.map((e) => App.fromJson(e)).toList() ?? [];
        _cards = (res['cards'] as List?)?.map((e) => CardModel.fromJson(e)).toList() ?? [];
        _banners = (res['banners'] as List?)?.map((e) => BannerModel.fromJson(e)).toList() ?? [];
        _loading = false;
      });
    } catch (e) {
      setState(() { _loading = false; _error = 'تعذر الاتصال بالخادم — تأكد من أن الهاتف والكمبيوتر على نفس الشبكة'; });
    }
  }

  Future<void> _openGameProducts(Game game) async {
    try {
      final products = await _api.getGameProducts(game.id);
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => ProductDetailScreen(title: game.nameAr, products: products, type: 'game'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر تحميل المنتجات')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('تهامة يمن', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
            icon: const Icon(Icons.notifications_outlined),
          ),
          IconButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen())),
            icon: const Icon(Icons.headset_mic_outlined),
          ),
        ],
      ),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null && _services.isEmpty && _games.isEmpty
          ? _errorView()
          : RefreshIndicator(
          onRefresh: _load,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_banners.isNotEmpty) ...[
                SizedBox(
                  height: 160,
                  child: PageView.builder(
                    itemCount: _banners.length,
                    itemBuilder: (ctx, i) => Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withAlpha(25),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: _banners[i].imageUrl != null
                        ? ClipRRect(borderRadius: BorderRadius.circular(16), child: CachedNetworkImage(imageUrl: _banners[i].imageUrl!, fit: BoxFit.cover))
                        : Center(child: Text(_banners[i].title ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],

              _sectionTitle('الخدمات', Icons.grid_view),
              const SizedBox(height: 8),
              if (_services.isEmpty)
                const Padding(padding: EdgeInsets.all(8), child: Text('لا توجد خدمات حالياً'))
              else
                Wrap(
                  spacing: 12, runSpacing: 12,
                  children: _services.map((s) => _serviceChip(s)).toList(),
                ),

              const SizedBox(height: 24),
              _sectionTitle('الألعاب', Icons.sports_esports),
              const SizedBox(height: 8),
              if (_games.isNotEmpty)
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _games.length,
                    itemBuilder: (ctx, i) => _gameCard(_games[i]),
                  ),
                ),

              if (_apps.isNotEmpty) ...[
                const SizedBox(height: 24),
                _sectionTitle('التطبيقات', Icons.phone_android),
                const SizedBox(height: 8),
                SizedBox(
                  height: 110,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _apps.length,
                    itemBuilder: (ctx, i) => _appCard(_apps[i]),
                  ),
                ),
              ],

              if (_cards.isNotEmpty) ...[
                const SizedBox(height: 24),
                _sectionTitle('البطاقات', Icons.credit_card),
                const SizedBox(height: 8),
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _cards.length,
                    itemBuilder: (ctx, i) => _cardItem(_cards[i]),
                  ),
                ),
              ],

              const SizedBox(height: 32),
            ],
          ),
        ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_outlined, size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            const Text('تعذر الاتصال بالخادم', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('تأكد أن الهاتف والكمبيوتر متصلان بنفس شبكة الواي فاي', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textSecondary)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _load,
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: AppTheme.primary),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
      ],
    );
  }

  Widget _serviceChip(Service s) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Text(s.nameAr, style: const TextStyle(fontWeight: FontWeight.w500)),
      ),
    );
  }

  Widget _gameCard(Game g) {
    return GestureDetector(
      onTap: () => _openGameProducts(g),
      child: Container(
        width: 140, margin: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: AppTheme.primary.withAlpha(25), borderRadius: BorderRadius.circular(12)),
              child: g.logoUrl != null
                ? CachedNetworkImage(imageUrl: g.logoUrl!, fit: BoxFit.cover)
                : const Icon(Icons.sports_esports, color: AppTheme.primary),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(g.nameAr, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _appCard(App a) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        width: 140, margin: const EdgeInsets.only(left: 12),
        decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: AppTheme.secondary.withAlpha(25), borderRadius: BorderRadius.circular(12)),
              child: a.logoUrl != null
                ? CachedNetworkImage(imageUrl: a.logoUrl!, fit: BoxFit.cover)
                : const Icon(Icons.phone_android, color: AppTheme.secondary),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(a.nameAr, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardItem(CardModel c) {
    return Container(
      width: 160, margin: const EdgeInsets.only(left: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.credit_card, color: AppTheme.warning, size: 28),
          const SizedBox(height: 8),
          Text(c.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }
}