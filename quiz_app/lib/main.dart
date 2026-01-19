import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:quiz_app/providers/auth_provider.dart';
import 'package:quiz_app/providers/locale_provider.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  HttpOverrides.global = MyHttpOverrides();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      title: 'Queez',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: supportedLanguages.map((lang) => Locale(lang.code)),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const AppEntryPoint(),
    );
  }
}

class AppEntryPoint extends ConsumerWidget {
  const AppEntryPoint({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appAuthProvider);

    return appState.when(
      data: (state) {
        if (state.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Navigate after build is complete
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            final routeToNavigate =
                state.lastRoute == '/' ? '/login' : state.lastRoute;
            customNavigateReplacement(
              context,
              routeToNavigate,
              AnimationType.fade,
            );
          }
        });

        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
      loading:
          () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
      error:
          (error, stack) =>
              Scaffold(body: Center(child: Text('Error: $error'))),
    );
  }
}
