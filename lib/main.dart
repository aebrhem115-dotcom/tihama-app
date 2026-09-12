import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await ApiService().init();
  } catch (_) {}
  runApp(const ProviderScope(child: TihamaApp()));
}