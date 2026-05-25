import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final bool isPositive;

  const StatCard({
    super.key,
    required this.title,
    required this.value,
    required this.trend,
    this.isPositive = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          Text(
            trend,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isPositive ? Colors.green : Colors.red,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
