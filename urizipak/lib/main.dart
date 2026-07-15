import 'package:flutter/material.dart';

import 'app/di.dart';
import 'app/urizipak_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final services = await AppServices.create();
  runApp(UrizipakApp(services: services));
}
