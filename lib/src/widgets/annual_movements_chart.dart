import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/models/deposit.dart';
import 'package:intl/intl.dart';

class AnnualMovementsChart extends StatelessWidget {
  final List<Deposit> deposits;
  const AnnualMovementsChart({super.key, required this.deposits});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final year = now.year;
    // Grouper les montants par mois (entrées/sorties)
    final List<double> monthlyIn = List.filled(12, 0);
    final List<double> monthlyOut = List.filled(12, 0);
    for (final d in deposits) {
      if (d.creationDate.year == year) {
        final m = d.creationDate.month - 1;
        if (d.amount >= 0) {
          monthlyIn[m] += d.amount;
        } else {
          monthlyOut[m] += d.amount.abs();
        }
      }
    }
    final maxY = [
      ...monthlyIn,
      ...monthlyOut
    ].fold<double>(0, (prev, e) => e > prev ? e : prev) * 1.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Répartition annuelle des mouvements',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxY == 0 ? 100 : maxY,
                  minY: 0,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          if (value < 0 || value > 11) return const Text('');
                          return Text(DateFormat('MMM').format(DateTime(year, value.toInt() + 1)), style: const TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
                      ),
                    ),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(12, (i) => BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: monthlyIn[i],
                        color: Colors.green,
                        width: 10,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                      BarChartRodData(
                        toY: monthlyOut[i],
                        color: Colors.red,
                        width: 10,
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      ),
                    ],
                  )),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Entrées', Colors.green),
                const SizedBox(width: 24),
                _buildLegendItem('Sorties', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
} 