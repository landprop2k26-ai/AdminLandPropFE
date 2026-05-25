import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../constants/colors.dart';

class AnalysisScreen extends StatelessWidget {
  const AnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Performance Analysis', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _buildChartCard('Monthly Revenue', _buildLineChart()),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: _buildChartCard('Service Distribution', _buildPieChart()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(String title, Widget chart) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          Expanded(child: chart),
        ],
      ),
    );
  }

  Widget _buildLineChart() {
    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: true),
        titlesData: const FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: [
              const FlSpot(0, 3),
              const FlSpot(2, 2),
              const FlSpot(4, 5),
              const FlSpot(6, 3.1),
              const FlSpot(8, 4),
              const FlSpot(10, 3),
              const FlSpot(12, 7),
            ],
            isCurved: true,
            color: AppColors.accent,
            barWidth: 4,
            belowBarData: BarAreaData(show: true, color: AppColors.accent.withOpacity(0.1)),
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    return PieChart(
      PieChartData(
        sections: [
          PieChartSectionData(value: 40, color: Colors.blue, title: 'Electrician', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 10)),
          PieChartSectionData(value: 30, color: Colors.green, title: 'Plumbing', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 10)),
          PieChartSectionData(value: 15, color: Colors.orange, title: 'Carpentry', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 10)),
          PieChartSectionData(value: 15, color: Colors.red, title: 'Painting', radius: 50, titleStyle: const TextStyle(color: Colors.white, fontSize: 10)),
        ],
      ),
    );
  }
}
