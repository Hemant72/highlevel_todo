import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:highlevel_todo/core/di/dependency_injection.dart';
import 'package:highlevel_todo/core/service/notification_service.dart';
import 'package:highlevel_todo/core/theme/app_theme.dart';
import 'package:highlevel_todo/src/presentation/pages/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureDependencies();
  await GetIt.I.allReady();
  final notificationService = GetIt.I<NotificationService>();
  await notificationService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HighLevel Todo',
      theme: AppTheme.light(),
      home: HomePage(),
    );
  }
}
