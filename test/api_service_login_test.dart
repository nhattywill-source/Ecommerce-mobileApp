import 'dart:convert';

import 'package:ecommerce_app/services/api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test('login accepts 201 Created as a successful response', () async {
    final client = MockClient((request) async {
      expect(request.method, equals('POST'));
      expect(request.url.toString(),
          equals('https://fakestoreapi.com/auth/login'));
      expect(
        jsonDecode(request.body),
        equals({'username': 'mor_2314', 'password': '83r5^_'}),
      );

      return http.Response(jsonEncode({'token': 'demo-token'}), 201);
    });

    final service = ApiService(client: client);

    final token = await service.login(
      username: 'mor_2314',
      password: '83r5^_',
    );

    expect(token, equals('demo-token'));
  });
}
