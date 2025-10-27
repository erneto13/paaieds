import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/models/test_results.dart';
import 'package:paaieds/core/providers/history_provider.dart';
import 'package:paaieds/ui/widgets/test/test_details_modal.dart';
import 'package:paaieds/ui/widgets/test/test_history_card.dart';
import 'package:provider/provider.dart';

class TestHistorySection extends StatelessWidget {
  const TestHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<HistoryProvider>(
      builder: (context, historyProvider, child) {
        if (historyProvider.isLoading) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (historyProvider.testHistory.isEmpty) {
          return _buildEmptyState();
        }

        return _buildHistoryList(historyProvider);
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 48, color: Colors.blueGrey[400]),
          const SizedBox(height: 12),
          Text(
            "Aún no has realizado ningún test",
            style: TextStyle(
              color: Colors.blueGrey[400],
              fontSize: 16,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Genera y completa tu primer test",
            style: TextStyle(color: Colors.blueGrey[300], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(HistoryProvider historyProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Historial de Tests',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.deepBlue,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.backgroundButtom.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${historyProvider.testHistory.length}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.backgroundButtom,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: historyProvider.testHistory.length,
          itemBuilder: (context, index) {
            final result = historyProvider.testHistory[index];
            return FadeInUp(
              duration: Duration(milliseconds: 400 + (index * 100)),
              child: TestHistoryCard(
                result: result,
                onTap: () => _showTestDetails(context, result),
              ),
            );
          },
        ),
      ],
    );
  }

  void _showTestDetails(BuildContext context, TestResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TestDetailsModal(result: result),
    );
  }
}
