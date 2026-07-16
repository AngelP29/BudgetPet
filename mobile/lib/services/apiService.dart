import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiService {
  // Android emulator -> host machine is 10.0.2.2, NOT localhost.
  // iOS simulator / Flutter web -> localhost works fine.
  // Physical device -> use your machine's LAN IP, e.g. http://192.168.1.42:5000/api
  static const String baseUrl = 'http://10.0.2.2:5000/api';

  // ---------------------------------------------------------------------
  // Internal helpers
  // ---------------------------------------------------------------------

  Future<Map<String, String>> _headers({bool auth = false}) async {
    final headers = {'Content-Type': 'application/json'};
    if (auth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  // Decodes the response and throws ApiException on failure, so callers
  // can just try/catch instead of checking statusCode.
  dynamic _handle(http.Response response) {
    final decoded = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final message = (decoded is Map && decoded['error'] != null)
        ? decoded['error'] as String
        : 'Request failed (${response.statusCode}).';
    throw ApiException(message);
  }

  Future<void> _saveSession(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', data['token'] as String);
    await prefs.setString('userId', data['userId'] as String);
    await prefs.setString('username', data['username'] as String);
  }

  Future<String?> getStoredUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('username');
  }


  // POST /api/auth/register
  Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String username,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: await _headers(),
      body: jsonEncode({
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'password': password,
      }),
    );

    final data = _handle(response) as Map<String, dynamic>;
    await _saveSession(data);
    return data;
  }

  // POST /api/auth/login
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: await _headers(),
      body: jsonEncode({
        'username': username,
        'password': password,
      }),
    );

    final data = _handle(response) as Map<String, dynamic>;
    await _saveSession(data);
    return data;
  }

  // POST /api/expenses/add  (requires auth token)
  // Returns the new expense plus the pet's updated happiness/level/exp.
  Future<Map<String, dynamic>> addExpense({
    required num amount,
    required String category,
    String? description,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/expenses/add'),
      headers: await _headers(auth: true),
      body: jsonEncode({
        'amount': amount,
        'category': category,
        'description': description,
      }),
    );

    return _handle(response) as Map<String, dynamic>;
  }

  // GET /api/expenses/:userId
  Future<List<dynamic>> getExpenses(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/expenses/$userId'),
      headers: await _headers(),
    );

    return _handle(response) as List<dynamic>;
  }

  // PUT /api/expenses/:expenseId
  Future<Map<String, dynamic>> updateExpense({
    required String expenseId,
    required String userId,
    required num amount,
    required String category,
    String? description,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/expenses/$expenseId'),
      headers: await _headers(),
      body: jsonEncode({
        'userId': userId,
        'amount': amount,
        'category': category,
        'description': description,
      }),
    );

    return _handle(response) as Map<String, dynamic>;
  }

  // DELETE /api/expenses/:expenseId
  Future<Map<String, dynamic>> deleteExpense({
    required String expenseId,
    required String userId,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/expenses/$expenseId'),
      headers: await _headers(),
      body: jsonEncode({'userId': userId}),
    );

    return _handle(response) as Map<String, dynamic>;
  }

  // GET /api/pets/:userId
  Future<Map<String, dynamic>> getPet(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/pets/$userId'),
      headers: await _headers(),
    );

    return _handle(response) as Map<String, dynamic>;
  }

  // POST /api/pets/interact
  Future<Map<String, dynamic>> interactWithPet({
    required String userId,
    required String action,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pets/interact'),
      headers: await _headers(),
      body: jsonEncode({
        'userId': userId,
        'action': action,
      }),
    );

    return _handle(response) as Map<String, dynamic>;
  }

  // POST /api/pets/chat
  // Returns just the assistant's reply text.
  Future<String> chatWithPetAi({
    required String message,
    String? petName,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/pets/chat'),
      headers: await _headers(),
      body: jsonEncode({
        'message': message,
        'petName': petName,
      }),
    );

    final data = _handle(response) as Map<String, dynamic>;
    return data['reply'] as String;
  }

  // GET /api/dashboard/:userId
  Future<Map<String, dynamic>> getDashboardStats(String userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/dashboard/$userId'),
      headers: await _headers(),
    );

    return _handle(response) as Map<String, dynamic>;
  }

  // PUT /api/dashboard/:userId
  Future<Map<String, dynamic>> updateDashboardGoals({
    required String userId,
    required num monthlyBudget,
    required num monthlySavingsGoal,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/dashboard/$userId'),
      headers: await _headers(),
      body: jsonEncode({
        'monthlyBudget': monthlyBudget,
        'monthlySavingsGoal': monthlySavingsGoal,
      }),
    );

    return _handle(response) as Map<String, dynamic>;
  }
}