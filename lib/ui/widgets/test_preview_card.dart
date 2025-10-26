import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/providers/test_provider.dart';
import 'package:paaieds/util/string_formatter.dart';
import 'package:provider/provider.dart';

class TestPreviewCard extends StatelessWidget {
  final VoidCallback onStartTest;

  const TestPreviewCard({super.key, required this.onStartTest});

  @override
  Widget build(BuildContext context) {
    return Consumer<TestProvider>(
      builder: (context, testProvider, child) {
        if (testProvider.questions.isEmpty) {
          return const SizedBox.shrink();
        }

        return FadeInUp(
          duration: const Duration(milliseconds: 700),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.backgroundButtom, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.lightBlue.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, testProvider),
                const SizedBox(height: 12),
                _buildQuestionCount(testProvider),
                const SizedBox(height: 16),
                _buildDivider(),
                const SizedBox(height: 16),
                _buildQuestionPreview(testProvider),
                const SizedBox(height: 20),
                _buildStartButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, TestProvider testProvider) {
    return Row(
      children: [
        const Icon(Icons.quiz, color: Colors.white, size: 28),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            testProvider.currentTopic?.toTitleCase() ?? 'Test Generado',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        IconButton(
          onPressed: () => testProvider.reset(),
          icon: const Icon(Icons.close, color: Colors.white70, size: 24),
          tooltip: 'Cancelar test',
        ),
      ],
    );
  }

  Widget _buildQuestionCount(TestProvider testProvider) {
    return Row(
      children: [
        const Icon(Icons.help_outline, color: Colors.white70, size: 18),
        const SizedBox(width: 6),
        Text(
          '${testProvider.questions.length} preguntas',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 1, color: Colors.white.withValues(alpha: 0.2));
  }

  Widget _buildQuestionPreview(TestProvider testProvider) {
    final previewQuestions = testProvider.questions.take(3).toList();

    return Column(
      children: [
        ...previewQuestions.asMap().entries.map((entry) {
          final index = entry.key;
          final question = entry.value;

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.question,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }),
        if (testProvider.questions.length > 3)
          Padding(
            padding: const EdgeInsets.only(left: 36),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '...y ${testProvider.questions.length - 3} preguntas más',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: onStartTest,
        icon: const Icon(
          Icons.play_arrow_rounded,
          color: AppColors.backgroundButtom,
          size: 28,
        ),
        label: const Text(
          "Comenzar Test",
          style: TextStyle(
            color: AppColors.backgroundButtom,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}
