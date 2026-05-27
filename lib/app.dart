import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/router.dart';
import 'config/theme.dart';
import 'core/providers/app_provider.dart';
import 'features/auth/providers/auth_provider.dart';
import 'features/friends/providers/friends_provider.dart';
import 'features/messages/providers/messages_provider.dart';
import 'features/settings/providers/settings_provider.dart';

class LionMessengerApp extends StatelessWidget {
  const LionMessengerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FriendsProvider()),
        ChangeNotifierProvider(create: (_) => MessagesProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: Consumer<AppProvider>(
        builder: (context, appProvider, _) => MaterialApp.router(
          title: 'LionMessenger',
          debugShowCheckedModeBanner: false,
          theme: LionTheme.light,
          darkTheme: LionTheme.dark,
          themeMode: appProvider.themeMode,
          routerConfig: appRouter,
        ),
      ),
    );
  }
}
