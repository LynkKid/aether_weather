import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:aether_weather/features/weather/presentation/providers/radar_provider.dart';
import 'package:aether_weather/features/weather/presentation/providers/weather_provider.dart';

class RadarTab extends StatefulWidget {
  const RadarTab({super.key});

  @override
  State<RadarTab> createState() => _RadarTabState();
}

class _RadarTabState extends State<RadarTab> with SingleTickerProviderStateMixin {
  late final AnimationController _sweepController;

  @override
  void initState() {
    super.initState();
    _sweepController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
  }

  @override
  void dispose() {
    _sweepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radar = context.watch<RadarProvider>();
    final weatherProvider = context.watch<WeatherProvider>();
    final weather = weatherProvider.weather;
    final atmTheme = weatherProvider.atmosphericTheme;

    // Synchronize radar telemetry with live weather when available
    if (weather != null) {
      final currentRain = weather.weatherCode >= 51 ? 1.5 : 0.0;
      final currentRainProb = weather.hourly.isNotEmpty
          ? weather.hourly.first.precipitationProbability
          : 20;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        radar.updateTelemetryFromWeather(
          currentPrecip: currentRain,
          rainProb: currentRainProb,
          temp: weather.temperature,
          feelsLike: weather.feelsLike,
          minTemp: weather.daily.isNotEmpty ? weather.daily.first.minTemp : 20.0,
          maxTemp: weather.daily.isNotEmpty ? weather.daily.first.maxTemp : 30.0,
          cloudCover: weather.cloudCover,
          windSpeed: weather.windSpeed,
          windDirection: weather.windDirection,
          hourlyPrecip: weather.hourly.take(6).map((h) => h.precipitationProbability > 40 ? 1.8 : 0.4).toList(),
          hourlyTemp: weather.hourly.take(6).map((h) => h.temperature).toList(),
        );
      });
    }

    final cardBg = atmTheme.cardBg;
    final cardBorder = atmTheme.cardBorder;
    final textColor = atmTheme.textColor;
    final subtitleColor = atmTheme.subtitleColor;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Layer Selector Chips (Precip, Thermal, Clouds)
        Row(
          children: [
            Expanded(
              child: _buildLayerButton(
                context,
                title: 'Precipitation',
                icon: Icons.water_drop_rounded,
                selected: radar.activeLayer == WeatherLayerType.precip,
                color: const Color(0xFF22D3EE),
                onTap: () => radar.setActiveLayer(WeatherLayerType.precip),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildLayerButton(
                context,
                title: 'Temperature',
                icon: Icons.thermostat_rounded,
                selected: radar.activeLayer == WeatherLayerType.temp,
                color: const Color(0xFFF97316),
                onTap: () => radar.setActiveLayer(WeatherLayerType.temp),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildLayerButton(
                context,
                title: 'Satellite Clouds',
                icon: Icons.cloud_rounded,
                selected: radar.activeLayer == WeatherLayerType.clouds,
                color: const Color(0xFF38BDF8),
                onTap: () => radar.setActiveLayer(WeatherLayerType.clouds),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // Radar Canvas Container
        Container(
          height: 360,
          decoration: BoxDecoration(
            color: const Color(0xFF0B1120),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: cardBorder),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(80),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Custom Radar Canvas
              AnimatedBuilder(
                animation: _sweepController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(double.infinity, 360),
                    painter: _RadarCanvasPainter(
                      sweepAngle: _sweepController.value * 2 * math.pi,
                      timeIndex: radar.timeIndex,
                      layer: radar.activeLayer,
                      zoomLevel: radar.zoomLevel,
                      telemetry: radar.telemetry,
                    ),
                  );
                },
              ),

              // Overlay Status Badge
              Positioned(
                top: 14,
                left: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(180),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF10B981),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'LIVE DOPPLER · ${weather?.city.name ?? 'Aether Station'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Zoom Controls (+ / -)
              Positioned(
                right: 14,
                top: 14,
                child: Column(
                  children: [
                    _buildZoomButton(
                      icon: Icons.add_rounded,
                      onTap: () => radar.zoomIn(),
                    ),
                    const SizedBox(height: 6),
                    _buildZoomButton(
                      icon: Icons.remove_rounded,
                      onTap: () => radar.zoomOut(),
                    ),
                  ],
                ),
              ),

              // Bottom Canvas Legend
              Positioned(
                bottom: 12,
                left: 14,
                right: 14,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'RNG: 200 km · IMPULSE 10 GHz',
                      style: TextStyle(
                        fontSize: 9,
                        fontFamily: 'monospace',
                        color: Colors.white.withAlpha(140),
                      ),
                    ),
                    Text(
                      'ZOOM: ${(radar.zoomLevel * 100).round()}%',
                      style: TextStyle(
                        fontSize: 9,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        color: Colors.white.withAlpha(180),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Timeline Scrubber & Controls (-90m to +60m)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => radar.togglePlay(),
                        icon: Icon(
                          radar.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        RadarProvider.timeLabels[radar.timeIndex],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: radar.timeIndex == 3 ? const Color(0xFF10B981) : textColor,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'Loop Interval: 1.4s',
                    style: TextStyle(fontSize: 10, color: subtitleColor),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Timeline scrubber chips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(RadarProvider.timeLabels.length, (idx) {
                  final isSelected = radar.timeIndex == idx;
                  final label = RadarProvider.timeLabels[idx];
                  return InkWell(
                    onTap: () => radar.setTimeIndex(idx),
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (idx == 3 ? const Color(0xFF10B981) : const Color(0xFF38BDF8))
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Colors.white
                              : (idx == 3 ? const Color(0xFF10B981) : subtitleColor),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Live Radar Telemetry Data Grid
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: cardBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'RADAR SCAN TELEMETRY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.8,
                      color: subtitleColor,
                    ),
                  ),
                  Text(
                    radar.telemetry.lastFetched,
                    style: const TextStyle(fontSize: 10, color: Color(0xFF10B981)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.2,
                children: [
                  _buildTelemetryItem(
                    label: 'Precipitation',
                    value: '${radar.telemetry.precipCurrentMm.toStringAsFixed(1)} mm/h',
                    subvalue: '${radar.telemetry.precipProbability}% Rain Chance',
                    color: const Color(0xFF22D3EE),
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                  ),
                  _buildTelemetryItem(
                    label: 'Surface Temp',
                    value: '${radar.telemetry.tempCurrent.round()}°C',
                    subvalue: 'Apparent ${radar.telemetry.tempApparent.round()}°C',
                    color: const Color(0xFFF97316),
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                  ),
                  _buildTelemetryItem(
                    label: 'Satellite Cloud',
                    value: '${radar.telemetry.cloudCoverTotal}%',
                    subvalue: 'Low ${radar.telemetry.cloudCoverLow}% · High ${radar.telemetry.cloudCoverHigh}%',
                    color: const Color(0xFF38BDF8),
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                  ),
                  _buildTelemetryItem(
                    label: 'Vector Flow',
                    value: '${radar.telemetry.windSpeed.round()} km/h',
                    subvalue: 'Heading ${radar.telemetry.windDirection}°',
                    color: const Color(0xFFA855F7),
                    textColor: textColor,
                    subtitleColor: subtitleColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLayerButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool selected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: selected ? color.withAlpha(40) : Colors.white.withAlpha(10),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? color : Colors.white.withAlpha(20),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: selected ? color : Colors.white60),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: selected ? color : Colors.white70,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(180),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }

  Widget _buildTelemetryItem({
    required String label,
    required String value,
    required String subvalue,
    required Color color,
    required Color textColor,
    required Color subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(8),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: subtitleColor)),
            ],
          ),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor)),
          Text(subvalue, style: TextStyle(fontSize: 9, color: subtitleColor), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _RadarCanvasPainter extends CustomPainter {
  final double sweepAngle;
  final int timeIndex;
  final WeatherLayerType layer;
  final double zoomLevel;
  final LayerTelemetryData telemetry;

  _RadarCanvasPainter({
    required this.sweepAngle,
    required this.timeIndex,
    required this.layer,
    required this.zoomLevel,
    required this.telemetry,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Background base
    final bgPaint = Paint()..color = const Color(0xFF0B1120);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // 1. Concentric Range Rings
    final ringPaint = Paint()
      ..color = const Color(0x33475569)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (double r = 40; r <= 180; r += 40) {
      canvas.drawCircle(Offset(cx, cy), r * zoomLevel, ringPaint);
    }

    // Compass Crosshairs
    canvas.drawLine(Offset(cx, 0), Offset(cx, size.height), ringPaint);
    canvas.drawLine(Offset(0, cy), Offset(size.width, cy), ringPaint);

    // Topography & Terrain Mock Contours
    final terrainPaint = Paint()..color = const Color(0x1F1E293B);
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 30, cy + 25), width: 140 * zoomLevel, height: 90 * zoomLevel),
      terrainPaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 60, cy - 40), width: 110 * zoomLevel, height: 70 * zoomLevel),
      terrainPaint,
    );

    // Calculate wind drift shift based on windDirection and timeIndex (3 is live)
    final windRad = (telemetry.windDirection * math.pi) / 180.0;
    final driftDist = (timeIndex - 3) * 14.0 * zoomLevel;
    final shiftX = math.sin(windRad) * driftDist;
    final shiftY = -math.cos(windRad) * driftDist;

    // 2. LAYER SPECIFIC RENDERING
    if (layer == WeatherLayerType.precip) {
      // PRECIPITATION DOPPLER ECHOES
      final rainFactor = (telemetry.hourlyPrecip.length > timeIndex
              ? telemetry.hourlyPrecip[timeIndex]
              : 0.8)
          .clamp(0.3, 3.0);

      // Light rain band (Green/Cyan)
      final p1 = Paint()
        ..shader = const RadialGradient(
          colors: [
            Color(0xB222C55E),
            Color(0x7338BDF8),
            Color(0x0038BDF8),
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(cx + 25 + shiftX, cy - 15 + shiftY),
          radius: 80 * zoomLevel * rainFactor,
        ));
      canvas.drawCircle(Offset(cx + 25 + shiftX, cy - 15 + shiftY), 80 * zoomLevel * rainFactor, p1);

      // Moderate Rain (Yellow)
      final p2 = Paint()
        ..shader = const RadialGradient(
          colors: [
            Color(0xD0EAB308),
            Color(0x8C22C55E),
            Color(0x0022C55E),
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(cx + 20 + shiftX, cy - 10 + shiftY),
          radius: 45 * zoomLevel * rainFactor,
        ));
      canvas.drawCircle(Offset(cx + 20 + shiftX, cy - 10 + shiftY), 45 * zoomLevel * rainFactor, p2);

      // Severe Convective Red Core
      final p3 = Paint()
        ..shader = const RadialGradient(
          colors: [
            Color(0xEEEF4444),
            Color(0xB0F97316),
            Color(0x00F97316),
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(cx + 15 + shiftX, cy - 5 + shiftY),
          radius: 22 * zoomLevel * rainFactor,
        ));
      canvas.drawCircle(Offset(cx + 15 + shiftX, cy - 5 + shiftY), 22 * zoomLevel * rainFactor, p3);
    } else if (layer == WeatherLayerType.temp) {
      // THERMAL ISOTHERM HEATMAP OVERLAY
      final tVal = telemetry.hourlyTemp.length > timeIndex
          ? telemetry.hourlyTemp[timeIndex]
          : telemetry.tempCurrent;

      List<Color> thermalColors;
      if (tVal < 15) {
        thermalColors = [const Color(0x733B82F6), const Color(0x596366F1), const Color(0x009333EA)];
      } else if (tVal < 25) {
        thermalColors = [const Color(0x7310B981), const Color(0x5938BDF8), const Color(0x003B82F6)];
      } else {
        thermalColors = [const Color(0x8CF97316), const Color(0x66EAB308), const Color(0x0010B981)];
      }

      final tPaint = Paint()
        ..shader = RadialGradient(
          colors: thermalColors,
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 170 * zoomLevel));

      canvas.drawCircle(Offset(cx, cy), 170 * zoomLevel, tPaint);
    } else if (layer == WeatherLayerType.clouds) {
      // SATELLITE CLOUD COVER OVERLAY
      final cloudPaint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withAlpha(120),
            Colors.white.withAlpha(60),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(cx - 30 + shiftX, cy + 20 + shiftY),
          radius: 120 * zoomLevel,
        ));
      canvas.drawCircle(Offset(cx - 30 + shiftX, cy + 20 + shiftY), 120 * zoomLevel, cloudPaint);

      final cloudPaint2 = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withAlpha(90),
            Colors.transparent,
          ],
        ).createShader(Rect.fromCircle(
          center: Offset(cx + 50 + shiftX, cy - 35 + shiftY),
          radius: 95 * zoomLevel,
        ));
      canvas.drawCircle(Offset(cx + 50 + shiftX, cy - 35 + shiftY), 95 * zoomLevel, cloudPaint2);
    }

    // 3. RADAR ROTATING SWEEP BEAM
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: 0.0,
        endAngle: 0.5,
        colors: const [
          Color(0x0010B981),
          Color(0x6610B981),
        ],
        transform: GradientRotation(sweepAngle),
      ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: 180 * zoomLevel));

    canvas.drawCircle(Offset(cx, cy), 180 * zoomLevel, sweepPaint);

    // Center Station Marker
    final centerPaint = Paint()..color = const Color(0xFF38BDF8);
    canvas.drawCircle(Offset(cx, cy), 4, centerPaint);
    canvas.drawCircle(Offset(cx, cy), 8, Paint()..color = const Color(0x4438BDF8));
  }

  @override
  bool shouldRepaint(covariant _RadarCanvasPainter oldDelegate) => true;
}
