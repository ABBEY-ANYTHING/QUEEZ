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
      // Create multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/upload'),
      );

      // Add video file
      request.files.add(
        await http.MultipartFile.fromPath('file', videoFile.path),
      );

      // Add title as form field
      request.fields['title'] = title;

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return {
            'fileId': data['fileId'],
            'shareableLink': data['shareableLink'],
            'name': data['name'],
          };
        }
      }

      debugPrint('Upload failed: ${response.statusCode} - ${response.body}');
      return null;
    } catch (e) {
      debugPrint('Error uploading video: $e');
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
      final response = await http.delete(Uri.parse('$_baseUrl/$fileId'));

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
      final response = await http.get(Uri.parse('$_baseUrl/$fileId'));

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
