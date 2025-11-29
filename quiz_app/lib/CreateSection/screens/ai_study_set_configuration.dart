import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quiz_app/CreateSection/providers/ai_study_set_provider.dart';
import 'package:quiz_app/CreateSection/screens/ai_generation_progress.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';

class AIStudySetConfiguration extends ConsumerStatefulWidget {
  const AIStudySetConfiguration({super.key});

  @override
  ConsumerState<AIStudySetConfiguration> createState() =>
      _AIStudySetConfigurationState();
}

class _AIStudySetConfigurationState
    extends ConsumerState<AIStudySetConfiguration> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedCategory = '';
  String _selectedLanguage = '';

  final List<String> _categories = [
    'Science',
    'Mathematics',
    'History',
    'Geography',
    'Literature',
    'Technology',
    'Business',
    'Arts',
    'Medicine',
    'Engineering',
    'Law',
    'Other',
  ];

  final List<String> _languages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Chinese',
    'Japanese',
    'Hindi',
    'Arabic',
    'Portuguese',
    'Russian',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
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

          // Just add file to pending list (don't upload yet)
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
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _startGeneration() {
    // Settings are already stored in the provider state via sliders
    // Just navigate to progress screen
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
      appBar: AppBar(
        title: const Text(
          'AI Study Set Generator',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Upload Section
            _buildSectionTitle('Upload Documents', Icons.upload_file),
            const SizedBox(height: 12),
            Text(
              'Upload up to 3 documents (PDF, PPT, DOC, TXT) - Max 10MB each',
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // File Upload Slots
            ...List.generate(3, (index) {
              if (index < state.pendingFiles.length) {
                return _buildPendingFileCard(
                  state.pendingFiles[index],
                  index,
                  notifier,
                );
              }
              return _buildEmptyFileSlot(index + 1);
            }),

            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: state.pendingFiles.length < 3 ? _pickFiles : null,
                icon: const Icon(Icons.add),
                label: const Text('Add Documents'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // AI Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.deepPurple.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: Colors.deepPurple, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'AI will automatically generate study set name, description, categories, and language based on your document content!',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Generation Settings
            _buildSectionTitle('Generation Settings', Icons.settings),
            const SizedBox(height: 16),

            _buildSliderSetting(
              'Number of Quizzes',
              state.settings.quizCount.toDouble(),
              1,
              5,
              (value) => notifier.updateSettings(quizCount: value.toInt()),
            ),

            _buildSliderSetting(
              'Number of Flashcard Sets',
              state.settings.flashcardSetCount.toDouble(),
              1,
              3,
              (value) =>
                  notifier.updateSettings(flashcardSetCount: value.toInt()),
            ),

            _buildSliderSetting(
              'Number of Notes',
              state.settings.noteCount.toDouble(),
              1,
              3,
              (value) => notifier.updateSettings(noteCount: value.toInt()),
            ),

            _buildSliderSetting(
              'Questions per Quiz',
              state.settings.questionsPerQuiz.toDouble(),
              5,
              20,
              (value) =>
                  notifier.updateSettings(questionsPerQuiz: value.toInt()),
              divisions: 15,
            ),

            _buildSliderSetting(
              'Cards per Flashcard Set',
              state.settings.cardsPerSet.toDouble(),
              10,
              50,
              (value) => notifier.updateSettings(cardsPerSet: value.toInt()),
              divisions: 40,
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: state.settings.difficulty,
              decoration: InputDecoration(
                labelText: 'Difficulty Level',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: AppColors.surface,
              ),
              items:
                  ['Easy', 'Medium', 'Hard', 'Mixed'].map((difficulty) {
                    return DropdownMenuItem(
                      value: difficulty,
                      child: Text(difficulty),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  notifier.updateSettings(difficulty: value);
                }
              },
            ),

            const SizedBox(height: 32),

            // Generate Button
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: state.canGenerate ? _startGeneration : null,
                icon: const Icon(Icons.auto_awesome, size: 24),
                label: const Text(
                  'Generate Study Set',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyFileSlot(int slotNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.3),
          width: 2,
          style: BorderStyle.solid,
        ),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.surface.withOpacity(0.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.textSecondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.upload_file,
              color: AppColors.textSecondary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Document Slot $slotNumber (Empty)',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingFileCard(
    File file,
    int index,
    AIStudySetNotifier notifier,
  ) {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final fileSizeBytes = file.lengthSync();
    final fileSizeMB = (fileSizeBytes / (1024 * 1024)).toStringAsFixed(2);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.description_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fileName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$fileSizeMB MB',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => notifier.removeFile(index),
            icon: Icon(Icons.close, color: Colors.red[400], size: 20),
            constraints: const BoxConstraints(),
            padding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildUploadedFileCard(
    dynamic file,
    int index,
    AIStudySetNotifier notifier,
  ) {
    final fileSizeMB = (file.fileSize / (1024 * 1024)).toStringAsFixed(2);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.check_circle, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  file.fileName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$fileSizeMB MB',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => notifier.removeFile(index),
            icon: const Icon(Icons.close, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildSliderSetting(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged, {
    int? divisions,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value.toInt().toString(),
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions ?? (max - min).toInt(),
          activeColor: AppColors.primary,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
