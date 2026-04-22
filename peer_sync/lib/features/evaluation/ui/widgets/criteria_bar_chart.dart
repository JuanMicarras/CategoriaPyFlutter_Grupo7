import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/features/evaluation/domain/models/chart_point.dart';

class CriteriaBarChart extends StatelessWidget {
  final List<ChartPoint> data;
  final double maxY;
  final bool hideGeneralBar;
  final double? yInterval;
  final int? maxBars;

  const CriteriaBarChart({
    super.key,
    required this.data,
    this.maxY = 5,
    this.hideGeneralBar = false,
    this.yInterval,
    this.maxBars,
  });

  static double? extractGeneralValue(List<ChartPoint> data) {
    try {
      final general = data.firstWhere(
        (item) => item.label.toLowerCase() == 'general',
      );
      return general.value;
    } catch (_) {
      return null;
    }
  }

  static List<ChartPoint> visibleBars(
    List<ChartPoint> data, {
    bool hideGeneralBar = false,
  }) {
    if (!hideGeneralBar) return data;
    return data.where((item) => item.label.toLowerCase() != 'general').toList();
  }

  @override
  Widget build(BuildContext context) {
    var visibleData = visibleBars(data, hideGeneralBar: hideGeneralBar);

    if (maxBars != null && visibleData.length > maxBars!) {
      visibleData = visibleData.sublist(visibleData.length - maxBars!);
    }

    if (visibleData.isEmpty) {
      return const SizedBox(
        height: 240,
        child: Center(child: Text('Sin datos')),
      );
    }

    final interval = yInterval ?? (maxY == 100 ? 25 : 1);

    return SizedBox(
      height: 240,
      child: BarChart(
        BarChartData(
          minY: 0,
          maxY: maxY,
          alignment: BarChartAlignment.spaceAround,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: interval,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppTheme.grayColor300.withOpacity(0.5),
              strokeWidth: 1,
            ),
          ),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: interval,
                getTitlesWidget: (value, meta) {
                  if (value < 0 || value > maxY) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: Text(
                      value.toInt().toString(),
                      style: AppTheme.bodyS.copyWith(
                        fontSize: 12,
                        color: const Color(0xFF6B7280),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 42,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index < 0 || index >= visibleData.length) {
                    return const SizedBox.shrink();
                  }

                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: SizedBox(
                      width: 60,
                      child: Text(
                        visibleData[index].label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.bodyS.copyWith(
                          fontSize: 12,
                          color: const Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          barGroups: List.generate(
            visibleData.length,
            (index) => BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: visibleData[index].value,
                  width: 24,
                  color: AppTheme.secondaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
