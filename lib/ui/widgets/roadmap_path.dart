import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:paaieds/core/models/roadmap_section.dart';

class RoadmapPath extends StatelessWidget {
  final List<RoadmapSection> sections;
  final Function(RoadmapSection) onTap;

  const RoadmapPath({super.key, required this.sections, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: sections.length,
      itemBuilder: (context, index) {
        final section = sections[index];
        final isLocked = index > 0 && !sections[index - 1].completed;
        final isEven = index % 2 == 0;

        return FadeInUp(
          duration: Duration(milliseconds: 400 + (index * 100)),
          child: _buildPathNode(
            context,
            section: section,
            index: index,
            isLocked: isLocked,
            isEven: isEven,
            isFirst: index == 0,
            isLast: index == sections.length - 1,
          ),
        );
      },
    );
  }

  Widget _buildPathNode(
    BuildContext context, {
    required RoadmapSection section,
    required int index,
    required bool isLocked,
    required bool isEven,
    required bool isFirst,
    required bool isLast,
  }) {
    return Column(
      children: [
        if (!isFirst)
          _buildConnectorLine(
            isCompleted: sections[index - 1].completed,
            isEven: !isEven,
          ),

        Row(
          mainAxisAlignment: isEven
              ? MainAxisAlignment.start
              : MainAxisAlignment.end,
          children: [
            if (!isEven) const Spacer(),
            _buildSectionNode(context, section, isLocked, isEven),
            if (isEven) const Spacer(),
          ],
        ),

        if (!isLast)
          _buildConnectorLine(isCompleted: section.completed, isEven: isEven),
      ],
    );
  }

  Widget _buildConnectorLine({
    required bool isCompleted,
    required bool isEven,
  }) {
    return Container(
      width: 6,
      height: 40,

      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isCompleted
              ? [Colors.green, Colors.green.withOpacity(0.6)]
              : [Colors.grey.shade300, Colors.grey.shade400],
        ),
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildSectionNode(
    BuildContext context,
    RoadmapSection section,
    bool isLocked,
    bool isEven,
  ) {
    return GestureDetector(
      onTap: isLocked ? null : () => onTap(section),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.75,
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _getGradientColors(section, isLocked),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: _getBloomColor(
                      section.bloomLevel,
                    ).withOpacity(isLocked ? 0.1 : 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(section, isLocked),
                  const SizedBox(height: 12),
                  _buildTitle(section, isLocked),
                  const SizedBox(height: 8),
                  _buildDescription(section, isLocked),
                  const SizedBox(height: 16),
                  _buildMetadata(section, isLocked),
                ],
              ),
            ),

            if (section.completed)
              Positioned(top: -8, right: -8, child: _buildCompleteBadge()),

            Positioned(
              top: -12,
              left: 12,
              child: _buildBloomIcon(section.bloomLevel, isLocked),
            ),

            if (isLocked)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.lock,
                        color: Colors.grey,
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(RoadmapSection section, bool isLocked) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            section.bloomLevel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _getBloomColor(section.bloomLevel),
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildDifficultyBadge(section.baseDifficulty, isLocked),
        const Spacer(),
        if (!isLocked && !section.completed)
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.play_arrow,
              color: _getBloomColor(section.bloomLevel),
              size: 20,
            ),
          ),
      ],
    );
  }

  Widget _buildTitle(RoadmapSection section, bool isLocked) {
    return Text(
      section.subtopic,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: isLocked ? Colors.white.withOpacity(0.6) : Colors.white,
        height: 1.2,
      ),
    );
  }

  Widget _buildDescription(RoadmapSection section, bool isLocked) {
    return Text(
      section.description,
      style: TextStyle(
        fontSize: 14,
        color: isLocked
            ? Colors.white.withOpacity(0.5)
            : Colors.white.withOpacity(0.9),
        height: 1.4,
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildMetadata(RoadmapSection section, bool isLocked) {
    return Row(
      children: [
        _buildMetadataChip(
          icon: Icons.checklist,
          label: '${section.objectives.length} objetivos',
          isLocked: isLocked,
        ),
        const SizedBox(width: 8),
        if (section.finalTheta != null)
          _buildMetadataChip(
            icon: Icons.analytics,
            label: 'θ: ${section.finalTheta!.toStringAsFixed(2)}',
            isLocked: isLocked,
          ),
      ],
    );
  }

  Widget _buildMetadataChip({
    required IconData icon,
    required String label,
    required bool isLocked,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(isLocked ? 0.3 : 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: Colors.white.withOpacity(isLocked ? 0.6 : 0.9),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(isLocked ? 0.6 : 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyBadge(String difficulty, bool isLocked) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.signal_cellular_alt,
            size: 12,
            color: _getDifficultyColor(difficulty),
          ),
          const SizedBox(width: 4),
          Text(
            _formatDifficulty(difficulty),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: _getDifficultyColor(difficulty),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteBadge() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF10B981), Color(0xFF059669)],
        ),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Icon(Icons.check, color: Colors.white, size: 20),
    );
  }

  Widget _buildBloomIcon(String bloomLevel, bool isLocked) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: _getBloomColor(bloomLevel).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        _getBloomIcon(bloomLevel),
        color: _getBloomColor(bloomLevel),
        size: 20,
      ),
    );
  }

  List<Color> _getGradientColors(RoadmapSection section, bool isLocked) {
    if (isLocked) {
      return [Colors.grey.shade400, Colors.grey.shade500];
    }

    if (section.completed) {
      return [const Color(0xFF10B981), const Color(0xFF059669)];
    }

    final baseColor = _getBloomColor(section.bloomLevel);
    return [baseColor, Color.lerp(baseColor, Colors.black, 0.2)!];
  }

  Color _getBloomColor(String bloomLevel) {
    switch (bloomLevel.toLowerCase()) {
      case 'remember':
      case 'recordar':
        return const Color(0xFF3B82F6);
      case 'understand':
      case 'comprender':
        return const Color(0xFF06B6D4);
      case 'apply':
      case 'aplicar':
        return const Color(0xFF10B981);
      case 'analyze':
      case 'analizar':
        return const Color(0xFFF97316);
      case 'evaluate':
      case 'evaluar':
        return const Color(0xFFEF4444);
      case 'create':
      case 'crear':
        return const Color(0xFF8B5CF6);
      default:
        return Colors.grey;
    }
  }

  IconData _getBloomIcon(String bloomLevel) {
    switch (bloomLevel.toLowerCase()) {
      case 'remember':
      case 'recordar':
        return Icons.lightbulb_outline;
      case 'understand':
      case 'comprender':
        return Icons.psychology;
      case 'apply':
      case 'aplicar':
        return Icons.build;
      case 'analyze':
      case 'analizar':
        return Icons.analytics;
      case 'evaluate':
      case 'evaluar':
        return Icons.rate_review;
      case 'create':
      case 'crear':
        return Icons.auto_awesome;
      default:
        return Icons.circle;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'low':
      case 'baja':
        return const Color(0xFF10B981);
      case 'medium':
      case 'media':
        return const Color(0xFFF59E0B);
      case 'high':
      case 'alta':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  String _formatDifficulty(String difficulty) {
    return difficulty[0].toUpperCase() + difficulty.substring(1).toLowerCase();
  }
}
