import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quiz_app/CreateSection/models/flashcard_set.dart';
import 'package:quiz_app/CreateSection/screens/flashcard_creation_page.dart';
import 'package:quiz_app/CreateSection/services/image_picker_service.dart';
import 'package:quiz_app/CreateSection/widgets/custom_dropdown.dart';
import 'package:quiz_app/CreateSection/widgets/custom_text_field.dart';
import 'package:quiz_app/CreateSection/widgets/image_picker.dart';
import 'package:quiz_app/CreateSection/widgets/primary_button.dart';
import 'package:quiz_app/CreateSection/widgets/section_title.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/utils/globals.dart';
import 'package:quiz_app/widgets/appbar/universal_appbar.dart';

class FlashcardDetailsPage extends StatefulWidget {
  final bool isStudySetMode;
  final Function(FlashcardSet)? onSaveForStudySet;

  const FlashcardDetailsPage({
    super.key,
    this.isStudySetMode = false,
    this.onSaveForStudySet,
  });

  @override
  FlashcardDetailsPageState createState() => FlashcardDetailsPageState();
}

class FlashcardDetailsPageState extends State<FlashcardDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String? _selectedCategory;
  String? _coverImagePath;
  bool _autoValidate = false;

  final List<String> _categories = [
    'Language Learning',
    'Science and Technology',
    'Law',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const UniversalAppBar(title: 'Create Flashcard Set'),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 120.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fill the details to get started',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Flashcard Set Title Field
                  SectionTitle(
                    title: 'Set Title',
                    child: CustomTextField(
                      controller: _titleController,
                      hintText: 'Enter the title',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                      autoValidate: _autoValidate,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Cover Image Section
                  SectionTitle(
                    title: 'Cover Image',
                    child: ImagePickerWidget(
                      imagePath: _coverImagePath,
                      onTap: _pickImage,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Description Field
                  SectionTitle(
                    title: 'Description',
                    child: CustomTextField(
                      controller: _descriptionController,
                      hintText: 'Describe your flashcard set...',
                      maxLines: 4,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                      autoValidate: _autoValidate,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Category Dropdown
                  SectionTitle(
                    title: 'Category',
                    child: CustomDropdown(
                      value: _selectedCategory,
                      items: _categories,
                      hintText: 'Select a category',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                      autoValidate: _autoValidate,
                      onChanged: (value) =>
                          setState(() => _selectedCategory = value),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Get Started Button
                  PrimaryButton(
                    text: 'Get Started',
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final userId = FirebaseAuth.instance.currentUser?.uid;
                        if (userId == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('User not authenticated'),
                            ),
                          );
                          return;
                        }

                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => FlashcardCreationPage(
                              title: _titleController.text,
                              description: _descriptionController.text,
                              category: _selectedCategory!,
                              creatorId: userId,
                              isStudySetMode: widget.isStudySetMode,
                              onSaveForStudySet: widget.onSaveForStudySet,
                            ),
                          ),
                        );
                      } else {
                        setState(() => _autoValidate = true);
                      }
                    },
                  ),

                  SizedBox(height: kBottomNavbarHeight),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final imagePath = await ImagePickerService().pickImageFromGallery();
      if (imagePath != null) {
        setState(() {
          _coverImagePath = imagePath;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
