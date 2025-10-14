// test/test_helpers/mock_data.dart
class MockData {
  static Map<String, dynamic> get validRequest => {
    'contents': [
      {
        'parts': [
          {'text': 'Hello, test message'},
        ],
      },
    ],
  };

  static Map<String, dynamic> get expectedResponse => {
    'candidates': [
      {
        'content': {
          'parts': [
            {'text': 'Hello! How can I help you?'},
          ],
        },
      },
    ],
  };
}
