import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_mobile/layers/presentation/app_root.dart';

void main() {
  runApp(const ProviderScope(child: AppRoot()));
}
