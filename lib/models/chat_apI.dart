import 'dart:convert';

import 'package:http/http.dart' as http;

class ChatApi {
  res(prompt) async {
    return await http.post(
      Uri.parse('https://api.openai.com/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer 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',
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "system", "content": "You are a helpful assistant."},
          {"role": "user", "content": prompt},
        ],
      }),
    );
  }
}
