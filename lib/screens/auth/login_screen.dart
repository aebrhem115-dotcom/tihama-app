import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../home/home_shell.dart';
import 'otp_verify_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirm = TextEditingController();
  final _name = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _isRegister = false;
  String? _error;

  final _api = ApiService();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      if (_isRegister) {
        await _api.register(
          phone: _phone.text.trim(),
          name: _name.text.trim(),
          password: _password.text,
        );
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeShell()), (_) => false);
      } else {
        final res = await _api.login(identifier: _phone.text.trim(), password: _password.text);
        if (res['access_token'] != null) {
          if (!mounted) return;
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeShell()), (_) => false);
        }
      }
    } catch (e) {
      setState(() { _error = _parseError(e); });
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  Future<void> _forgotPassword() async {
    if (_phone.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل رقم الهاتف أولًا')));
      return;
    }
    try {
      await _api.forgotPassword(identifier: _phone.text.trim());
      if (!mounted) return;
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => OtpVerifyScreen(identifier: _phone.text.trim(), purpose: 'forgot'),
      ));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_parseError(e))));
    }
  }

  String _parseError(dynamic e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) return data['message'];
      if (e.response?.statusCode == 422) return 'بيانات غير صحيحة — تأكد من الحقول المطلوبة';
      if (e.response?.statusCode == 401) return 'رقم الهاتف أو كلمة المرور غير صحيحة';
      if (e.response?.statusCode == 403) return 'الحساب معطّل — تواصل مع الدعم الفني';
    }
    return 'حدث خطأ — تحقق من الاتصال بالخادم';
  }

  @override
  void dispose() { _phone.dispose(); _password.dispose(); _passwordConfirm.dispose(); _name.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(20)),
                  child: const Icon(Icons.account_balance_wallet, size: 44, color: Colors.white),
                ),
                const SizedBox(height: 24),
                Text(
                  _isRegister ? 'إنشاء حساب جديد' : 'تسجيل الدخول',
                  style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 8),
                const Text('تهامة يمن — منصتك المالية الذكية', style: TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 32),

                if (_isRegister)
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'الاسم الكامل', prefixIcon: Icon(Icons.person_outline)),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'الاسم مطلوب' : null,
                    textInputAction: TextInputAction.next,
                  ),
                if (_isRegister) const SizedBox(height: 16),

                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'رقم الهاتف', prefixIcon: Icon(Icons.phone_outlined)),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'أدخل رقم الهاتف' : null,
                  inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+\\-]'))],
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'كلمة المرور', prefixIcon: Icon(Icons.lock_outline)),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'أدخل كلمة المرور';
                    if (_isRegister && v.length < 8) return '8 أحرف على الأقل';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                if (_isRegister)
                  TextFormField(
                    controller: _passwordConfirm,
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور', prefixIcon: Icon(Icons.lock_outline)),
                    validator: (v) {
                      if (_isRegister && v != _password.text) return 'كلمتا المرور غير متطابقتين';
                      return null;
                    },
                  ),
                if (_isRegister) const SizedBox(height: 8),

                if (!_isRegister)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: const Text('نسيت كلمة المرور؟'),
                    ),
                  ),

                const SizedBox(height: 16),

                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: AppTheme.danger.withAlpha(25), borderRadius: BorderRadius.circular(12)),
                    child: Text(_error!, style: const TextStyle(color: AppTheme.danger)),
                  ),

                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_isRegister ? 'إنشاء حساب' : 'دخول'),
                ),
                const SizedBox(height: 16),

                TextButton(
                  onPressed: () => setState(() { _isRegister = !_isRegister; _error = null; }),
                  child: Text(_isRegister ? 'لديك حساب؟ سجّل دخول' : 'ليس لديك حساب؟ أنشئ حسابًا جديدًا'),
                ),

                const SizedBox(height: 24),
                Center(
                  child: TextButton.icon(
                    onPressed: () => Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeShell()), (_) => false),
                    icon: const Icon(Icons.explore_outlined, size: 18),
                    label: const Text('تصفح كضيف'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}