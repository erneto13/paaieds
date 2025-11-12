import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:paaieds/core/models/forum_post.dart';
import 'package:paaieds/core/models/roadmap_section.dart';
import 'package:paaieds/core/providers/auth_provider.dart';
import 'package:paaieds/core/providers/roadmap_provider.dart';
import 'package:provider/provider.dart';

class RoadmapAttachmentDetail extends StatelessWidget {
  final PostAttachment attachment;

  const RoadmapAttachmentDetail({super.key, required this.attachment});

  @override
  Widget build(BuildContext context) {
    final roadmapId = attachment.id;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final roadmapProvider = Provider.of<RoadmapProvider>(context);

    if (roadmapProvider.currentRoadmap?.id != roadmapId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        roadmapProvider.loadRoadmap(
          userId: authProvider.currentUser!.uid,
          roadmapId: roadmapId,
        );
      });
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detalles del Roadmap',
          style: TextStyle(color: Colors.grey[800], fontSize: 18),
        ),
      ),
      body: roadmapProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : roadmapProvider.currentRoadmap == null
          ? _buildErrorState()
          : _buildRoadmapContent(roadmapProvider.currentRoadmap!),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No se pudo cargar el roadmap',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildRoadmapContent(Roadmap roadmap) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeInDown(child: _buildHeader(roadmap)),
          const SizedBox(height: 24),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildProgressCard(roadmap),
          ),
          const SizedBox(height: 24),
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: _buildSectionsList(roadmap),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Roadmap roadmap) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade600],
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
              Icon(Icons.map, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  roadmap.topic,
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
              'Nivel: ${roadmap.level}',
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

  Widget _buildProgressCard(Roadmap roadmap) {
    final progress = roadmap.progressPercentage;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progreso General',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              Text(
                '${progress.toInt()}%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress / 100,
              minHeight: 10,
              backgroundColor: Colors.white,
              valueColor: AlwaysStoppedAnimation(Colors.blue.shade600),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatItem(
                'Completadas',
                '${roadmap.completedSections}',
                Colors.green,
              ),
              const SizedBox(width: 20),
              _buildStatItem('Total', '${roadmap.totalSections}', Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionsList(Roadmap roadmap) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Secciones (${roadmap.sections.length})',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 16),
        ...roadmap.sections.asMap().entries.map((entry) {
          final index = entry.key;
          final section = entry.value;
          return FadeInUp(
            delay: Duration(milliseconds: 400 + (index * 50)),
            child: _buildSectionCard(section, index),
          );
        }),
      ],
    );
  }

  Widget _buildSectionCard(RoadmapSection section, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: section.completed
              ? Colors.green.shade300
              : Colors.grey.shade300,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: section.completed
                      ? Colors.green.shade100
                      : Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: section.completed
                      ? Icon(
                          Icons.check,
                          color: Colors.green.shade700,
                          size: 18,
                        )
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.subtopic,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      section.bloomLevel,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            section.description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class RoadmapSectionAttachmentDetail extends StatelessWidget {
  final PostAttachment attachment;

  const RoadmapSectionAttachmentDetail({super.key, required this.attachment});

  @override
  Widget build(BuildContext context) {
    final metadata = attachment.metadata!;
    final subtopic = metadata['subtopic'] as String;
    final bloomLevel = metadata['bloomLevel'] as String;
    final description = metadata['description'] as String;
    final roadmapTopic = metadata['roadmapTopic'] as String;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: Colors.grey[800]),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Detalles de la Sección',
          style: TextStyle(color: Colors.grey[800], fontSize: 18),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeInDown(child: _buildHeader(subtopic, bloomLevel, roadmapTopic)),
            const SizedBox(height: 24),
            FadeInUp(
              delay: const Duration(milliseconds: 200),
              child: _buildDescriptionCard(description),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String subtopic, String bloomLevel, String roadmapTopic) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo.shade400, Colors.indigo.shade600],
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
              Icon(Icons.bookmark, color: Colors.white, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  subtopic,
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
              bloomLevel,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.map_outlined, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Roadmap: $roadmapTopic',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(String description) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.indigo.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.indigo.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Descripción',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
