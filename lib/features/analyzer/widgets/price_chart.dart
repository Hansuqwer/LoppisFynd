import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/tokens/app_tokens.dart';
import '../../../gen/app_localizations.dart';

class PriceChart extends StatelessWidget {
  const PriceChart({
    super.key,
    required this.min,
    required this.median,
    required this.max,
    required this.compsRawJson,
  });

  final double? min;
  final double? median;
  final double? max;
  final String? compsRawJson;

  List<({DateTime at, double priceSek})> _salePointsFromRawJson(
    String rawJson,
  ) {
    try {
      final decoded = jsonDecode(rawJson);
      if (decoded is! Map) return const [];
      final salesAny = decoded['sales'];
      if (salesAny is! List) return const [];

      final out = <({DateTime at, double priceSek})>[];
      for (final s in salesAny) {
        if (s is! Map) continue;
        final priceAny = s['priceSek'];
        final endAny = s['endDate'];
        final price = priceAny is num ? priceAny.toDouble() : null;
        final at = endAny is String ? DateTime.tryParse(endAny) : null;
        if (price == null || at == null) continue;
        out.add((at: at, priceSek: price));
      }

      out.sort((a, b) => a.at.compareTo(b.at));
      return out;
    } catch (_) {
      return const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final raw = compsRawJson;
    final sales = raw == null
        ? const <({DateTime at, double priceSek})>[]
        : _salePointsFromRawJson(raw);

    if (sales.length >= 2) {
      final spots = <FlSpot>[];
      for (var i = 0; i < sales.length; i += 1) {
        spots.add(FlSpot(i.toDouble(), sales[i].priceSek));
      }

      final minY =
          sales.map((p) => p.priceSek).reduce((a, b) => a < b ? a : b);
      final maxY =
          sales.map((p) => p.priceSek).reduce((a, b) => a > b ? a : b);

      return SizedBox(
        height: 160,
        child: LineChart(
          LineChartData(
            minY: (minY * 0.9).clamp(0, double.infinity),
            maxY: (maxY * 1.1).clamp(0, double.infinity),
            backgroundColor: Colors.transparent,
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: false),
            titlesData: const FlTitlesData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: AppColors.deepSapphire,
                barWidth: 3,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 3.5,
                      color: AppColors.primaryAction,
                      strokeWidth: 2,
                      strokeColor: AppColors.cloudDancer,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: AppColors.deepSapphire.withValues(alpha: 0.08),
                ),
              ),
            ],
          ),
          duration: AppMotion.normal,
          curve: AppMotion.curve,
        ),
      );
    }

    if (min == null || median == null || max == null) {
      return Container(
        height: 160,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderSubtle),
        ),
        alignment: Alignment.center,
        child: Text(AppLocalizations.of(context)!.itemDetailNoMarketDataYet),
      );
    }

    final points = <FlSpot>[
      FlSpot(0, min!),
      FlSpot(1, median!),
      FlSpot(2, max!),
    ];

    return SizedBox(
      height: 160,
      child: LineChart(
        LineChartData(
          backgroundColor: Colors.transparent,
          borderData: FlBorderData(show: false),
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 24,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final label = switch (value.toInt()) {
                    0 => 'Min',
                    1 => 'Median',
                    2 => 'Max',
                    _ => '',
                  };
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      label,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  );
                },
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: points,
              isCurved: true,
              color: AppColors.deepSapphire,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 4,
                    color: AppColors.primaryAction,
                    strokeWidth: 2,
                    strokeColor: AppColors.cloudDancer,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.deepSapphire.withValues(alpha: 0.08),
              ),
            ),
          ],
        ),
        duration: AppMotion.normal,
        curve: AppMotion.curve,
      ),
    );
  }
}
