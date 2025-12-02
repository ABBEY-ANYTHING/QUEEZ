import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/screens/study_set_dashboard.dart';
import 'package:quiz_app/CreateSection/services/image_picker_service.dart';
import 'package:quiz_app/CreateSection/services/study_set_cache_manager.dart';
import 'package:quiz_app/CreateSection/widgets/custom_dropdown.dart';
import 'package:quiz_app/CreateSection/widgets/custom_text_field.dart';
import 'package:quiz_app/CreateSection/widgets/image_picker.dart';
import 'package:quiz_app/CreateSection/widgets/primary_button.dart';
import 'package:quiz_app/CreateSection/widgets/section_title.dart';
import 'package:quiz_app/utils/animations/page_transition.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/globals.dart';

class StudySetDetails extends StatefulWidget {
  const StudySetDetails({super.key});

  @override
  StudySetDetailsState createState() => StudySetDetailsState();
}

class StudySetDetailsState extends State<StudySetDetails> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedTag;
  String? _selectedLanguage;
  String? _coverImagePath;
  bool _autoValidate = false;

  final List<String> _tags = [
    'Language Learning',
    'Science and Technology',
    'Law',
    'Other',
  ];

  final List<String> _languages = ['English', 'Spanish', 'French', 'Others'];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _handleCreate() {
    if (_formKey.currentState!.validate()) {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('User not authenticated')));
        return;
      }

      final studySetId = DateTime.now().millisecondsSinceEpoch.toString();

      StudySetCacheManager.instance.initializeStudySet(
        id: studySetId,
        name: _titleController.text,
        description: _descriptionController.text,
        category: _selectedTag!,
        language: _selectedLanguage!,
        ownerId: userId,
        coverImagePath: _coverImagePath,
      );

      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return PageTransition(
              animation: animation,
              animationType: AnimationType.slideLeft,
              child: StudySetDashboard(
                title: _titleController.text,
                description: _descriptionController.text,
                language: _selectedLanguage!,
                category: _selectedTag!,
                coverImagePath: _coverImagePath,
                studySetId: studySetId,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        ),
      );
    } else {
      setState(() => _autoValidate = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'New Study Set',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          color: AppColors.textPrimary,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 10, 24, kBottomNavbarHeight),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 32),
                _buildFormSection(),
                const SizedBox(height: 40),
                PrimaryButton(
                  text: 'Create Study Set',
                  onPressed: _handleCreate,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Let\'s build your set',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Fill in the details below to organize your learning materials effectively.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondary.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(
            title: 'Title',
            child: CustomTextField(
              controller: _titleController,
              hintText: 'e.g., Biology 101, French Basics',
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a title' : null,
              autoValidate: _autoValidate,
            ),
          ),
          const SizedBox(height: 24),
          SectionTitle(
            title: 'Description',
            child: CustomTextField(
              controller: _descriptionController,
              hintText: 'What is this study set about?',
              maxLines: 3,
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Please enter a description' : null,
              autoValidate: _autoValidate,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SectionTitle(
                  title: 'Language',
                  child: CustomDropdown(
                    value: _selectedLanguage,
                    items: _languages,
                    hintText: 'Select',
                    validator: (value) => value == null ? 'Required' : null,
                    autoValidate: _autoValidate,
                    onChanged: (val) => setState(() => _selectedLanguage = val),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SectionTitle(
                  title: 'Category',
                  child: CustomDropdown(
                    value: _selectedTag,
                    items: _tags,
                    hintText: 'Select',
                    validator: (value) => value == null ? 'Required' : null,
                    autoValidate: _autoValidate,
                    onChanged: (val) => setState(() => _selectedTag = val),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SectionTitle(
            title: 'Cover Image',
            child: ImagePickerWidget(
              imagePath: _coverImagePath,
              onTap: () async {
                try {
                  final imagePath = await ImagePickerService()
                      .pickImageFromGallery();
                  if (imagePath != null) {
                    setState(() => _coverImagePath = imagePath);
                  }
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('Error: $e')));
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
