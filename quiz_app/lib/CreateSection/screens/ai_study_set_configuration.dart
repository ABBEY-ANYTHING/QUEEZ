import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/CreateSection/providers/ai_study_set_provider.dart';
import 'package:quiz_app/CreateSection/screens/ai_generation_progress.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/globals.dart';
import 'package:quiz_app/widgets/appbar/universal_appbar.dart';

class AIStudySetConfiguration extends ConsumerStatefulWidget {
  const AIStudySetConfiguration({super.key});

  @override
  ConsumerState<AIStudySetConfiguration> createState() =>
      _AIStudySetConfigurationState();
}

class _AIStudySetConfigurationState
    extends ConsumerState<AIStudySetConfiguration> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final notifier = ref.read(aiStudySetProvider.notifier);
    final state = ref.read(aiStudySetProvider);

    if (state.pendingFiles.length >= 3) {
      _showError('Maximum 3 files allowed');
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'ppt', 'pptx', 'doc', 'docx', 'txt'],
        allowMultiple: true,
      );

      if (result != null) {
        for (final platformFile in result.files) {
          if (ref.read(aiStudySetProvider).pendingFiles.length >= 3) {
            _showError('Maximum 3 files reached');
            break;
          }

          if (platformFile.size > 10 * 1024 * 1024) {
            _showError('File ${platformFile.name} exceeds 10MB limit');
            continue;
          }

          if (platformFile.path == null) {
            _showError('Could not access file ${platformFile.name}');
            continue;
          }

          notifier.addPendingFile(File(platformFile.path!));
        }
      }
    } catch (e) {
      _showError('File picker error: ${e.toString()}');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _startGeneration() {
    Navigator.push(
      context,
      customRoute(const AIGenerationProgress(), AnimationType.slideUp),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aiStudySetProvider);
    final notifier = ref.read(aiStudySetProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const UniversalAppBar(title: 'AI Configuration'),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: EdgeInsets.fromLTRB(24, 10, 24, kBottomNavbarHeight + 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 32),
            _buildSectionTitle('Upload Documents', Icons.cloud_upload_outlined),
            const SizedBox(height: 16),
            _buildUploadSection(state, notifier),
            const SizedBox(height: 24),
            _buildAIInfoBox(),
            const SizedBox(height: 32),
            // Generate Button - now part of scrollable content
            _buildGenerateButton(state),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surface),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.auto_awesome, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AI Assistant',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Upload documents and let AI craft your perfect study set.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 22),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildUploadSection(
    AIStudySetState state,
    AIStudySetNotifier notifier,
  ) {
    return Column(
      children: [
        ...List.generate(3, (index) {
          if (index < state.pendingFiles.length) {
            return _buildFileCard(state.pendingFiles[index], index, notifier);
          }
          return const SizedBox.shrink();
        }),
        if (state.pendingFiles.length < 3)
          _buildAddFileButton(state.pendingFiles.length),
        if (state.pendingFiles.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Text(
              '${state.pendingFiles.length}/3 files selected',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFileCard(File file, int index, AIStudySetNotifier notifier) {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final size = (file.lengthSync() / (1024 * 1024)).toStringAsFixed(2);
    final isPdf = fileName.toLowerCase().endsWith('.pdf');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.surface),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isPdf
                ? Colors.red.withValues(alpha: 0.1)
                : Colors.blue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            isPdf ? Icons.picture_as_pdf : Icons.description,
            color: isPdf ? Colors.red : Colors.blue,
            size: 24,
          ),
        ),
        title: Text(
          fileName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          '$size MB',
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close, size: 20),
          color: AppColors.textSecondary,
          onPressed: () => notifier.removeFile(index),
        ),
      ),
    );
  }

  Widget _buildAddFileButton(int currentCount) {
    return InkWell(
      onTap: _pickFiles,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.surface.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.primary.withValues(alpha: 0.2),
            style: BorderStyle.solid,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline_rounded,
              color: AppColors.primary,
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Add Document ${currentCount + 1}',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIInfoBox() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.auto_awesome, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
          
            child: Text(
              'AI will analyze your documents and automatically create the optimal number of quizzes, flashcards, and notes.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenerateButton(AIStudySetState state) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!state.canGenerate)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Upload at least 1 document to continue',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: state.canGenerate ? _startGeneration : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 18),
              elevation: state.canGenerate ? 8 : 2,
              shadowColor: AppColors.primary.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              disabledBackgroundColor: Colors.grey[300],
              disabledForegroundColor: Colors.grey[600],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, size: 22),
                const SizedBox(width: 12),
                const Text(
                  'Generate Study Set',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
