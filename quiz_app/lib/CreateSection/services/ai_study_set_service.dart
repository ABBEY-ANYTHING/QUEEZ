import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_app/CreateSection/models/ai_study_set_models.dart';
import 'package:quiz_app/CreateSection/models/study_set.dart';
import 'package:quiz_app/api_config.dart';
import 'package:quiz_app/utils/app_logger.dart';

class AIStudySetService {
  static const String baseUrl = ApiConfig.baseUrl;

  /// Wake up the server (handles Render cold start)
  static Future<bool> wakeUpServer() async {
    try {
      AppLogger.network('Waking up server...');
      final response = await http
          .get(Uri.parse('$baseUrl/health'))
          .timeout(
            const Duration(seconds: 90),
            onTimeout: () {
              throw Exception('Server wake-up timed out');
            },
          );
      AppLogger.network('Server wake-up response: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      AppLogger.warning('Server wake-up failed: $e');
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
      if (user == null) {
        throw Exception(
          'Authentication required\n\n'
          'Please sign in to upload documents.',
        );
      }

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
              throw Exception(
                'Server is starting up\n\n'
                'The server is warming up. This can take up to a minute on the first request. Please try again.',
              );
            },
          );

      AppLogger.network('Upload URL response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['uploadUrl'];
      } else {
        String errorMessage = 'Failed to prepare upload';
        try {
          final errorData = jsonDecode(response.body);
          final detail = errorData['detail'] ?? errorData['error'];
          if (detail != null) {
            errorMessage = detail.toString();
          }
        } catch (_) {
          if (response.statusCode == 401 || response.statusCode == 403) {
            errorMessage = 'Session expired. Please sign in again.';
          } else if (response.statusCode >= 500) {
            errorMessage = 'Server temporarily unavailable. Please try again.';
          }
        }
        throw Exception(errorMessage);
      }
    } on SocketException catch (_) {
      throw Exception(
        'No internet connection\n\n'
        'Please check your network connection and try again.',
      );
    } catch (e) {
      AppLogger.error('Error getting upload URL: $e');
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
        AppLogger.network(
          'Uploading file to Gemini: ${file.path} (attempt ${retryCount + 1}/$maxRetries)',
        );

        final fileName = file.path.split(Platform.pathSeparator).last;
        final fileBytes = await file.readAsBytes();
        final fileSize = fileBytes.length;

        // Check file size (20MB limit for Gemini)
        if (fileSize > 20 * 1024 * 1024) {
          throw Exception(
            'File "$fileName" is too large (${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB). '
            'Maximum file size is 20MB. Try compressing or splitting your document.',
          );
        }

        // Determine MIME type and validate supported formats
        String mimeType = 'application/octet-stream';
        final lowerFileName = fileName.toLowerCase();

        if (lowerFileName.endsWith('.pdf')) {
          mimeType = 'application/pdf';
        } else if (lowerFileName.endsWith('.pptx')) {
          mimeType =
              'application/vnd.openxmlformats-officedocument.presentationml.presentation';
        } else if (lowerFileName.endsWith('.ppt')) {
          mimeType = 'application/vnd.ms-powerpoint';
        } else if (lowerFileName.endsWith('.docx')) {
          mimeType =
              'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
        } else if (lowerFileName.endsWith('.doc')) {
          mimeType = 'application/msword';
        } else if (lowerFileName.endsWith('.txt')) {
          mimeType = 'text/plain';
        } else {
          // Unsupported file format
          final extension = lowerFileName.contains('.')
              ? lowerFileName.split('.').last.toUpperCase()
              : 'unknown';
          throw Exception(
            'Unsupported file format: .$extension\n\n'
            'Supported formats:\n'
            '• PDF documents (.pdf)\n'
            '• Word documents (.doc, .docx)\n'
            '• PowerPoint presentations (.ppt, .pptx)\n'
            '• Text files (.txt)',
          );
        }

        AppLogger.network(
          'File: $fileName, Size: $fileSize bytes, MIME: $mimeType',
        );

        // Get resumable upload URL from backend
        final uploadUrl = await getUploadUrl(
          fileName: fileName,
          mimeType: mimeType,
        );

        AppLogger.network('Got upload URL, uploading file...');

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
                throw Exception(
                  'Upload timed out after 3 minutes.\n\n'
                  'This could be due to:\n'
                  '• Slow internet connection\n'
                  '• Large file size\n\n'
                  'Try with a smaller document or check your connection.',
                );
              },
            );

        AppLogger.network(
          'Gemini upload response: ${uploadResponse.statusCode}',
        );
        AppLogger.network('Response body: ${uploadResponse.body}');

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
          // Parse error response for better messaging
          String errorMessage = 'Upload failed';
          try {
            final errorData = jsonDecode(uploadResponse.body);
            if (errorData['error'] != null) {
              errorMessage = errorData['error']['message'] ?? errorMessage;
            }
          } catch (_) {
            // Use status code for generic message
            if (uploadResponse.statusCode == 413) {
              errorMessage = 'File is too large for the server to process';
            } else if (uploadResponse.statusCode == 415) {
              errorMessage = 'File format not supported';
            } else if (uploadResponse.statusCode >= 500) {
              errorMessage =
                  'Server is temporarily unavailable. Please try again later.';
            }
          }
          throw Exception(errorMessage);
        }
      } catch (e) {
        retryCount++;
        final errorString = e.toString().toLowerCase();

        // Check if this is a retryable error (network issues, broken pipe, etc.)
        final isNetworkError =
            errorString.contains('broken pipe') ||
            errorString.contains('connection') ||
            errorString.contains('socket') ||
            errorString.contains('network') ||
            errorString.contains('socketexception') ||
            errorString.contains('handshake');

        final isTimeoutError =
            errorString.contains('timeout') ||
            errorString.contains('timed out');

        final isRetryable = isNetworkError || isTimeoutError;

        if (isRetryable && retryCount < maxRetries) {
          AppLogger.network(
            'Retryable error occurred: $e. Retrying in ${retryDelay.inSeconds}s...',
          );
          await Future.delayed(retryDelay);
          // Exponential backoff
          retryDelay *= 2;
          continue;
        }

        AppLogger.network('Error uploading file to Gemini (final): $e');

        // Provide user-friendly error messages based on error type
        if (isNetworkError) {
          throw Exception(
            'Connection error\n\n'
            'Unable to connect to the server. Please:\n'
            '• Check your internet connection\n'
            '• Make sure you\'re not on a restricted network\n'
            '• Try again in a few moments',
          );
        }

        if (isTimeoutError) {
          throw Exception(
            'Request timed out\n\n'
            'The server took too long to respond. This may be due to:\n'
            '• Slow internet connection\n'
            '• Server is busy\n\n'
            'Please try again.',
          );
        }

        // For other errors, clean up the message
        final cleanError = e
            .toString()
            .replaceAll('Exception: ', '')
            .replaceAll('exception: ', '');
        throw Exception(cleanError);
      }
    }
  }

  /// Generate study set using uploaded file URIs
  static Future<StudySet> generateStudySet({
    required List<String> fileUris,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception(
          'Authentication required\n\n'
          'Please sign in to generate study materials.',
        );
      }

      final token = await user.getIdToken();

      AppLogger.network('Generating study set with ${fileUris.length} files');

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
                'Generation timed out\n\n'
                'The AI is taking longer than expected. This may happen with:\n'
                '• Very large documents\n'
                '• Complex content\n\n'
                'Try with smaller or simpler documents.',
              );
            },
          );

      AppLogger.network('Generation response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['studySet'] != null) {
          return StudySet.fromJson(data['studySet']);
        }
        throw Exception(
          'Invalid response from server\n\n'
          'The server returned an unexpected format. Please try again.',
        );
      } else {
        // Parse and provide user-friendly error messages
        String errorMessage = 'Generation failed';
        try {
          final errorData = jsonDecode(response.body);
          final detail = errorData['error'] ?? errorData['detail'];
          if (detail != null) {
            // Check for common error patterns
            final detailLower = detail.toString().toLowerCase();
            if (detailLower.contains('quota') ||
                detailLower.contains('rate limit')) {
              errorMessage =
                  'Service temporarily busy\n\n'
                  'Too many requests at the moment. Please wait a few minutes and try again.';
            } else if (detailLower.contains('content') &&
                detailLower.contains('extract')) {
              errorMessage =
                  'Unable to read document\n\n'
                  'The AI couldn\'t extract text from your document. This may happen with:\n'
                  '• Scanned PDFs (image-based)\n'
                  '• Password-protected files\n'
                  '• Corrupted documents\n\n'
                  'Try a different document or use a text-based PDF.';
            } else if (detailLower.contains('empty') ||
                detailLower.contains('no content')) {
              errorMessage =
                  'Document appears empty\n\n'
                  'No text content was found in your document. Please ensure your file contains readable text.';
            } else if (detailLower.contains('safety') ||
                detailLower.contains('block')) {
              errorMessage =
                  'Content not supported\n\n'
                  'The document contains content that cannot be processed. Please try a different document.';
            } else {
              errorMessage = detail.toString();
            }
          }
        } catch (_) {
          // Handle by status code
          if (response.statusCode == 401 || response.statusCode == 403) {
            errorMessage =
                'Session expired\n\n'
                'Please sign out and sign in again to continue.';
          } else if (response.statusCode == 429) {
            errorMessage =
                'Too many requests\n\n'
                'Please wait a few minutes before trying again.';
          } else if (response.statusCode >= 500) {
            errorMessage =
                'Server error\n\n'
                'Our servers are experiencing issues. Please try again later.';
          }
        }
        throw Exception(errorMessage);
      }
    } on SocketException catch (_) {
      throw Exception(
        'No internet connection\n\n'
        'Please check your network connection and try again.',
      );
    } catch (e) {
      AppLogger.network('Error generating study set: $e');
      // Clean up error message if it's already user-friendly
      final errorStr = e.toString();
      if (errorStr.contains('\n\n')) {
        // Already formatted, rethrow as-is
        rethrow;
      }
      // Clean and rethrow
      throw Exception(
        errorStr.replaceAll('Exception: ', '').replaceAll('exception: ', ''),
      );
    }
  }
}
