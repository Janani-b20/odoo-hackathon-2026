import 'dart:convert';

import 'package:http/http.dart' as http;

/// Minimal REST client for the local Dayflow demo API.
class DayflowApi {
  DayflowApi({http.Client? client}) : _client = client ?? http.Client();

  static const baseUrl = 'http://127.0.0.1:8000';
  final http.Client _client;

  Future<Map<String, dynamic>> login(String email) async {
    final response = await _client.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': 'demo'}),
    );
    return _decode(response);
  }

  Future<List<dynamic>> employees() async => _decodeList(await _client.get(Uri.parse('$baseUrl/employees')));
  Future<List<dynamic>> payroll() async => _decodeList(await _client.get(Uri.parse('$baseUrl/payroll')));
  Future<List<dynamic>> attendance({int? employeeId}) async {
    final suffix = employeeId == null ? '' : '?employee_id=$employeeId';
    return _decodeList(
      await _client.get(Uri.parse('$baseUrl/attendance$suffix')),
    );
  }

  Future<List<dynamic>> leaves({int? employeeId}) async {
    final suffix = employeeId == null ? '' : '?employee_id=$employeeId';
    return _decodeList(await _client.get(Uri.parse('$baseUrl/leaves$suffix')));
  }

  Future<void> applyForLeave({required int employeeId, required String leaveType, required String startDate, required String endDate, required String remarks}) async {
    final response = await _client.post(Uri.parse('$baseUrl/leaves'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'employee_id': employeeId, 'leave_type': leaveType, 'start_date': startDate, 'end_date': endDate, 'remarks': remarks}));
    _decode(response);
  }

  Future<Map<String, dynamic>> checkIn(int employeeId) async => _decode(await _client.post(Uri.parse('$baseUrl/attendance/check-in'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'employee_id': employeeId})));
  Future<Map<String, dynamic>> checkOut(int employeeId) async => _decode(await _client.post(Uri.parse('$baseUrl/attendance/check-out'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'employee_id': employeeId})));

  Future<void> updateLeaveStatus(int leaveId, String status) async {
    final response = await _client.patch(Uri.parse('$baseUrl/leaves/$leaveId'), headers: {'Content-Type': 'application/json'}, body: jsonEncode({'status': status}));
    _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode >= 400) throw Exception(data['error'] ?? 'Request failed');
    return data;
  }

  List<dynamic> _decodeList(http.Response response) {
    if (response.statusCode >= 400) throw Exception('Request failed');
    return jsonDecode(response.body) as List<dynamic>;
  }
}

