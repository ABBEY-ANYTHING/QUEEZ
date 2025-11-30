import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';
import 'package:quiz_app/CreateSection/models/note.dart';
import 'package:quiz_app/CreateSection/services/note_service.dart';
import 'package:quiz_app/CreateSection/widgets/quiz_saved_dialog.dart';
import 'package:quiz_app/utils/color.dart';

class NoteEditorPage extends StatefulWidget {
  final String title;
  final String description;
  final String category;
  final String creatorId;
  final String? coverImagePath;
  final bool isStudySetMode;
  final Function(Note)? onSaveForStudySet;

  const NoteEditorPage({
    super.key,
    required this.title,
    required this.description,
    required this.category,
    required this.creatorId,
    this.coverImagePath,
    this.isStudySetMode = false,
    this.onSaveForStudySet,
  });

  @override
  State<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends State<NoteEditorPage> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    setState(() => _isSaving = true);

    try {
      // Convert Quill Delta to HTML for storage
      final delta = _controller.document.toDelta();
      final deltaJson = delta.toJson();
      final converter = QuillDeltaToHtmlConverter(
        List<Map<String, dynamic>>.from(deltaJson),
        ConverterOptions.forEmail(),
      );
      final htmlContent = converter.convert();

      // If in study set mode, create note and add to cache
      if (widget.isStudySetMode && widget.onSaveForStudySet != null) {
        final noteId = DateTime.now().millisecondsSinceEpoch.toString();
        final note = Note(
          id: noteId,
          title: widget.title,
          description: widget.description,
          category: widget.category,
          content: htmlContent,
          creatorId: widget.creatorId,
          coverImagePath: widget.coverImagePath,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );

        widget.onSaveForStudySet!(note);

        if (mounted) {
          // Show success dialog with custom QuizSavedDialog
          await QuizSavedDialog.show(
            context,
            title: 'Note Added!',
            message: 'Note has been added to your study set.',
            onDismiss: () async {
              if (mounted) {
                // Pop back to dashboard with simple slide animation
                // Stack: ... -> Dashboard -> NoteDetailsPage -> NoteEditorPage (current)
                int popCount = 0;
                Navigator.of(context).popUntil((route) {
                  return popCount++ >= 2 || route.isFirst;
                });
              }
            },
          );
        }
        return;
      }

      await NoteService.createNote(
        title: widget.title,
        description: widget.description,
        category: widget.category,
        creatorId: widget.creatorId,
        content: htmlContent,
        coverImagePath: widget.coverImagePath,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Note saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving note: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          widget.title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveNote,
              tooltip: 'Save Note',
            ),
        ],
      ),
      body: Column(
        children: [
          // Toolbar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Wrap(
              spacing: 4,
              children: [
                _buildToolbarButton(Icons.format_bold, Attribute.bold),
                _buildToolbarButton(Icons.format_italic, Attribute.italic),
                _buildToolbarButton(
                  Icons.format_underline,
                  Attribute.underline,
                ),
                const VerticalDivider(),
                _buildToolbarButton(Icons.format_list_bulleted, Attribute.ul),
                _buildToolbarButton(Icons.format_list_numbered, Attribute.ol),
                const VerticalDivider(),
                _buildToolbarButton(Icons.undo, null, isUndo: true),
                _buildToolbarButton(Icons.redo, null, isRedo: true),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1),

          // Editor
          Expanded(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: QuillEditor.basic(
                controller: _controller,
                focusNode: _focusNode,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton(
    IconData icon,
    Attribute? attribute, {
    bool isUndo = false,
    bool isRedo = false,
  }) {
    return IconButton(
      icon: Icon(icon, size: 20),
      onPressed: () {
        if (isUndo) {
          _controller.undo();
        } else if (isRedo) {
          _controller.redo();
        } else if (attribute != null) {
          final isActive = _controller.getSelectionStyle().containsKey(
            attribute.key,
          );
          _controller.formatSelection(
            isActive ? Attribute.clone(attribute, null) : attribute,
          );
        }
      },
      padding: const EdgeInsets.all(4),
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
    );
  }
}
