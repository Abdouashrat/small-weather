import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class WeatherForecast extends StatelessWidget {
  const WeatherForecast(
      {super.key, required this.times, required this.temperatures});
  final List<String> times;
  final List<int> temperatures;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Time and Temperature Description Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(times.length, (index) {
                return Column(
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      times[index],
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${temperatures[index]}°',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ],
                );
              }),
            ),
            const SizedBox(height: 16),
            // Line Chart
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 10),
              height: 100,
              width: 354,
              child: LineChart(
                LineChartData(
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(
                        temperatures.length,
                        (index) => FlSpot(
                          index.toDouble(),
                          temperatures[index].toDouble(),
                        ),
                      ),
                      isCurved: true,
                      color: Colors.white,
                      barWidth: 3,
                      dotData: const FlDotData(
                        show: true,
                      ),
                      belowBarData: BarAreaData(show: true),
                    ),
                  ],
                  titlesData: const FlTitlesData(show: false),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: temperatures.length - 1.toDouble(),
                  minY:
                      temperatures.reduce((a, b) => a < b ? a : b).toDouble() -
                          1,
                  maxY:
                      temperatures.reduce((a, b) => a > b ? a : b).toDouble() +
                          1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
