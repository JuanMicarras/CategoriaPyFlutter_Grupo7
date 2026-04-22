import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/features/evaluation/domain/models/chart_point.dart';

class StudentTrendChart extends StatelessWidget {
  final List<ChartPoint> data;

  const StudentTrendChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return const SizedBox(
        height: 260,
        child: Center(child: Text('Sin datos')),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double baseWidth = constraints.maxWidth;

        // ancho por item para que haya scroll solo si realmente hace falta
        final double widthPerItem = 110;
        final double calculatedWidth = data.length * widthPerItem;

        final double chartWidth = calculatedWidth > baseWidth
            ? calculatedWidth
            : baseWidth;

        return SizedBox(
          height: 320,
          width: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: SizedBox(
              width: chartWidth,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: 5.2,
                  baselineY: 0,
                  clipData: const FlClipData.all(),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    checkToShowHorizontalLine: (value) =>
                        value >= 0 && value <= 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: AppTheme.grayColor300.withOpacity(0.45),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: LineTouchData(
                    enabled: true,
                    touchTooltipData: LineTouchTooltipData(
                      tooltipPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      tooltipMargin: 12,
                      getTooltipColor: (_) => const Color(0xFFE8DDF8),
                      getTooltipItems: (spots) {
                        return spots.map((spot) {
                          final index = spot.x.toInt();
                          if (index < 0 || index >= data.length) return null;

                          return LineTooltipItem(
                            '${data[index].label}\n${spot.y.toStringAsFixed(1)}',
                            TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          );
                        }).toList();
                      },
                    ),
                    getTouchedSpotIndicator: (barData, spotIndexes) {
                      return spotIndexes.map((index) {
                        return TouchedSpotIndicatorData(
                          FlLine(
                            color: AppTheme.secondaryColor.withOpacity(0.9),
                            strokeWidth: 2,
                          ),
                          FlDotData(
                            getDotPainter: (spot, percent, bar, i) {
                              return FlDotCirclePainter(
                                radius: 7,
                                color: AppTheme.secondaryColor,
                                strokeWidth: 2.5,
                                strokeColor: Colors.white,
                              );
                            },
                          ),
                        );
                      }).toList();
                    },
                  ),
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
                        reservedSize: 28,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          if (value < 0 || value > 5) {
                            return const SizedBox.shrink();
                          }

                          return Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: Text(
                              value.toInt().toString(),
                              style: AppTheme.bodyS.copyWith(
                                fontSize: 12,
                                color: AppTheme.grayColor500,
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
                        reservedSize: 68,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index < 0 || index >= data.length) {
                            return const SizedBox.shrink();
                          }

                          return SideTitleWidget(
                            meta: meta,
                            space: 12,
                            child: SizedBox(
                              width: 90,
                              child: Text(
                                data[index].label,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.bodyS.copyWith(
                                  fontSize: 12,
                                  color: AppTheme.grayColor500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      curveSmoothness: 0.28,
                      barWidth: 4,
                      color: AppTheme.secondaryColor,
                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            AppTheme.secondaryColor.withOpacity(0.30),
                            AppTheme.secondaryColor.withOpacity(0.10),
                          ],
                        ),
                      ),
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 5.5,
                            color: AppTheme.secondaryColor,
                            strokeWidth: 2.2,
                            strokeColor: Colors.white,
                          );
                        },
                      ),
                      spots: List.generate(
                        data.length,
                        (index) => FlSpot(index.toDouble(), data[index].value),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
