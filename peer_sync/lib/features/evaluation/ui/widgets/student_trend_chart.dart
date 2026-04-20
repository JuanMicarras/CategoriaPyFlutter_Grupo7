import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:peer_sync/core/themes/app_theme.dart';
import 'package:peer_sync/features/evaluation/domain/models/chart_point.dart';

class StudentTrendChart extends StatelessWidget {
  final List<ChartPoint> data;

  const StudentTrendChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;

    if (data.isEmpty) {
      return const SizedBox(
        height: 260,
        child: Center(child: Text('Sin datos')),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final double baseWidth = constraints.maxWidth;
        final double widthPerItem = 128;
        const double sidePadding = 32;
        const double extraRightSpace = 52;

        final double calculatedWidth =
            (data.length * widthPerItem) + (sidePadding * 2) + extraRightSpace;

        final double minWidth = baseWidth;
        final double chartWidth = calculatedWidth > minWidth
            ? calculatedWidth
            : minWidth + 60;

        return SizedBox(
          height: 320,
          child: ClipRect(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: SizedBox(
                width: chartWidth,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: sidePadding,
                    right: sidePadding + extraRightSpace,
                  ),
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
                            color: isLight
                                ? AppTheme.grayColor300.withOpacity(0.45)
                                : AppTheme.darkBorder.withOpacity(0.5),
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
                          getTooltipColor: (_) => isLight
                              ? const Color(0xFFE8DDF8)
                              : const Color(0xFF3F2A6B),
                          getTooltipItems: (spots) {
                            return spots.map((spot) {
                              final index = spot.x.toInt();
                              if (index < 0 || index >= data.length) {
                                return null;
                              }

                              return LineTooltipItem(
                                '${data[index].label}\n${spot.y.toStringAsFixed(1)}',
                                TextStyle(
                                  color: isLight
                                      ? AppTheme.primaryColor
                                      : AppTheme.darkPrimarySoft,
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
                            reservedSize: 34,
                            interval: 1,
                            getTitlesWidget: (value, meta) {
                              if (value < 0 || value > 5) {
                                return const SizedBox.shrink();
                              }

                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  value.toInt().toString(),
                                  style: AppTheme.bodyS.copyWith(
                                    fontSize: 12,
                                    color: isLight
                                        ? AppTheme.grayColor500
                                        : AppTheme.darkTextMuted,
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

                              final bool isFirst = index == 0;
                              final bool isLast = index == data.length - 1;

                              return SideTitleWidget(
                                meta: meta,
                                space: 12,
                                child: Transform.translate(
                                  offset: Offset(
                                    isFirst ? 10 : (isLast ? -18 : 0),
                                    0,
                                  ),
                                  child: SizedBox(
                                    width: isLast ? 120 : 100,
                                    child: Text(
                                      data[index].label,
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                      style: AppTheme.bodyS.copyWith(
                                        fontSize: 12,
                                        color: isLight
                                            ? AppTheme.grayColor500
                                            : AppTheme.darkTextMuted,
                                        fontWeight: FontWeight.w500,
                                      ),
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
                            (index) =>
                                FlSpot(index.toDouble(), data[index].value),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
