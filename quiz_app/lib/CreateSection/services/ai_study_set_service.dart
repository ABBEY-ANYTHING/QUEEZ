import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:quiz_app/CreateSection/models/ai_study_set_models.dart';
import 'package:quiz_app/CreateSection/models/study_set.dart';
import 'package:quiz_app/api_config.dart';

class AIStudySetService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Wake up the server (handles Render cold start)
  static Future<bool> wakeUpServer() async {
    try {
      debugPrint('Waking up server...');
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(
            const Duration(seconds: 90),
            onTimeout: () {
              throw Exception('Server wake-up timed out');
            },
          );
      debugPrint('Server wake-up response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Server wake-up failed: $e');
      return false;
    }
  }

  /// Get resumable upload URL from backend
  static Future<String> getUploadUrl({
    required String fileName,
    required String mimeType,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final token = await user.getIdToken();

      final response = await http
          .post(
            Uri.parse('$baseUrl/ai/get-upload-url'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'file_name': fileName, 'mime_type': mimeType}),
          )
          .timeout(
            const Duration(seconds: 90), // Increased for Render cold start
            onTimeout: () {
              throw Exception('Request timed out - server may be starting up');
            },
          );

      debugPrint('Upload URL response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['uploadUrl'];
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['detail'] ?? 'Failed to get upload URL');
      }
    } catch (e) {
      debugPrint('Error getting upload URL: $e');
      rethrow;
    }
  }

  /// Upload file using resumable upload URL with retry mechanism
  static Future<UploadedFile> uploadFileToGemini({required File file}) async {
    const int maxRetries = 3;
    int retryCount = 0;
    Duration retryDelay = const Duration(seconds: 2);

    while (true) {
      try {
        debugPrint('Uploading file to Gemini: ${file.path} (attempt ${retryCount + 1}/$maxRetries)');

        final fileName = file.path.split(Platform.pathSeparator).last;
        final fileBytes = await file.readAsBytes();
        final fileSize = fileBytes.length;

        // Determine MIME type
        String mimeType = 'application/octet-stream';
        if (fileName.toLowerCase().endsWith('.pdf')) {
          mimeType = 'application/pdf';
        } else if (fileName.toLowerCase().endsWith('.pptx')) {
          mimeType =
              'application/vnd.openxmlformats-officedocument.presentationml.presentation';
        } else if (fileName.toLowerCase().endsWith('.ppt')) {
          mimeType = 'application/vnd.ms-powerpoint';
        } else if (fileName.toLowerCase().endsWith('.docx')) {
          mimeType =
              'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        } else if (fileName.toLowerCase().endsWith('.doc')) {
          mimeType = 'application/msword';
        } else if (fileName.toLowerCase().endsWith('.txt')) {
          mimeType = 'text/plain';
        }

        debugPrint('File: $fileName, Size: $fileSize bytes, MIME: $mimeType');

        // Get resumable upload URL from backend
        final uploadUrl = await getUploadUrl(
          fileName: fileName,
          mimeType: mimeType,
        );

        debugPrint('Got upload URL, uploading file...');

        // Upload file data using resumable protocol
        final uploadResponse = await http
            .put(
              Uri.parse(uploadUrl),
              headers: {
                'Content-Length': fileSize.toString(),
                'X-Goog-Upload-Offset': '0',
                'X-Goog-Upload-Command': 'upload, finalize',
              },
              body: fileBytes,
            )
            .timeout(
              const Duration(minutes: 3),
              onTimeout: () {
                throw Exception('Upload timed out');
              },
            );

        debugPrint('Gemini upload response: ${uploadResponse.statusCode}');
        debugPrint('Response body: ${uploadResponse.body}');

        if (uploadResponse.statusCode == 200) {
          final data = jsonDecode(uploadResponse.body);
          final fileData = data['file'];

          return UploadedFile(
            fileName: fileData['displayName'] ?? fileName,
            fileUri: fileData['name'] ?? fileData['uri'],
            fileSize: fileSize,
            mimeType: fileData['mimeType'] ?? mimeType,
          );
        } else {
          throw Exception('Upload failed: ${uploadResponse.body}');
        }
      } catch (e) {
        retryCount++;
        final errorString = e.toString().toLowerCase();
        
        // Check if this is a retryable error (network issues, broken pipe, etc.)
        final isRetryable = errorString.contains('broken pipe') ||
            errorString.contains('connection') ||
            errorString.contains('socket') ||
            errorString.contains('timeout') ||
            errorString.contains('network');

        if (isRetryable && retryCount < maxRetries) {
          debugPrint('Retryable error occurred: $e. Retrying in ${retryDelay.inSeconds}s...');
          await Future.delayed(retryDelay);
          // Exponential backoff
          retryDelay *= 2;
          continue;
        }

        debugPrint('Error uploading file to Gemini (final): $e');
        
        // Provide a more user-friendly error message
        if (isRetryable) {
          throw Exception('Network error: Please check your internet connection and try again.');
        }
        rethrow;
      }
    }
  }

  /// Generate study set using uploaded file URIs
  static Future<StudySet> generateStudySet({
    required List<String> fileUris,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final token = await user.getIdToken();

      debugPrint('Generating study set with ${fileUris.length} files');

      final response = await http
          .post(
            Uri.parse('$baseUrl/ai/generate-study-set'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'fileUris': fileUris}),
          )
          .timeout(
            const Duration(minutes: 3),
            onTimeout: () {
              throw Exception(
                'Generation timed out. Please try with smaller documents.',
              );
            },
          );

      debugPrint('Generation response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['studySet'] != null) {
          return StudySet.fromJson(data['studySet']);
        }
        throw Exception('Invalid response format');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['error'] ?? 'Generation failed');
      }
    } catch (e) {
      debugPrint('Error generating study set: $e');
      rethrow;
    }
  }
}
