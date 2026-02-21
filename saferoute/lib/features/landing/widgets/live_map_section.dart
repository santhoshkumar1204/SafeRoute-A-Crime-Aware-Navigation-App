import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum _Zone { safe, moderate, danger }

const int _gridSize = 20;
const double _cell = 28;

const _zoneColors = {
  _Zone.safe: Color.fromRGBO(22, 163, 74, 0.18),
  _Zone.moderate: Color.fromRGBO(245, 158, 11, 0.22),
  _Zone.danger: Color.fromRGBO(220, 38, 38, 0.22),
};

const List<List<int>> _routePath = [
  [1, 1], [2, 1], [3, 1], [4, 2], [5, 3], [6, 4], [7, 5], [8, 5],
  [9, 6], [10, 7], [11, 8], [12, 9], [13, 10], [14, 10], [15, 11],
  [16, 12], [17, 13], [18, 14], [18, 15],
];

class _RiskMarker {
  final int r, c;
  final _Zone level;
  final int score;
  const _RiskMarker(this.r, this.c, this.level, this.score);
}

const _riskMarkers = [
  _RiskMarker(5, 7, _Zone.danger, 82),
  _RiskMarker(10, 3, _Zone.moderate, 54),
  _RiskMarker(14, 15, _Zone.danger, 76),
  _RiskMarker(8, 12, _Zone.moderate, 48),
];

List<List<_Zone>> _generateGrid() {
  final rng = Random();
  return List.generate(_gridSize, (_) {
    return List.generate(_gridSize + 1, (_) {
      final r = rng.nextDouble();
      if (r < 0.55) return _Zone.safe;
      if (r < 0.8) return _Zone.moderate;
      return _Zone.danger;
    });
  });
}

class LiveMapSection extends StatefulWidget {
  const LiveMapSection({super.key});

  @override
  State<LiveMapSection> createState() => _LiveMapSectionState();
}

class _LiveMapSectionState extends State<LiveMapSection> {
  late final List<List<_Zone>> _grid;
  bool _showHeatmap = true;
  bool _showPrediction = true;
  String _timeOfDay = 'evening';
  int? _hoveredMarker;
  int _routeProgress = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _grid = _generateGrid();
    _timer = Timer.periodic(const Duration(milliseconds: 600), (_) {
      if (mounted) {
        setState(() {
          _routeProgress = (_routeProgress + 1) % _routePath.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktop = screenWidth >= 1024;

    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 80),
      child: Column(
        children: [
          // Title
          Text(
            'Live Crime',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: isDesktop ? 36 : 28,
              fontWeight: FontWeight.w700,
              color: AppColors.foreground,
            ),
          ),
          ShaderMask(
            shaderCallback: (bounds) =>
                AppColors.primaryGradient.createShader(bounds),
            child: Text(
              'Heatmap Prototype',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isDesktop ? 36 : 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 12),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: const Text(
              'Interactive map showing AI-predicted crime risk zones with real-time route analysis',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.mutedForeground,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 40),

          // Map + Controls
          isDesktop
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildMap()),
                    const SizedBox(width: 24),
                    SizedBox(width: 300, child: _buildControls()),
                  ],
                )
              : Column(
                  children: [
                    _buildMap(),
                    const SizedBox(height: 16),
                    _buildControls(),
                  ],
                ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    final svgW = _gridSize * _cell + 20;
    final svgH = _gridSize * _cell + 20;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: svgW,
              height: svgH,
              child: CustomPaint(
                painter: _MapPainter(
                  grid: _grid,
                  showHeatmap: _showHeatmap,
                  showPrediction: _showPrediction,
                  routeProgress: _routeProgress,
                  hoveredMarker: _hoveredMarker,
                ),
                child: MouseRegion(
                  onHover: (event) {
                    // Check if hovering over a risk marker
                    for (int i = 0; i < _riskMarkers.length; i++) {
                      final m = _riskMarkers[i];
                      final cx = m.c * _cell + _cell / 2 + 10;
                      final cy = m.r * _cell + _cell / 2 + 10;
                      final dx = event.localPosition.dx - cx;
                      final dy = event.localPosition.dy - cy;
                      if (dx * dx + dy * dy < 16 * 16) {
                        if (_hoveredMarker != i) {
                          setState(() => _hoveredMarker = i);
                        }
                        return;
                      }
                    }
                    if (_hoveredMarker != null) {
                      setState(() => _hoveredMarker = null);
                    }
                  },
                  onExit: (_) {
                    if (_hoveredMarker != null) {
                      setState(() => _hoveredMarker = null);
                    }
                  },
                  child: const SizedBox.expand(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Legend
          Wrap(
            spacing: 16,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              _legendItem(AppColors.safe.withOpacity(0.3), 'Low Risk'),
              _legendItem(AppColors.warning.withOpacity(0.3), 'Moderate'),
              _legendItem(AppColors.danger.withOpacity(0.3), 'High Risk'),
              _legendItem(AppColors.primary, 'Route', isCircle: true),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, {bool isCircle = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius:
                isCircle ? BorderRadius.circular(6) : BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.mutedForeground),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        // Map Controls
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Map Controls',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _toggleControl(
                icon: Icons.layers,
                label: 'Crime Heatmap',
                active: _showHeatmap,
                onToggle: () => setState(() => _showHeatmap = !_showHeatmap),
              ),
              const SizedBox(height: 12),
              _toggleControl(
                icon: Icons.visibility,
                label: 'AI Prediction',
                active: _showPrediction,
                onToggle: () =>
                    setState(() => _showPrediction = !_showPrediction),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Time of Day
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: AppColors.foreground),
                  SizedBox(width: 8),
                  Text(
                    'Time of Day',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...['morning', 'afternoon', 'evening', 'night'].map(
                (t) => Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => setState(() => _timeOfDay = t),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _timeOfDay == t
                              ? AppColors.primary
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          t[0].toUpperCase() + t.substring(1),
                          style: TextStyle(
                            fontSize: 13,
                            color: _timeOfDay == t
                                ? Colors.white
                                : AppColors.foreground,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Quick Toggle
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.place, size: 16, color: AppColors.foreground),
                  SizedBox(width: 8),
                  Text(
                    'Quick Toggle',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Police Stations',
                style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
              ),
              const SizedBox(height: 6),
              const Text(
                'Community Reports',
                style: TextStyle(fontSize: 12, color: AppColors.mutedForeground),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _toggleControl({
    required IconData icon,
    required String label,
    required bool active,
    required VoidCallback onToggle,
  }) {
    return GestureDetector(
      onTap: onToggle,
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.foreground),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13),
            ),
          ),
          // Custom toggle switch
          Container(
            width: 36,
            height: 20,
            decoration: BoxDecoration(
              color: active ? AppColors.primary : AppColors.muted,
              borderRadius: BorderRadius.circular(10),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment:
                  active ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 16,
                height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPainter extends CustomPainter {
  final List<List<_Zone>> grid;
  final bool showHeatmap;
  final bool showPrediction;
  final int routeProgress;
  final int? hoveredMarker;

  _MapPainter({
    required this.grid,
    required this.showHeatmap,
    required this.showPrediction,
    required this.routeProgress,
    this.hoveredMarker,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 0.5;

    // Grid lines
    for (int i = 0; i <= _gridSize; i++) {
      canvas.drawLine(
        Offset(10, i * _cell + 10),
        Offset(_gridSize * _cell + 10, i * _cell + 10),
        gridPaint,
      );
      canvas.drawLine(
        Offset(i * _cell + 10, 10),
        Offset(i * _cell + 10, _gridSize * _cell + 10),
        gridPaint,
      );
    }

    // Heatmap zones
    if (showHeatmap) {
      for (int r = 0; r < grid.length; r++) {
        for (int c = 0; c < grid[r].length && c < _gridSize; c++) {
          final zone = grid[r][c];
          final rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(c * _cell + 10, r * _cell + 10, _cell, _cell),
            const Radius.circular(4),
          );
          canvas.drawRRect(rect, Paint()..color = _zoneColors[zone]!);
        }
      }
    }

    // Route line
    final routePaint = Paint()
      ..color = const Color(0xFF2563EB)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final routePoints = _routePath
        .map((p) => Offset(
              p[1] * _cell + _cell / 2 + 10,
              p[0] * _cell + _cell / 2 + 10,
            ))
        .toList();

    if (routePoints.length > 1) {
      final path = Path()..moveTo(routePoints[0].dx, routePoints[0].dy);
      for (int i = 1; i < routePoints.length; i++) {
        path.lineTo(routePoints[i].dx, routePoints[i].dy);
      }
      canvas.drawPath(path, routePaint..color = const Color(0xCC2563EB));
    }

    // Moving dot
    if (routeProgress < _routePath.length) {
      final pos = routePoints[routeProgress];
      // Pulse ring
      canvas.drawCircle(
        pos,
        10,
        Paint()..color = const Color(0x332563EB),
      );
      // Solid dot
      canvas.drawCircle(
        pos,
        5,
        Paint()..color = const Color(0xFF2563EB),
      );
    }

    // Start marker (green)
    canvas.drawCircle(
      routePoints.first,
      6,
      Paint()..color = const Color(0xFF16A34A),
    );

    // End marker (red)
    canvas.drawCircle(
      routePoints.last,
      6,
      Paint()..color = const Color(0xFFDC2626),
    );

    // Risk markers
    if (showPrediction) {
      for (int i = 0; i < _riskMarkers.length; i++) {
        final m = _riskMarkers[i];
        final cx = m.c * _cell + _cell / 2 + 10;
        final cy = m.r * _cell + _cell / 2 + 10;

        // Pulsing circle
        final markerColor = m.level == _Zone.danger
            ? const Color(0x4DDC2626)
            : const Color(0x4DF59E0B);
        canvas.drawCircle(Offset(cx, cy), 12, Paint()..color = markerColor);

        // Warning text
        final tp = TextPainter(
          text: TextSpan(
            text: '⚠',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: m.level == _Zone.danger
                  ? const Color(0xFFDC2626)
                  : const Color(0xFFF59E0B),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));

        // Tooltip on hover
        if (hoveredMarker == i) {
          final tooltipW = 110.0;
          final tooltipH = 28.0;
          final tooltipX = cx - tooltipW / 2;
          final tooltipY = cy - 30;

          final rrect = RRect.fromRectAndRadius(
            Rect.fromLTWH(tooltipX, tooltipY, tooltipW, tooltipH),
            const Radius.circular(8),
          );
          canvas.drawRRect(
              rrect, Paint()..color = const Color(0xFF0F172A));

          final tooltipTp = TextPainter(
            text: TextSpan(
              text: 'Risk Score: ${m.score}%',
              style: const TextStyle(fontSize: 10, color: Colors.white),
            ),
            textDirection: TextDirection.ltr,
          )..layout();
          tooltipTp.paint(
            canvas,
            Offset(
              tooltipX + (tooltipW - tooltipTp.width) / 2,
              tooltipY + (tooltipH - tooltipTp.height) / 2,
            ),
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter old) =>
      old.showHeatmap != showHeatmap ||
      old.showPrediction != showPrediction ||
      old.routeProgress != routeProgress ||
      old.hoveredMarker != hoveredMarker;
}
