import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../../models/models.dart';
import '../auth/login_screen.dart';
import '../support/support_screen.dart';
import '../notifications/notifications_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _api = ApiService();
  User? _user;
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    if (!_api.isLoggedIn) { setState(() => _loading = false); return; }
    try {
      final u = await _api.getProfile();
      setState(() { _user = u; _loading = false; });
    } catch (_) { setState(() => _loading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('حسابي')),
      body: _loading
        ? const Center(child: CircularProgressIndicator())
        : !_api.isLoggedIn
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_outline, size: 64, color: AppTheme.textSecondary),
                  const SizedBox(height: 16),
                  const Text('سجّل دخولك لإدارة حسابك', style: TextStyle(color: AppTheme.textSecondary)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: const Text('تسجيل الدخول'),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 36, backgroundColor: AppTheme.primary.withAlpha(25),
                        child: Text(
                          (_user?.name ?? _user?.phone ?? '?').substring(0, 1),
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primary),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(_user?.name ?? 'بدون اسم', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(_user?.phone ?? '', style: const TextStyle(color: AppTheme.textSecondary)),
                      if (_user?.email != null) Text(_user!.email!, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _menuTile(Icons.notifications_outlined, 'الإشعارات', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
                }),
                _menuTile(Icons.headset_mic_outlined, 'الدعم الفني', () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportScreen()));
                }),
                _menuTile(Icons.lock_outline, 'تغيير كلمة المرور', () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('قريباً')));
                }),
                _menuTile(Icons.language, 'اللغة', () {}),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () async {
                    await _api.logout();
                    if (!context.mounted) return;
                    Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (_) => false);
                  },
                  icon: const Icon(Icons.logout, color: AppTheme.danger),
                  label: const Text('تسجيل الخروج', style: TextStyle(color: AppTheme.danger)),
                  style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.danger)),
                ),
              ],
            ),
    );
  }

  Widget _menuTile(IconData icon, String label, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.textPrimary),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        tileColor: Colors.white,
        onTap: onTap,
      ),
    );
  }
}