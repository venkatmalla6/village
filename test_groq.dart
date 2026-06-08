import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final _model = 'llama-3.1-8b-instant';
  final _apiUrl = 'https://api.groq.com/openai/v1/chat/completions';
  final apiKey = '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';
  
  final prompt = 'Generate 1 multiple-choice question about "Test". Output ONLY valid JSON.';

  print('Sending request...');
  final response = await http.post(
    Uri.parse(_apiUrl),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $apiKey',
    },
    body: jsonEncode({
      'model': _model,
      'messages': [
        {'role': 'user', 'content': prompt}
      ],
      'temperature': 0.7,
    }),
  );

  print('Status code: ${response.statusCode}');
  print('Body: ${response.body}');
}
