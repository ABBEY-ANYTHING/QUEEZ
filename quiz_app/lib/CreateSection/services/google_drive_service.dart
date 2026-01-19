import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_app/api_config.dart';

/// Service for uploading videos to Google Drive via backend API
/// Videos are uploaded to the central Queez Google Drive folder
class GoogleDriveService {
  // Base URL for video API
  static String get _baseUrl => '${ApiConfig.baseUrl}/video';

  /// Wake up the server (Render free tier goes to sleep)
  static Future<bool> _wakeUpServer() async {
    try {
      debugPrint('📹 [GoogleDriveService] Waking up server...');
      final response = await http
          .get(Uri.parse('${ApiConfig.baseUrl}/health'))
          .timeout(const Duration(seconds: 10));
      debugPrint(
        '📹 [GoogleDriveService] Server wake response: ${response.statusCode}',
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('📹 [GoogleDriveService] Server might be starting up: $e');
      return false;
    }
  }

  /// Upload a video file to Google Drive
  ///
  /// [videoFile] - The video file to upload
  /// [title] - Display title for the video
  ///
  /// Returns a map with 'fileId' and 'shareableLink', or null on failure
  static Future<Map<String, dynamic>?> uploadVideo({
    required File videoFile,
    required String title,
  }) async {
    try {
      debugPrint('📹 [GoogleDriveService] Starting video upload...');
      debugPrint('📹 [GoogleDriveService] File path: ${videoFile.path}');
      debugPrint(
        '📹 [GoogleDriveService] File exists: ${await videoFile.exists()}',
      );

      final fileSize = await videoFile.length();
      debugPrint(
        '📹 [GoogleDriveService] File size: $fileSize bytes (${(fileSize / (1024 * 1024)).toStringAsFixed(2)} MB)',
      );
      debugPrint('📹 [GoogleDriveService] Title: $title');
      debugPrint('📹 [GoogleDriveService] Upload URL: $_baseUrl/upload');

      // Wake up the server first (Render free tier sleeps after 15 mins)
      debugPrint('📹 [GoogleDriveService] Checking if server is awake...');
      await _wakeUpServer();

      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload'),
      );

      // Add video file
      debugPrint('📹 [GoogleDriveService] Adding file to multipart request...');
      request.files.add(
        await http.MultipartFile.fromPath('file', videoFile.path),
      );

      // Add title as form field
      request.fields['title'] = title;

      // Send request with timeout (2 minutes for large files)
      debugPrint(
        '📹 [GoogleDriveService] Sending request to backend (timeout: 120s)...',
      );

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 120),
        onTimeout: () {
          debugPrint(
            '📹 [GoogleDriveService] ⚠️ Request timed out after 120 seconds',
          );
          throw TimeoutException('Upload timed out after 120 seconds');
        },
      );

      debugPrint(
        '📹 [GoogleDriveService] Response status: ${streamedResponse.statusCode}',
      );

      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('📹 [GoogleDriveService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          debugPrint('📹 [GoogleDriveService] ✅ Upload successful!');
          debugPrint('📹 [GoogleDriveService] File ID: ${data['fileId']}');
          debugPrint(
            '📹 [GoogleDriveService] Shareable Link: ${data['shareableLink']}',
          );
          return {
            'fileId': data['fileId'],
            'shareableLink': data['shareableLink'],
            'name': data['name'],
          };
        } else {
          debugPrint('📹 [GoogleDriveService] ❌ Upload failed - success=false');
          debugPrint('📹 [GoogleDriveService] Message: ${data['message']}');
        }
      } else {
        debugPrint(
          '📹 [GoogleDriveService] ❌ Upload failed with status ${response.statusCode}',
        );
        debugPrint('📹 [GoogleDriveService] Error body: ${response.body}');
      }

      return null;
    } on TimeoutException catch (e) {
      debugPrint('📹 [GoogleDriveService] ⏱️ Timeout error: $e');
      debugPrint(
        '📹 [GoogleDriveService] The server might be waking up or the file is too large.',
      );
      debugPrint('📹 [GoogleDriveService] Try again in a few seconds.');
      return null;
    } on SocketException catch (e) {
      debugPrint('📹 [GoogleDriveService] 🔌 Network error: $e');
      debugPrint('📹 [GoogleDriveService] Check your internet connection.');
      return null;
    } catch (e, stackTrace) {
      debugPrint('📹 [GoogleDriveService] ❌ Error uploading video: $e');
      debugPrint('📹 [GoogleDriveService] Stack trace: $stackTrace');
      return null;
    }
  }

  /// Delete a video from Google Drive
  ///
  /// [fileId] - The Google Drive file ID to delete
  ///
  /// Returns true if successful
  static Future<bool> deleteVideo(String fileId) async {
    try {
      final response = await http
          .delete(Uri.parse('$_baseUrl/$fileId'))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['success'] == true;
      }

      debugPrint('Delete failed: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      debugPrint('Error deleting video: $e');
      return false;
    }
  }

  /// Get video information
  ///
  /// [fileId] - The Google Drive file ID
  ///
  /// Returns video info map or null
  static Future<Map<String, dynamic>?> getVideoInfo(String fileId) async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/$fileId'))
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return data['video'];
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error getting video info: $e');
      return null;
    }
  }

  // These methods are no longer needed but kept for compatibility
  static bool get isSignedIn =>
      true; // Always "signed in" since backend handles auth
  static Future<bool> signIn() async => true;
  static Future<void> signOut() async {}
}
