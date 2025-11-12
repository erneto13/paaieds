import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:paaieds/config/app_colors.dart';
import 'package:paaieds/core/models/exercise.dart';
import 'package:paaieds/core/models/roadmap_section.dart';
import 'package:paaieds/ui/widgets/roadmap/roadmap_custom_app_bar.dart';
import 'package:paaieds/util/string_formatter.dart';

class TheoryScreen extends StatefulWidget {
  final RoadmapSection section;
  final TheoryContent theoryContent;
  final VoidCallback onContinue;
  final VoidCallback? onCancel;
  final bool? isReviewOnly;

  const TheoryScreen({
    super.key,
    required this.section,
    required this.theoryContent,
    required this.onContinue,
    this.onCancel,
    this.isReviewOnly,
  });

  @override
  State<TheoryScreen> createState() => _TheoryScreenState();
}

class _TheoryScreenState extends State<TheoryScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToBottom = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_checkScrollPosition);
  }

  void _checkScrollPosition() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.position.pixels;
      if (currentScroll >= maxScroll - 100 && !_hasScrolledToBottom) {
        setState(() => _hasScrolledToBottom = true);
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RoadmapAppBar(
        topic: widget.section.bloomLevel,
        subtopic: 'Teoría: ${widget.section.subtopic}',
        onClose: () => Navigator.pop(context),
      ),
      backgroundColor: const Color(0xFFffffff),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 28),
                  _buildIntroduction(),
                  const SizedBox(height: 32),
                  ..._buildSections(),
                  const SizedBox(height: 32),
                  _buildKeyPoints(),
                  const SizedBox(height: 32),
                  _buildExamples(),
                  const SizedBox(height: 32),
                  _buildScrollIndicator(),
                ],
              ),
            ),
          ),
          _buildBottomBar(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return FadeInDown(
      duration: const Duration(milliseconds: 400),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.backgroundButtom.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.school_rounded,
                  color: AppColors.backgroundButtom,
                  size: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.section.subtopic.toTitleCase(),
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.section.description,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF4B5563),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroduction() {
    return FadeInUp(
      duration: const Duration(milliseconds: 500),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                'Introducción',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            widget.theoryContent.introduction,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF374151),
              height: 1.7,
            ),
            textAlign: TextAlign.justify,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSections() {
    return widget.theoryContent.sections.asMap().entries.map((entry) {
      final index = entry.key;
      final section = entry.value;

      return FadeInUp(
        duration: Duration(milliseconds: 600 + (index * 100)),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 4,
                    height: 24,
                    decoration: BoxDecoration(
                      color: _getSectionColor(index),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),

                  Expanded(
                    child: Text(
                      section.title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: _getSectionColor(index),
                      ),
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      maxLines: null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              Text(
                section.content,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF374151),
                  height: 1.7,
                ),
                textAlign: TextAlign.justify,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildKeyPoints() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Colors.amber[700]!.withValues(alpha: 0.6),
              width: 3,
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline_rounded,
                    color: Colors.amber[700],
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Puntos Clave',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.amber[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ...widget.theoryContent.keyPoints.map((point) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 7),
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.amber[700],
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          point,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF374151),
                            height: 1.6,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExamples() {
    if (widget.theoryContent.examples.isEmpty) return const SizedBox.shrink();

    return FadeInUp(
      duration: const Duration(milliseconds: 900),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.psychology_alt_rounded,
                color: AppColors.primary,
                size: 22,
              ),
              const SizedBox(width: 8),
              const Text(
                'Ejemplos Prácticos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...widget.theoryContent.examples.asMap().entries.map((entry) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ejemplo ${entry.key + 1}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF9FAFB),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF374151),
                        height: 1.6,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildScrollIndicator() {
    if (_hasScrolledToBottom) return const SizedBox.shrink();
    return FadeIn(
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.grey[400],
              size: 30,
            ),
            const SizedBox(height: 4),
            Text(
              'Desliza para ver más',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: widget.onContinue,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.backgroundButtom,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            icon: Icon(
              widget.isReviewOnly == true
                  ? Icons.close
                  : Icons.check_circle_rounded,
              color: Colors.white,
            ),
            label: Text(
              widget.isReviewOnly == true
                  ? 'Cerrar'
                  : 'Entendido, continuar con ejercicios',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getSectionColor(int index) {
    final colors = [
      AppColors.primary,
      AppColors.oceanBlue,
      AppColors.skyBlue,
      AppColors.deepBlue,
    ];
    return colors[index % colors.length];
  }
}
