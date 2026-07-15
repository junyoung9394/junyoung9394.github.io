import 'package:flutter/material.dart';

import '../features/shell/home_shell.dart';
import 'di.dart';

class UrizipakApp extends StatelessWidget {
  const UrizipakApp({super.key, required this.services});

  final AppServices services;

  @override
  Widget build(BuildContext context) {
    return AppServicesScope(
      services: services,
      child: ListenableBuilder(
        listenable: services.theme,
        builder: (context, _) {
          return MaterialApp(
            title: '우리지갑',
            debugShowCheckedModeBanner: false,
            theme: services.theme.themeData,
            home: const HomeShell(),
          );
        },
      ),
    );
  }
}
