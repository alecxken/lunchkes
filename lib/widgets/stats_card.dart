// lib/widgets/stats_card.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/lunch_provider.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LunchProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatItem(label: 'Staff', value: provider.summary['staff'] ?? 0),
              _StatItem(
                label: 'Contract',
                value: provider.summary['contract'] ?? 0,
              ),
              _StatItem(
                label: 'Visitors',
                value: provider.summary['visitor'] ?? 0,
              ),
              _StatItem(label: 'Total', value: provider.total, isTotal: true),
            ],
          ),
        );
      },
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  final bool isTotal;

  const _StatItem({
    required this.label,
    required this.value,
    this.isTotal = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: isTotal ? 22 : 20,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFBED600),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
