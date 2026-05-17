import 'dart:convert';
import 'package:http/http.dart' as http;

class AiService {
  static const String baseUrl = 'http://localhost:3000';

  static Future<String> generateVideo({
    required String prompt,
  }) async {
    final url = Uri.parse('$baseUrl/generate-video');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'prompt': prompt,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Lỗi server: ${response.body}');
    }

    final data = jsonDecode(response.body);

    if (data['ok'] != true) {
      throw Exception(data['error'] ?? 'AI tạo video lỗi');
    }

    return data['output'].toString();
  }

  static Future<String> askAi(String message) async {
    return 'Bạn vừa hỏi: $message\n\nĐây là bản demo.';
  }
}