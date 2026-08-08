import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../utils/constants.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<List<Product>> fetchProducts() async {
    try {
      final response = await _client
          .get(Uri.parse(ApiConstants.products))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Product.fromJson(e)).toList();
      }
      throw ApiException('Failed to load products (${response.statusCode})');
    } catch (e) {
      throw ApiException('Could not fetch products: ${e.toString()}');
    }
  }

  Future<Product> fetchProductById(int id) async {
    try {
      final response = await _client
          .get(Uri.parse('${ApiConstants.products}/$id'))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        return Product.fromJson(json.decode(response.body));
      }
      throw ApiException('Failed to load product (${response.statusCode})');
    } catch (e) {
      throw ApiException('Could not fetch product: ${e.toString()}');
    }
  }

  Future<List<String>> fetchCategories() async {
    try {
      final response = await _client
          .get(Uri.parse(ApiConstants.categories))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => e.toString()).toList();
      }
      throw ApiException('Failed to load categories (${response.statusCode})');
    } catch (e) {
      throw ApiException('Could not fetch categories: ${e.toString()}');
    }
  }

  Future<List<Product>> fetchProductsByCategory(String category) async {
    try {
      final response = await _client
          .get(Uri.parse(ApiConstants.productsByCategory(category)))
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((e) => Product.fromJson(e)).toList();
      }
      throw ApiException('Failed to load category (${response.statusCode})');
    } catch (e) {
      throw ApiException('Could not fetch category products: ${e.toString()}');
    }
  }

  /// Fake Store API's /auth/login only returns a token, not user details.
  /// It accepts fixed test users (e.g. username: "mor_2314", password: "83r5^_").
  Future<String> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(ApiConstants.login),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final token = data['token'];
        if (token == null) throw ApiException('Invalid credentials');
        return token;
      } else if (response.statusCode == 401) {
        throw ApiException('Invalid username or password');
      }
      throw ApiException('Login failed (${response.statusCode})');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Login failed: ${e.toString()}');
    }
  }

  /// Registers a new user via POST /users. Fake Store API persists this only
  /// in-memory on their mock server (not a real backend), so it won't be
  /// usable for a real /auth/login afterward — this is a known API limitation.
  Future<Map<String, dynamic>> register({
    required String email,
    required String username,
    required String password,
    required String firstname,
    required String lastname,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(ApiConstants.users),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'email': email,
              'username': username,
              'password': password,
              'name': {'firstname': firstname, 'lastname': lastname},
              'address': {
                'city': '',
                'street': '',
                'number': 0,
                'zipcode': '',
                'geolocation': {'lat': '0', 'long': '0'}
              },
              'phone': '',
            }),
          )
          .timeout(const Duration(seconds: 15));
      if (response.statusCode == 200 || response.statusCode == 201) {
        return json.decode(response.body);
      }
      throw ApiException('Registration failed (${response.statusCode})');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Registration failed: ${e.toString()}');
    }
  }

  void dispose() {
    _client.close();
  }
}
