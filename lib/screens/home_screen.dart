import 'package:flutter/material.dart';
import '../services/session_manager.dart';
import 'AddFineDialog.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> _offenseRecords = [];

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
              _offenseRecords.add(fineData.map(
                  (key, value) => MapEntry(key.toString(), value.toString())));
            });
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFebcec7),
      appBar: AppBar(
        title: const Text("Home"),
        leading: IconButton(
          icon: const Icon(Icons.person),
          onPressed: _showUserInfoDialog,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: _offenseRecords.isEmpty
          ? const Center(child: Text("No records available"))
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _offenseRecords.length,
              itemBuilder: (context, index) {
                final record = _offenseRecords[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: record.entries.map((entry) {
                        return Text(
                          "${entry.key}: ${entry.value}",
                          style: const TextStyle(fontSize: 16),
                        );
                      }).toList(),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddOffenseForm,
        tooltip: 'Add Offense',
        child: const Icon(Icons.add),
      ),
    );
  }
}
