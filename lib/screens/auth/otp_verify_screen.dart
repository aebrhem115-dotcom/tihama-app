import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../config/theme.dart';
import '../../services/api_service.dart';
import '../home/home_shell.dart';

class OtpVerifyScreen extends StatefulWidget {
  final String identifier;
  final String purpose;
  const OtpVerifyScreen({super.key, required this.identifier, this.purpose = 'forgot'});
  @override
  State<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _passwordConfirm = TextEditingController();
  bool _loading = false;
  int _secondsLeft = 60;
  Timer? _timer;

  final _api = ApiService();

  @override
  void initState() { super.initState(); _startTimer(); }

  void _startTimer() {
    _secondsLeft = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsLeft <= 0) { t.cancel(); return; }
      if (mounted) setState(() => _secondsLeft--);
    });
  }

  Future<void> _resend() async {
    try {
      await _api.sendOtp(identifier: widget.identifier, purpose: widget.purpose);
      _startTimer();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم إعادة إرسال الكود')));
    } catch (_) {}
  }

  Future<void> _verify() async {
    if (_code.text.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أدخل الكود الكامل')));
      return;
    }
    setState(() { _loading = true; });
    try {
      if (widget.purpose == 'forgot') {
        if (_password.text.length < 8) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كلمة المرور 8 أحرف على الأقل')));
          setState(() { _loading = false; });
          return;
        }
        if (_password.text != _passwordConfirm.text) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('كلمتا المرور غير متطابقتين')));
          setState(() { _loading = false; });
          return;
        }
        await _api.resetPassword(
          identifier: widget.identifier,
          code: _code.text,
          password: _password.text,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم تغيير كلمة المرور بنجاح — سجّل دخولك')));
        Navigator.of(context).popUntil((r) => r.isFirst);
      } else {
        final ok = await _api.verifyOtp(
          identifier: widget.identifier,
          code: _code.text,
          purpose: widget.purpose,
        );
        if (ok && mounted) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const HomeShell()), (_) => false);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('الكود غير صحيح أو منتهي الصلاحية')));
    } finally {
      if (mounted) setState(() { _loading = false; });
    }
  }

  @override
  void dispose() { _timer?.cancel(); _code.dispose(); _password.dispose(); _passwordConfirm.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isReset = widget.purpose == 'forgot';
    return Scaffold(
      appBar: AppBar(title: Text(isReset ? 'إعادة تعيين كلمة المرور' : 'التحقق من الكود')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(isReset ? Icons.lock_reset : Icons.sms_outlined, size: 64, color: AppTheme.primary),
            const SizedBox(height: 24),
            Text(
              'تم إرسال كود التحقق إلى\n${widget.identifier}',
              textAlign: TextAlign.center, style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),

            TextField(
              controller: _code,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 28, letterSpacing: 8),
              maxLength: 6,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(counterText: '', hintText: '000000'),
            ),
            const SizedBox(height: 16),

            if (isReset) ...[
              TextField(
                controller: _password, obscureText: true,
                decoration: const InputDecoration(labelText: 'كلمة المرور الجديدة (8 أحرف على الأقل)', prefixIcon: Icon(Icons.lock_outline)),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passwordConfirm, obscureText: true,
                decoration: const InputDecoration(labelText: 'تأكيد كلمة المرور', prefixIcon: Icon(Icons.lock_outline)),
              ),
              const SizedBox(height: 16),
            ],

            ElevatedButton(
              onPressed: _loading ? null : _verify,
              child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('تحقق'),
            ),
            const SizedBox(height: 16),

            TextButton(
              onPressed: _secondsLeft > 0 ? null : _resend,
              child: Text(_secondsLeft > 0 ? 'إعادة الإرسال بعد $_secondsLeft ثانية' : 'إعادة إرسال الكود'),
            ),
          ],
        ),
      ),
    );
  }
}