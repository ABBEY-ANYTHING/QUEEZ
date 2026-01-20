import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:quiz_app/CreateSection/models/note.dart';
import 'package:quiz_app/CreateSection/services/note_service.dart';
import 'package:quiz_app/utils/app_logger.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/widgets/appbar/universal_appbar.dart';
import 'package:quiz_app/widgets/core/app_dialog.dart';
import 'package:vsc_quill_delta_to_html/vsc_quill_delta_to_html.dart';

/// Page for editing an existing note
class NoteEditPage extends StatefulWidget {
  final Note note;
  final VoidCallback? onSaved;

  const NoteEditPage({super.key, required this.note, this.onSaved});

  @override
  State<NoteEditPage> createState() => _NoteEditPageState();
}

class _NoteEditPageState extends State<NoteEditPage> {
  late QuillController _controller;
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  final FocusNode _focusNode = FocusNode();
  bool _isSaving = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _descriptionController = TextEditingController(
      text: widget.note.description,
    );
    _initializeQuillController();

    // Track changes
    _titleController.addListener(_onFieldChanged);
    _descriptionController.addListener(_onFieldChanged);
  }

  void _initializeQuillController() {
    try {
      Document document;
      final content = widget.note.content;

      if (_isHtmlContent(content)) {
        // Convert HTML to Quill Delta
        final converter = HtmlToDelta();
        final delta = converter.convert(content);
        document = Document.fromDelta(delta);
      } else {
        // Try parsing as Quill Delta JSON
        try {
          final dynamic parsed = jsonDecode(content);
          if (parsed is List) {
            document = Document.fromJson(parsed);
          } else if (parsed is Map && parsed.containsKey('ops')) {
            document = Document.fromJson(parsed['ops']);
          } else {
            document = Document()..insert(0, content);
          }
        } catch (_) {
          document = Document()..insert(0, content);
        }
      }

      _controller = QuillController(
        document: document,
        selection: const TextSelection.collapsed(offset: 0),
      );

      // Track content changes
      _controller.document.changes.listen((_) {
        if (mounted && !_hasChanges) {
          setState(() => _hasChanges = true);
        }
      });
    } catch (e) {
      AppLogger.error('Error initializing Quill controller: $e');
      _controller = QuillController.basic();
    }
  }

  bool _isHtmlContent(String content) {
    final trimmed = content.trim();
    return trimmed.startsWith('<') &&
        (trimmed.contains('</') || trimmed.contains('/>'));
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() => _hasChanges = true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldDiscard = await AppDialog.showInput<bool>(
      context: context,
      title: 'Discard Changes?',
      content: const Text(
        'You have unsaved changes. Are you sure you want to discard them?',
        style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
      ),
      cancelText: 'Keep Editing',
      submitText: 'Discard',
      onSubmit: () => true,
    );

    return shouldDiscard == true;
  }

  Future<void> _saveNote() async {
    // Validate title
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title cannot be empty'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

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

      await NoteService.updateNote(
        noteId: widget.note.id ?? '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: widget.note.category,
        creatorId: widget.note.creatorId,
        content: htmlContent,
      );

      AppLogger.success('Note updated: ${widget.note.id}');

      if (mounted) {
        setState(() => _hasChanges = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 20),
                SizedBox(width: 12),
                Text('Note saved successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );

        widget.onSaved?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      AppLogger.error('Error updating note: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error saving note: ${e.toString().replaceAll('Exception: ', '')}',
            ),
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

  Widget _buildSaveAction() {
    if (_isSaving) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
      );
    }
    return IconButton(
      icon: Icon(
        Icons.save,
        color: _hasChanges ? AppColors.primary : AppColors.textSecondary,
      ),
      onPressed: _hasChanges ? _saveNote : null,
      tooltip: 'Save Note',
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasChanges,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: UniversalAppBar(
          title: 'Edit Note',
          showNotificationBell: false,
          actions: [_buildSaveAction()],
        ),
        body: Column(
          children: [
            // Title and Description section
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Note Title',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _descriptionController,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Add a description (optional)',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                    ),
                    maxLines: 2,
                  ),
                ],
              ),
            ),

            const Divider(height: 1, thickness: 1),

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
