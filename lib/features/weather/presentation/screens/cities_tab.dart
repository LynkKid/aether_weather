import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aether_weather/features/weather/data/repositories/weather_repository.dart';
import 'package:aether_weather/features/weather/domain/models/weather_models.dart';
import 'package:aether_weather/features/weather/presentation/providers/weather_provider.dart';

class CitiesTab extends StatefulWidget {
  final VoidCallback onCitySelected;

  const CitiesTab({super.key, required this.onCitySelected});

  @override
  State<CitiesTab> createState() => _CitiesTabState();
}

class _CitiesTabState extends State<CitiesTab> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherProvider = context.watch<WeatherProvider>();
    final atmTheme = weatherProvider.atmosphericTheme;
    final isDark = atmTheme.isDarkTheme;

    final cardBg = atmTheme.cardBg;
    final cardBorder = atmTheme.cardBorder;
    final textColor = atmTheme.textColor;
    final subtitleColor = atmTheme.subtitleColor;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Search Input Bar
        TextField(
          controller: _searchController,
          onChanged: (val) => weatherProvider.searchCities(val),
          style: TextStyle(color: textColor),
          decoration: InputDecoration(
            hintText: 'Search world city or radar station...',
            hintStyle: TextStyle(color: subtitleColor),
            prefixIcon: Icon(Icons.search_rounded, color: subtitleColor),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded, color: subtitleColor),
                    onPressed: () {
                      _searchController.clear();
                      weatherProvider.clearSearchResults();
                    },
                  )
                : null,
            filled: true,
            fillColor: cardBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: BorderSide(color: cardBorder),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // Search Results List (if active)
        if (weatherProvider.isSearching) ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
        ] else if (weatherProvider.searchResults.isNotEmpty) ...[
          Text(
            'SEARCH RESULTS (${weatherProvider.searchResults.length})',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: subtitleColor),
          ),
          const SizedBox(height: 8),
          ...weatherProvider.searchResults.map((city) => _buildCityTile(
                context,
                city: city,
                isSelected: weatherProvider.currentCity?.name == city.name,
                isDark: isDark,
                weatherProvider: weatherProvider,
                cardBg: cardBg,
                cardBorder: cardBorder,
                textColor: textColor,
                subtitleColor: subtitleColor,
                isSearchItem: true,
              )),
          const Divider(height: 32),
        ],

        // GPS Device Location Quick Selector
        InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () async {
            await weatherProvider.useDeviceLocation();
            widget.onCitySelected();
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0369A1), Color(0xFF0284C7)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.my_location_rounded, color: Colors.white, size: 28),
                SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Use GPS Live Coordinates',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Direct sensor positioning from connected hardware',
                        style: TextStyle(color: Colors.white70, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Popular Global Presets
        Text(
          'POPULAR METEOROLOGICAL STATIONS',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: subtitleColor),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: WeatherRepository.defaultCities.map((city) {
            final isCurrent = weatherProvider.currentCity?.name == city.name;
            return ChoiceChip(
              label: Text('${city.name}, ${city.country}'),
              selected: isCurrent,
              onSelected: (_) async {
                await weatherProvider.fetchWeatherForCity(city);
                widget.onCitySelected();
              },
              selectedColor: const Color(0xFF0284C7),
              labelStyle: TextStyle(
                fontSize: 11,
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCurrent ? Colors.white : textColor,
              ),
              backgroundColor: cardBg,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
                side: BorderSide(color: isCurrent ? const Color(0xFF0284C7) : cardBorder),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // Saved Cities Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'SAVED STATIONS (${weatherProvider.savedCities.length})',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.8, color: subtitleColor),
            ),
          ],
        ),
        const SizedBox(height: 12),

        ...weatherProvider.savedCities.map((city) => _buildCityTile(
              context,
              city: city,
              isSelected: weatherProvider.currentCity?.name == city.name,
              isDark: isDark,
              weatherProvider: weatherProvider,
              cardBg: cardBg,
              cardBorder: cardBorder,
              textColor: textColor,
              subtitleColor: subtitleColor,
            )),
      ],
    );
  }

  Widget _buildCityTile(
    BuildContext context, {
    required CityLocation city,
    required bool isSelected,
    required bool isDark,
    required WeatherProvider weatherProvider,
    required Color cardBg,
    required Color cardBorder,
    required Color textColor,
    required Color subtitleColor,
    bool isSearchItem = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: isSelected ? const Color(0xFF0284C7).withAlpha(40) : cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? const Color(0xFF0284C7) : cardBorder,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          onTap: () async {
          if (isSearchItem) {
            await weatherProvider.toggleFavorite(city);
          }
          await weatherProvider.fetchWeatherForCity(city);
          widget.onCitySelected();
        },
        leading: Icon(
          city.isCurrentLocation ? Icons.near_me_rounded : Icons.location_city_rounded,
          color: isSelected ? const Color(0xFF0284C7) : subtitleColor,
        ),
        title: Text(
          city.name,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor),
        ),
        subtitle: Text(
          '${city.country} · ${city.latitude.toStringAsFixed(2)}°, ${city.longitude.toStringAsFixed(2)}°',
          style: TextStyle(fontSize: 11, color: subtitleColor),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isSearchItem)
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 20),
                color: subtitleColor,
                onPressed: () => weatherProvider.removeSavedCity(city),
              ),
            if (isSearchItem)
              IconButton(
                icon: const Icon(Icons.add_circle_outline_rounded, size: 22),
                color: const Color(0xFF10B981),
                onPressed: () async {
                  await weatherProvider.toggleFavorite(city);
                  _searchController.clear();
                  weatherProvider.clearSearchResults();
                },
              ),
          ],
        ),
      ),
    ),
  );
  }
}
