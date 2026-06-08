import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GroqService {
  static const String _model = 'llama-3.1-8b-instant';
  static const String _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  
  static String? _getApiKey() {
    return dotenv.env['GROQ_API_KEY'];
  }

  static Future<List<Map<String, dynamic>>> generateQuiz(String topic) async {
    String? apiKey = _getApiKey();
    
    if (apiKey == null || apiKey.isEmpty) {
      throw Exception("Groq API key not found in .env file. Please check your setup.");
    }

    final prompt = '''
You are an expert quiz generator. Generate 30 multiple-choice questions about the topic: "$topic".
Output ONLY valid JSON in the exact format shown below, with no markdown formatting, no comments, and no extra text.
Format:
[
  {
    "question": "Question text here",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correctAnswerIndex": 0
  }
]
''';

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: jsonEncode({
        'model': _model,
        'messages': [
          {'role': 'system', 'content': 'You output strictly JSON only without markdown formatting.'},
          {'role': 'user', 'content': prompt}
        ],
        'temperature': 0.7,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = data['choices'][0]['message']['content'] as String;
      
      String cleanContent = content.trim();
      
      // Extract everything between the first [ and the last ]
      final startIndex = cleanContent.indexOf('[');
      final endIndex = cleanContent.lastIndexOf(']');
      
      if (startIndex != -1 && endIndex != -1 && endIndex >= startIndex) {
        cleanContent = cleanContent.substring(startIndex, endIndex + 1);
      }
      
      final List<dynamic> jsonList = jsonDecode(cleanContent);
      
      return jsonList.map((e) => e as Map<String, dynamic>).toList();
    } else {
      throw Exception("Failed to generate quiz (Status ${response.statusCode}): ${response.body}");
    }
  }
}
