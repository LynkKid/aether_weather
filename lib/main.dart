import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aether_weather/core/constants/app_constants.dart';
import 'package:aether_weather/core/services/notification_service.dart';
import 'package:aether_weather/core/theme/app_theme.dart';
import 'package:aether_weather/features/weather/presentation/providers/radar_provider.dart';
import 'package:aether_weather/features/weather/presentation/providers/weather_provider.dart';
import 'package:aether_weather/features/weather/presentation/screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => RadarProvider()),
      ],
      child: const AetherWeatherApp(),
    ),
  );
}

class AetherWeatherApp extends StatelessWidget {
  const AetherWeatherApp({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      themeMode: weatherProvider.materialThemeMode,
      theme: AppTheme.lightTheme,
      darkTheme: weatherProvider.activeThemeData,
      home: const MainNavigationScreen(),
    );
  }
}
