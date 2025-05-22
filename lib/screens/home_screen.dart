import 'package:flutter/material.dart';
import '../services/session_manager.dart';
import '../services/api_services.dart';
import 'AddFineDialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late List<Map<String, dynamic>> _offenseRecords = [];
  final ApiService _apiService = ApiService();
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchFines();
  }

  Future<void> _fetchFines() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userData = await UserPreferences.getUserData();
      final policeId = userData?['badgeNumber']?.toString();

      if (policeId == null) {
        throw Exception('Police badge number not found');
      }

      final response = await _apiService.fetchOffenseList();

      if (response != null) {
        // Handle different possible response structures
        List<dynamic> finesList = [];

        if (response is List) {
          finesList = response as List;
        } else if (response is Map) {
          if (response.containsKey('data')) {
            finesList = response['data'] is List ? response['data'] : [];
          } else {
            // If response is a map but not in expected format, try to convert values to list
            finesList = response.values.toList();
          }
        }

        // Filter fines by policeId and ensure each item is a Map
        final filteredFines = finesList.where((fine) {
          if (fine is! Map) return false;
          return fine['policeId']?.toString() == policeId;
        }).toList();

        print('filteredFines: $filteredFines');

        setState(() {
          _offenseRecords = List<Map<String, dynamic>>.from(filteredFines);
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load fines: ${e.toString()}';
      });
      debugPrint('Error fetching fines: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showUserInfoDialog() async {
    final userData = await UserPreferences.getUserData();
    print('user data: $userData');

    if (userData == null || userData.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("User Info"),
          content: const Text("No user data found."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

    final filteredUserData = Map.fromEntries(userData.entries.where(
      (entry) => !['id', 'token'].contains(entry.key.toLowerCase()),
    ));

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("User Info"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: filteredUserData.entries.map((entry) {
            return Text("${_formatKey(entry.key)}: ${entry.value}");
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  String _formatKey(String key) {
    return key.replaceAllMapped(RegExp(r'(_|^)([a-z])'), (match) {
      return " ${match[2]!.toUpperCase()}";
    }).trim();
  }

  void _showAddOffenseForm() {
    showDialog(
      context: context,
      builder: (context) {
        return AddFineDialog(
          onSubmit: (fineData) {
            setState(() {
              _offenseRecords.add(fineData);
            });
            _fetchFines(); // Refresh the list after adding new fine
          },
          onClose: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFebcec7),
      appBar: AppBar(
        title: const Text("My Issued Fines"),
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: _showUserInfoDialog,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchFines,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _offenseRecords.isEmpty
                  ? const Center(child: Text("No fines issued yet"))
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: _offenseRecords.length,
                      itemBuilder: (context, index) {
                        final record = _offenseRecords[index];
                        return Card(
                          color: record['isPaid'] ? Colors.green : Colors.red,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Type: ${record['type'] ?? 'N/A'}",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: record['isPaid']
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Name: ${record['civilUserName'] ?? 'N/A'}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: record['isPaid']
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                                Text(
                                  "NIC: ${record['civilNIC'] ?? 'N/A'}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: record['isPaid']
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                                Text(
                                  "Location: ${record['issueLocation'] ?? 'N/A'}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: record['isPaid']
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                                Text(
                                  "Date: ${record['date'] ?? 'N/A'}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: record['isPaid']
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                                Text(
                                  "Time: ${record['time'] ?? 'N/A'}",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: record['isPaid']
                                        ? Colors.black
                                        : Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOffenseForm,
        tooltip: 'Add New Fine',
        child: const Icon(Icons.add),
      ),
    );
  }
}
