import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../api_config.dart';
import '../models/library_item.dart';

class UnifiedLibraryService {
  static const String baseUrl = ApiConfig.baseUrl;

  static Future<List<LibraryItem>> getUnifiedLibrary(String userId) async {
    try {
      print('📚 UNIFIED_LIBRARY_SERVICE - Fetching from: $baseUrl/library/$userId');
      
      final response = await http
          .get(
            Uri.parse('$baseUrl/library/$userId'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception(
                'Request timed out. Please check your internet connection.',
              );
            },
          );

      print('📚 UNIFIED_LIBRARY_SERVICE - Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['data'];
        print('📚 UNIFIED_LIBRARY_SERVICE - Received ${items.length} items');
        
        // Debug: Print types of items received
        final types = items.map((i) => i['type']).toList();
        print('📚 UNIFIED_LIBRARY_SERVICE - Item types: $types');
        
        return items.map((item) => LibraryItem.fromJson(item)).toList();
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['detail'] ?? 'Failed to fetch library');
      }
    } catch (e) {
      print('📚 UNIFIED_LIBRARY_SERVICE - Error: $e');
      throw Exception('Error fetching library: $e');
    }
  }
}
