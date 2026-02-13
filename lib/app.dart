import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'config/theme.dart';
import 'config/router.dart';
import 'presentation/providers/theme_provider.dart';

class MeldenApp extends ConsumerWidget {
  const MeldenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Melden',
      theme: MeldenTheme.light(),
      darkTheme: MeldenTheme.dark(),
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
