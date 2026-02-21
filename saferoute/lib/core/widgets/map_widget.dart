import 'dart:math';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

enum ZoneType { safe, moderate, danger }

class MapWidget extends StatefulWidget {
  final bool showHeatmap;
  final bool showRoute;
  final bool showPoliceStations;
  final double? height;

  const MapWidget({
    super.key,
    this.showHeatmap = true,
    this.showRoute = true,
    this.showPoliceStations = false,
    this.height,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> with SingleTickerProviderStateMixin {
  static const int gridSize = 16;
  static const double cellSize = 28;
  late List<List<ZoneType>> grid;
  int routeProgress = 0;

  static const List<List<int>> routePath = [
    [1, 1], [2, 1], [3, 2], [4, 3], [5, 4], [6, 5], [7, 5],
    [8, 6], [9, 7], [10, 8], [11, 9], [12, 10], [13, 11], [14, 12],
  ];

  static const List<List<int>> policeStations = [
    [3, 12], [8, 3], [13, 14],
  ];

  @override
  void initState() {
    super.initState();
    grid = _generateGrid();
    if (widget.showRoute) {
      _startAnimation();
    }
  }

  void _startAnimation() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return false;
      setState(() {
        routeProgress = (routeProgress + 1) % routePath.length;
      });
      return true;
    });
  }

  List<List<ZoneType>> _generateGrid() {
    final random = Random(42);
    return List.generate(gridSize, (r) {
      return List.generate(gridSize, (c) {
        final val = random.nextDouble();
        if (val < 0.55) return ZoneType.safe;
        if (val < 0.8) return ZoneType.moderate;
        return ZoneType.danger;
      });
    });
  }

  Color _zoneColor(ZoneType z) {
    switch (z) {
      case ZoneType.safe:
        return AppColors.safe.withOpacity(0.18);
      case ZoneType.moderate:
        return AppColors.moderate.withOpacity(0.22);
      case ZoneType.danger:
        return AppColors.danger.withOpacity(0.22);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 280,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: CustomPaint(
                    size: Size(
                      gridSize * cellSize + 20,
                      gridSize * cellSize + 20,
                    ),
                    painter: _MapPainter(
                      grid: grid,
                      showHeatmap: widget.showHeatmap,
                      showRoute: widget.showRoute,
                      showPoliceStations: widget.showPoliceStations,
                      routeProgress: routeProgress,
                      routePath: routePath,
                      policeStations: policeStations,
                      cellSize: cellSize,
                      gridSize: gridSize,
                      zoneColor: _zoneColor,
                    ),
                  ),
                ),
              ),
            ),
            // Legend
            Positioned(
              bottom: 8,
              left: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LegendItem(color: AppColors.safe.withOpacity(0.4), label: 'Low Risk'),
                    const SizedBox(width: 16),
                    _LegendItem(color: AppColors.moderate.withOpacity(0.4), label: 'Moderate'),
                    const SizedBox(width: 16),
                    _LegendItem(color: AppColors.danger.withOpacity(0.4), label: 'High Risk'),
                    if (widget.showRoute) ...[
                      const SizedBox(width: 16),
                      _LegendItem(color: AppColors.primary, label: 'Route', isCircle: true),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final bool isCircle;

  const _LegendItem({
    required this.color,
    required this.label,
    this.isCircle = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: isCircle ? null : BorderRadius.circular(2),
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}

class _MapPainter extends CustomPainter {
  final List<List<ZoneType>> grid;
  final bool showHeatmap;
  final bool showRoute;
  final bool showPoliceStations;
  final int routeProgress;
  final List<List<int>> routePath;
  final List<List<int>> policeStations;
  final double cellSize;
  final int gridSize;
  final Color Function(ZoneType) zoneColor;

  _MapPainter({
    required this.grid,
    required this.showHeatmap,
    required this.showRoute,
    required this.showPoliceStations,
    required this.routeProgress,
    required this.routePath,
    required this.policeStations,
    required this.cellSize,
    required this.gridSize,
    required this.zoneColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const offset = 10.0;

    // Grid lines
    final gridPaint = Paint()
      ..color = const Color(0xFFE2E8F0)
      ..strokeWidth = 0.5;
    for (int i = 0; i <= gridSize; i++) {
      canvas.drawLine(
        Offset(offset, i * cellSize + offset),
        Offset(gridSize * cellSize + offset, i * cellSize + offset),
        gridPaint,
      );
      canvas.drawLine(
        Offset(i * cellSize + offset, offset),
        Offset(i * cellSize + offset, gridSize * cellSize + offset),
        gridPaint,
      );
    }

    // Heatmap zones
    if (showHeatmap) {
      for (int r = 0; r < gridSize; r++) {
        for (int c = 0; c < gridSize; c++) {
          final rect = RRect.fromRectAndRadius(
            Rect.fromLTWH(
              c * cellSize + offset,
              r * cellSize + offset,
              cellSize,
              cellSize,
            ),
            const Radius.circular(3),
          );
          canvas.drawRRect(rect, Paint()..color = zoneColor(grid[r][c]));
        }
      }
    }

    // Route
    if (showRoute && routePath.length >= 2) {
      final routePaint = Paint()
        ..color = AppColors.primary.withOpacity(0.8)
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(
        routePath[0][1] * cellSize + cellSize / 2 + offset,
        routePath[0][0] * cellSize + cellSize / 2 + offset,
      );
      for (int i = 1; i < routePath.length; i++) {
        path.lineTo(
          routePath[i][1] * cellSize + cellSize / 2 + offset,
          routePath[i][0] * cellSize + cellSize / 2 + offset,
        );
      }
      canvas.drawPath(path, routePaint);

      // Start marker (green)
      canvas.drawCircle(
        Offset(
          routePath[0][1] * cellSize + cellSize / 2 + offset,
          routePath[0][0] * cellSize + cellSize / 2 + offset,
        ),
        6,
        Paint()..color = AppColors.safe,
      );

      // End marker (red)
      canvas.drawCircle(
        Offset(
          routePath.last[1] * cellSize + cellSize / 2 + offset,
          routePath.last[0] * cellSize + cellSize / 2 + offset,
        ),
        6,
        Paint()..color = AppColors.danger,
      );

      // Moving dot
      if (routeProgress < routePath.length) {
        final cx = routePath[routeProgress][1] * cellSize + cellSize / 2 + offset;
        final cy = routePath[routeProgress][0] * cellSize + cellSize / 2 + offset;
        canvas.drawCircle(
          Offset(cx, cy),
          10,
          Paint()..color = AppColors.primary.withOpacity(0.2),
        );
        canvas.drawCircle(
          Offset(cx, cy),
          5,
          Paint()..color = AppColors.primary,
        );
      }
    }

    // Police stations
    if (showPoliceStations) {
      for (final s in policeStations) {
        final cx = s[1] * cellSize + cellSize / 2 + offset;
        final cy = s[0] * cellSize + cellSize / 2 + offset;
        canvas.drawCircle(
          Offset(cx, cy),
          8,
          Paint()..color = AppColors.primary.withOpacity(0.2),
        );
        final tp = TextPainter(
          text: const TextSpan(text: '🏛', style: TextStyle(fontSize: 12)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(cx - tp.width / 2, cy - tp.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MapPainter oldDelegate) {
    return oldDelegate.routeProgress != routeProgress ||
        oldDelegate.showHeatmap != showHeatmap ||
        oldDelegate.showRoute != showRoute ||
        oldDelegate.showPoliceStations != showPoliceStations;
  }
}
