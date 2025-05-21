import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'https://tms-server-rosy.vercel.app/';

  // Get user by ID
  Future<Map<String, dynamic>?> getUser(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/user/$id'));
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('Failed to fetch user. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
    return null;
  }

  // Login user
  Future<Map<String, dynamic>?> login(
      String badgeNumber, String password) async {
    final url = Uri.parse('${baseUrl}policeOfficers/auth/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'badgeNumber': badgeNumber,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'user': data['user']};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Login failed'
        };
      }
    } catch (e) {
      print('Login error: $e');
      return {'success': false, 'message': 'An error occurred'};
    }
  }

  // Get fines by NIC
  Future<List<Map<String, dynamic>>?> getFinesByNIC(String nic) async {
    final url = Uri.parse('${baseUrl}policeIssueFine/fines-get-by-NIC/$nic');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data["data"] is List) {
          return List<Map<String, dynamic>>.from(data["data"]);
        } else if (data['fines'] != null && data['fines'] is List) {
          return List<Map<String, dynamic>>.from(data['fines']);
        }
      } else {
        print('Failed to load fines, status: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception fetching fines: $e');
    }

    return null;
  }

  // Get all fines
  Future<List<Map<String, dynamic>>?> getAllFines() async {
    final url = Uri.parse('${baseUrl}fines/all');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<Map<String, dynamic>>.from(data['data']);
      } else {
        print('Failed to load all fines. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching all fines: $e');
    }

    return null;
  }

  // Get a fine by ID (ObjectId)
  Future<Map<String, dynamic>?> getFineById(String id) async {
    final url = Uri.parse('${baseUrl}fines/all');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> fines = data['data'];

        final fine = fines.firstWhere(
          (item) => item['_id'] == id,
          orElse: () => null,
        );

        if (fine != null) {
          return Map<String, dynamic>.from(fine);
        } else {
          print('Fine not found with ID: $id');
        }
      } else {
        print('Failed to load all fines. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching fine by ID: $e');
    }

    return null;
  }

  // Add new offense record
  Future<Map<String, dynamic>?> addOffenseRecord(
      Map<String, dynamic> data) async {
    final url = Uri.parse('${baseUrl}policeIssueFine/add');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return {'success': true, 'message': 'Offense added successfully'};
      } else {
        final error = jsonDecode(response.body);
        return {
          'success': false,
          'message': error['message'] ?? 'Failed to add offense'
        };
      }
    } catch (e) {
      print('Error adding offense record: $e');
      return {'success': false, 'message': 'An error occurred'};
    }
  }

  Future<List<dynamic>?> fetchOffenseList() async {
    final response = await http.get(Uri.parse('$baseUrl/policeIssueFine/all'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }
}
