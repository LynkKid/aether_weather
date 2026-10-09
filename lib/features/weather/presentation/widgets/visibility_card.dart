import 'package:flutter/material.dart';

class VisibilityCard extends StatelessWidget {
  final double visibilityKm;
  final bool isMph;
  final Color cardBg;
  final Color cardBorder;
  final Color textColor;
  final Color subtitleColor;

  const VisibilityCard({
    super.key,
    required this.visibilityKm,
    required this.isMph,
    required this.cardBg,
    required this.cardBorder,
    required this.textColor,
    required this.subtitleColor,
  });

  String _formatVis() {
    if (isMph) {
      final miles = visibilityKm * 0.621371;
      return '${miles.toStringAsFixed(1)} mi';
    }
    return '${visibilityKm.toStringAsFixed(1)} km';
  }

  String _getCategory() {
    if (visibilityKm >= 10.0) return 'Optimal Clear Horizons';
    if (visibilityKm >= 5.0) return 'Good Atmospheric Clarity';
    if (visibilityKm >= 2.0) return 'Moderate Haze / Mist';
    return 'Dense Obscuration / Fog';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
              Expanded(
                child: Row(
                  children: [
                    const Icon(Icons.visibility_rounded, size: 16, color: Color(0xFF8B5CF6)),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'OPTICAL VISIBILITY',
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                          color: subtitleColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                visibilityKm > 8 ? 'Clear' : 'Obscured',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _formatVis(),
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _getCategory(),
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Color(0xFF8B5CF6)),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (visibilityKm / 10.0).clamp(0.05, 1.0),
              backgroundColor: Colors.white.withAlpha(20),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }
}
