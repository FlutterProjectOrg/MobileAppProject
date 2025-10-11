import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

typedef ChartLabelFormatter = String Function(double value);

class ChartConfigItem {
  final String? label;
  final Color? color;

  ChartConfigItem({this.label, this.color});
}

class ChartConfig {
  final Map<String, ChartConfigItem> items;

  ChartConfig(this.items);
}

class ChartContainer extends StatelessWidget {
  final ChartConfig config;
  final Widget child;
  final double height;

  const ChartContainer({
    Key? key,
    required this.config,
    required this.child,
    this.height = 300,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: child,
    );
  }
}

class ChartLegend extends StatelessWidget {
  final ChartConfig config;
  final bool hideIcon;

  const ChartLegend({Key? key, required this.config, this.hideIcon = false})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      children: config.items.entries.map((entry) {
        final item = entry.value;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!hideIcon)
              Container(
                width: 12,
                height: 12,
                color: item.color ?? Colors.blue,
                margin: const EdgeInsets.only(right: 4),
              ),
            if (item.label != null)
              Text(item.label!, style: const TextStyle(fontSize: 12)),
          ],
        );
      }).toList(),
    );
  }
}

class LineChartWidget extends StatelessWidget {
  final ChartConfig config;
  final List<FlSpot> data;
  final bool showTooltip;
  final ChartLabelFormatter? labelFormatter;

  const LineChartWidget({
    Key? key,
    required this.config,
    required this.data,
    this.showTooltip = true,
    this.labelFormatter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: data,
            color: config.items.values.first.color ?? Colors.blue,
            isCurved: true,
            dotData: FlDotData(show: true),
            barWidth: 2,
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                labelFormatter?.call(value) ?? value.toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
        lineTouchData: showTooltip
            ? LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Theme.of(context).colorScheme.surface,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final item = config.items.entries.first.value;
                      return LineTooltipItem(
                        '${labelFormatter?.call(spot.x) ?? spot.x}\n${spot.y}',
                        TextStyle(color: item.color ?? Colors.blue),
                      );
                    }).toList();
                  },
                ),
              )
            : LineTouchData(enabled: false),
      ),
    );
  }
}
