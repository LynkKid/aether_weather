import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aether_weather/core/theme/app_theme.dart';
import 'package:aether_weather/features/weather/presentation/providers/weather_provider.dart';
import 'package:aether_weather/features/weather/presentation/screens/alerts_tab.dart';
import 'package:aether_weather/features/weather/presentation/screens/cities_tab.dart';
import 'package:aether_weather/features/weather/presentation/screens/forecast_tab.dart';
import 'package:aether_weather/features/weather/presentation/screens/radar_tab.dart';
import 'package:aether_weather/features/weather/presentation/screens/settings_tab.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    final weather = weatherProvider.weather;
    final atmTheme = weatherProvider.atmosphericTheme;
    final alertsCount = weather?.severeAlerts.length ?? 0;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: atmTheme.bgGradient,
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Custom Meteorological App Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                weather?.city.name ?? 'Aether Weather',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: atmTheme.textColor,
                                ),
                              ),
                              if (weatherProvider.isNightModeActive) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0x33A855F7),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    children: [
                                      Icon(Icons.bedtime_rounded, size: 10, color: Color(0xFFA855F7)),
                                      SizedBox(width: 3),
                                      Text(
                                        'SLEEP',
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFFA855F7),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            'Synoptic Doppler Radar & Convective Center',
                            style: TextStyle(fontSize: 11, color: atmTheme.subtitleColor),
                          ),
                        ],
                      ),
                    ),

                    // Quick Theme Toggle Button
                    IconButton(
                      tooltip: 'Toggle Theme',
                      icon: Icon(
                        atmTheme.isDarkTheme ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                        color: atmTheme.isDarkTheme ? const Color(0xFFF59E0B) : const Color(0xFF0F172A),
                      ),
                      onPressed: () {
                        final newMode = atmTheme.isDarkTheme ? AppThemeMode.light : AppThemeMode.dark;
                        weatherProvider.setThemeMode(newMode);
                      },
                    ),

                    // Severe Alert Button / Indicator
                    IconButton(
                      tooltip: 'Severe Alert Center',
                      icon: Badge(
                        isLabelVisible: alertsCount > 0,
                        label: Text('$alertsCount'),
                        backgroundColor: const Color(0xFFEF4444),
                        child: Icon(
                          alertsCount > 0 ? Icons.crisis_alert_rounded : Icons.notifications_none_rounded,
                          color: alertsCount > 0 ? const Color(0xFFEF4444) : atmTheme.textColor,
                        ),
                      ),
                      onPressed: () {
                        setState(() => _currentIndex = 2);
                      },
                    ),

                    // Refresh Button
                    IconButton(
                      tooltip: 'Refresh Forecast',
                      icon: weatherProvider.isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(Icons.refresh_rounded, color: atmTheme.textColor),
                      onPressed: weatherProvider.isLoading
                          ? null
                          : () => weatherProvider.refreshWeather(),
                    ),
                  ],
                ),
              ),

              // Active Tab Body
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: [
                    ForecastTab(
                      onOpenAlerts: () => setState(() => _currentIndex = 2),
                      onOpenSettings: () => setState(() => _currentIndex = 4),
                    ),
                    const RadarTab(),
                    const AlertsTab(),
                    CitiesTab(
                      onCitySelected: () {
                        setState(() => _currentIndex = 0);
                      },
                    ),
                    const SettingsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.wb_sunny_outlined),
            selectedIcon: Icon(Icons.wb_sunny_rounded),
            label: 'Forecast',
          ),
          const NavigationDestination(
            icon: Icon(Icons.radar_outlined),
            selectedIcon: Icon(Icons.radar_rounded),
            label: 'Radar',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: alertsCount > 0,
              label: Text('$alertsCount'),
              child: const Icon(Icons.warning_amber_rounded),
            ),
            selectedIcon: Badge(
              isLabelVisible: alertsCount > 0,
              label: Text('$alertsCount'),
              child: const Icon(Icons.warning_rounded),
            ),
            label: 'Alerts',
          ),
          const NavigationDestination(
            icon: Icon(Icons.location_city_outlined),
            selectedIcon: Icon(Icons.location_city_rounded),
            label: 'Cities',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
