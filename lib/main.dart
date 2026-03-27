import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'firebase_options.dart';
import 'core/providers/auth_provider.dart';
import 'core/providers/cart_provider.dart';
import 'core/providers/product_provider.dart';
import 'core/services/firestore_service.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/models/user_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:          Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  runApp(const RetailHubApp());
}

class RetailHubApp extends StatelessWidget {
  const RetailHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        Provider(create: (_) => FirestoreService()),
        ChangeNotifierProxyProvider<FirestoreService, ProductProvider>(
          create:  (ctx) => ProductProvider(ctx.read<FirestoreService>()),
          update:  (ctx, svc, prev) => prev ?? ProductProvider(svc),
        ),
      ],
      child: const _AppContent(),
    );
  }
}

class _AppContent extends StatefulWidget {
  const _AppContent();

  @override
  State<_AppContent> createState() => _AppContentState();
}

class _AppContentState extends State<_AppContent> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _router = createRouter(auth);

    AuthStatus _prevStatus = auth.status;
    auth.addListener(() {
      final current = auth.status;
      if (current == AuthStatus.authenticated &&
          _prevStatus != AuthStatus.authenticated) {
        context.read<ProductProvider>().resubscribe();
      }
      _prevStatus = current;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth    = context.watch<AuthProvider>();
    final isAdmin = auth.appUser?.role == UserRole.admin;
    final theme   = isAdmin ? AppTheme.adminTheme() : AppTheme.consumerTheme();

    return MaterialApp.router(
      title:                      'Retail Hub',
      debugShowCheckedModeBanner: false,
      theme:                      theme,
      routerConfig:               _router,
    );
  }
}