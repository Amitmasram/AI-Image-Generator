// In prompt_repo.dart
import 'dart:developer';
import 'dart:typed_data';
import 'package:dio/dio.dart';

class PromptRepo {
  static Future<Uint8List?> generateImage(String prompt) async {
    try {
      String url = 'https://api.vyro.ai/v1/imagine/api/generations';
      Map<String, dynamic> headers = {
        'Authorization': 'Bearer vk-DfhpP30oxfDCyfzs4iceVC2nFV2DUgwDxolkYDTg3yB8n2'
      };

      Map<String, dynamic> payload = {
        'prompt': prompt,
        'style_id': '122',
        'aspect_ratio': '1:1',
        'cfg': '5',
        'seed': '1',
        'high_res_results': '1'
      };

      FormData formData = FormData.fromMap(payload);

      Dio dio = Dio();
      dio.options = BaseOptions(
        headers: headers,
        responseType: ResponseType.bytes,
        validateStatus: (status) => status! < 500,
      );

      final response = await dio.post(url, data: formData);
      if (response.statusCode == 200) {
        return Uint8List.fromList(response.data);
      } else {
        log('Error: ${response.statusCode} - ${response.statusMessage}');
        return null;
      }
    } catch (e) {
      log('Exception: $e');
      return null;
    }
  }
}
