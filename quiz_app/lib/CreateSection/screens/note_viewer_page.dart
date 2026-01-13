import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_delta_from_html/flutter_quill_delta_from_html.dart';
import 'package:quiz_app/CreateSection/models/note.dart';
import 'package:quiz_app/CreateSection/services/note_service.dart';
import 'package:quiz_app/utils/color.dart';
import 'package:quiz_app/widgets/appbar/universal_appbar.dart';
import 'package:quiz_app/widgets/bottom_nav_aware_page.dart';

class NoteViewerPage extends StatefulWidget {
  final String noteId;
  final String userId;
  final Note? preloadedNote;

  const NoteViewerPage({
    super.key,
    required this.noteId,
    required this.userId,
    this.preloadedNote,
  });

  @override
  State<NoteViewerPage> createState() => _NoteViewerPageState();
}

class _NoteViewerPageState extends State<NoteViewerPage> {
  late QuillController _controller;
  String? _noteTitle;

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();

    // Use preloaded note if available, otherwise fetch
    if (widget.preloadedNote != null) {
      _initializeNote(widget.preloadedNote!);
    } else {
      _loadNote();
    }
  }

  void _initializeNote(Note note) {
    try {
      Document document;

      // Check if content is HTML (AI-generated) or Quill Delta (manually created)
      final content = note.content;

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
            // Legacy format: direct list of ops
            document = Document.fromJson(parsed);
          } else if (parsed is Map && parsed.containsKey('ops')) {
            // Format: {"ops": [...]}
            document = Document.fromJson(parsed['ops']);
          } else {
            // Unknown format, treat as plain text
            document = Document()..insert(0, content);
          }
        } catch (_) {
          // Not valid JSON, treat as plain text
          document = Document()..insert(0, content);
        }
      }

      setState(() {
        _controller = QuillController(
          document: document,
          selection: const TextSelection.collapsed(offset: 0),
          readOnly: true,
        );
        _noteTitle = note.title;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading note: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  bool _isHtmlContent(String content) {
    // Check if content looks like HTML
    final trimmed = content.trim();
    return trimmed.startsWith('<') &&
        (trimmed.contains('</') || trimmed.contains('/>'));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadNote() async {
    try {
      final note = await NoteService.getNote(widget.noteId, widget.userId);
      _initializeNote(note);
    } catch (e) {
      // Show error in snackbar instead of state
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: UniversalAppBar(title: _noteTitle ?? 'Note'),
      body: BottomNavAwarePage(
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16),
          child: QuillEditor.basic(controller: _controller),
        ),
      ),
    );
  }
}
