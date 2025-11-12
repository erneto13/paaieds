import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:paaieds/core/models/forum_post.dart';
import 'package:paaieds/core/models/test_results.dart';
import 'package:paaieds/core/providers/auth_provider.dart';
import 'package:paaieds/core/providers/history_provider.dart';
import 'package:paaieds/ui/widgets/util/custom_app_bar.dart';
import 'package:provider/provider.dart';

class TestAttachmentDetail extends StatefulWidget {
  final PostAttachment attachment;

  const TestAttachmentDetail({super.key, required this.attachment});

  @override
  State<TestAttachmentDetail> createState() => _TestAttachmentDetailState();
}

class _TestAttachmentDetailState extends State<TestAttachmentDetail> {
  TestResult? _testResult;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTestData();
  }

  Future<void> _loadTestData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final historyProvider = Provider.of<HistoryProvider>(
      context,
      listen: false,
    );

    await historyProvider.loadTestHistory(authProvider.currentUser!.uid);

    final test = historyProvider.testHistory.firstWhere(
      (t) => t.id == widget.attachment.id,
      orElse: () => TestResult(
        id: '',
        topic: '',
        level: '',
        theta: 0,
        percentage: 0,
        correctAnswers: 0,
        totalQuestions: 0,
        completedAt: widget.attachment.metadata?['completedAt'],
      ),
    );

    setState(() {
      _testResult = test.id.isNotEmpty ? test : null;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Detalles del Test',
        customIcon: Icons.arrow_back,
        onCustomIconTap: () => Navigator.pop(context),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _testResult == null
          ? _buildFallbackContent()
          : _buildTestContent(),
    );
  }

  Widget _buildFallbackContent() {
    final metadata = widget.attachment.metadata!;
    final topic = widget.attachment.title;
    final level = metadata['level'] as String;
    final percentage = metadata['percentage'] as double;
    final correctAnswers = metadata['correctAnswers'] as int;
    final totalQuestions = metadata['totalQuestions'] as int;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(child: _buildHeaderFromMetadata(topic, level)),
          const SizedBox(height: 24),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildStatsFromMetadata(
              level,
              percentage,
              correctAnswers,
              totalQuestions,
            ),
          ),
          const SizedBox(height: 24),
          _buildNoQuestionsMessage(),
        ],
      ),
    );
  }

  Widget _buildTestContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(child: _buildHeader(_testResult!)),
          const SizedBox(height: 24),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildStatsCard(_testResult!),
          ),
          const SizedBox(height: 24),
          if (_testResult!.questions != null &&
              _testResult!.questions!.isNotEmpty) ...[
            FadeInUp(
              delay: const Duration(milliseconds: 300),
              child: _buildQuestionsSection(_testResult!),
            ),
          ] else
            _buildNoQuestionsMessage(),
        ],
      ),
    );
  }

  Widget _buildHeader(TestResult result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.quiz, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  result.topic,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Nivel: ${result.level}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderFromMetadata(String topic, String level) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.quiz, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  topic,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Nivel: $level',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(TestResult result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Dominio',
                  '${result.percentage.toInt()}%',
                  Icons.percent,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Correctas',
                  '${result.correctAnswers}/${result.totalQuestions}',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsFromMetadata(
    String level,
    double percentage,
    int correctAnswers,
    int totalQuestions,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Dominio',
                  '${percentage.toInt()}%',
                  Icons.percent,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Correctas',
                  '$correctAnswers/$totalQuestions',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildQuestionsSection(TestResult result) {
    final incorrectQuestions = result.getIncorrectAnswers();
    final correctQuestions = result.getCorrectAnswers();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Preguntas del Test',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        if (incorrectQuestions.isNotEmpty) ...[
          Text(
            'Incorrectas (${incorrectQuestions.length})',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.red[700],
            ),
          ),
          const SizedBox(height: 12),
          ...incorrectQuestions.asMap().entries.map((entry) {
            return _buildQuestionCard(entry.value, entry.key + 1, false);
          }),
          const SizedBox(height: 24),
        ],
        if (correctQuestions.isNotEmpty) ...[
          Text(
            'Correctas (${correctQuestions.length})',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Colors.green[700],
            ),
          ),
          const SizedBox(height: 12),
          ...correctQuestions.asMap().entries.map((entry) {
            return _buildQuestionCard(entry.value, entry.key + 1, true);
          }),
        ],
      ],
    );
  }

  Widget _buildQuestionCard(
    QuestionDetail question,
    int number,
    bool isCorrect,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.green.withValues(alpha: 0.05)
            : Colors.red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect
              ? Colors.green.withValues(alpha: 0.3)
              : Colors.red.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: isCorrect
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isCorrect ? Colors.green[700] : Colors.red[700],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  question.question,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildAnswerRow(
            'Tu respuesta:',
            question.userAnswer,
            isCorrect ? Colors.green : Colors.red,
            isCorrect ? Icons.check : Icons.close,
          ),
          if (!isCorrect) ...[
            const SizedBox(height: 8),
            _buildAnswerRow(
              'Respuesta correcta:',
              question.correctAnswer,
              Colors.green,
              Icons.check,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAnswerRow(
    String label,
    String answer,
    Color color,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              children: [
                TextSpan(
                  text: '$label ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: answer),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoQuestionsMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Las preguntas de este test no están disponibles',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
