import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/supabase_config.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();

  runApp(const ProviderScope(child: CrmApp()));
}

class CrmApp extends ConsumerWidget {
  const CrmApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'CRM',
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
