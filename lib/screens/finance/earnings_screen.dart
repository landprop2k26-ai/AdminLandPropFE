import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/worker_provider.dart';
import '../../constants/colors.dart';

class EarningsScreen extends StatelessWidget {
  const EarningsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final workerProvider = Provider.of<WorkerProvider>(context);
    
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Earnings Dashboard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 32),
          _buildSummaryCards(workerProvider),
          const SizedBox(height: 32),
          const Text('Worker-wise Earnings (Current Month)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: workerProvider.workers.length,
              itemBuilder: (context, index) {
                final worker = workerProvider.workers[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(child: Text(worker.name[0])),
                    title: Text(worker.name),
                    subtitle: Text(worker.roles.join(', ')),
                    trailing: Text('₹${worker.earningsThisMonth}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(WorkerProvider provider) {
    return Row(
      children: [
        _summaryCard('Today', '₹18,400', Colors.blue),
        const SizedBox(width: 20),
        _summaryCard('This Week', '₹96,200', Colors.orange),
        const SizedBox(width: 20),
        _summaryCard('This Month', '₹${provider.totalEarningsMonth}', Colors.green),
      ],
    );
  }

  Widget _summaryCard(String period, String amount, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(period, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(amount, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
