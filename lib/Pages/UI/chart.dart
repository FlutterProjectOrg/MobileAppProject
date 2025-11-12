import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart' as fl_chart;
import 'package:mobile_app_project/Pages/UI/AppColors.dart';

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
  final List<fl_chart.FlSpot> data;
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
    return fl_chart.LineChart(
      fl_chart.LineChartData(
        lineBarsData: [
          fl_chart.LineChartBarData(
            spots: data,
            color: config.items.values.first.color ?? Colors.blue,
            isCurved: true,
            dotData: fl_chart.FlDotData(show: true),
            barWidth: 2,
          ),
        ],
        titlesData: fl_chart.FlTitlesData(
          bottomTitles: fl_chart.AxisTitles(
            sideTitles: fl_chart.SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) => Text(
                labelFormatter?.call(value) ?? value.toString(),
                style: const TextStyle(fontSize: 10),
              ),
            ),
          ),
          leftTitles: fl_chart.AxisTitles(
            sideTitles: fl_chart.SideTitles(showTitles: true),
          ),
        ),
        gridData: fl_chart.FlGridData(show: true),
        borderData: fl_chart.FlBorderData(show: false),
        lineTouchData: showTooltip
            ? fl_chart.LineTouchData(
                touchTooltipData: fl_chart.LineTouchTooltipData(
                  tooltipBgColor: Theme.of(context).colorScheme.surface,
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final item = config.items.entries.first.value;
                      return fl_chart.LineTooltipItem(
                        '${labelFormatter?.call(spot.x) ?? spot.x}\n${spot.y}',
                        TextStyle(color: item.color ?? Colors.blue),
                      );
                    }).toList();
                  },
                ),
              )
            : fl_chart.LineTouchData(enabled: false),
      ),
    );
  }
}

class BarChart extends StatelessWidget {
  final List<ChartData> data;
  final String? title;
  final double height;
  final bool showValues;

  const BarChart({
    Key? key,
    required this.data,
    this.title,
    this.height = 200,
    this.showValues = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryOrange.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            height: height,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((item) {
                final heightRatio = item.value / maxValue;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (showValues)
                          Text(
                            item.value.toStringAsFixed(0),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryOrange,
                            ),
                          ),
                        const SizedBox(height: 4),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              width: double.infinity,
                              height: height * heightRatio * 0.8,
                              decoration: BoxDecoration(
                                gradient: AppColors.gradientPrimary,
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(8),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primaryOrange.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item.label,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class LineChart extends StatelessWidget {
  final List<ChartData> data;
  final String? title;
  final double height;

  const LineChart({Key? key, required this.data, this.title, this.height = 200})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    final maxValue = data.map((d) => d.value).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryOrange.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryOrange.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
          ],
          SizedBox(
            height: height,
            child: CustomPaint(
              painter: _LineChartPainter(data: data, maxValue: maxValue),
              child: Container(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: data.map((item) {
              return Text(
                item.label,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<ChartData> data;
  final double maxValue;

  _LineChartPainter({required this.data, required this.maxValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = AppColors.gradientPrimary.createShader(
        Rect.fromLTWH(0, 0, size.width, size.height),
      )
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final points = <Offset>[];

    for (int i = 0; i < data.length; i++) {
      final x = (size.width / (data.length - 1)) * i;
      final y = size.height - (data[i].value / maxValue * size.height);
      points.add(Offset(x, y));

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    final pointPaint = Paint()
      ..color = AppColors.primaryOrange
      ..style = PaintingStyle.fill;

    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
      canvas.drawCircle(
        point,
        6,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class ChartData {
  final String label;
  final double value;

  ChartData({required this.label, required this.value});
}
