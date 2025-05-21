import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<Map<String, String>> _offenseRecords = [];

  void _showAddOffenseForm() {
    final TextEditingController licenseController = TextEditingController();
    final TextEditingController dateController = TextEditingController();
    final TextEditingController offenceController = TextEditingController();
    String nature = "Low"; // Default nature value
    String type = "Normal"; // Default type value
    final TextEditingController amountController = TextEditingController();

    Future<void> _selectDate() async {
      DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(2000),
        lastDate: DateTime(2100),
      );
      if (picked != null) {
        setState(() {
          dateController.text = "${picked.year}-${picked.month}-${picked.day}";
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Add Offense Record"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(licenseController, "License ID"),
                TextField(
                  controller: dateController,
                  decoration: InputDecoration(
                    labelText: "Date",
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _selectDate,
                    ),
                  ),
                  readOnly: true,
                ),
                const SizedBox(height: 10),
                _buildTextField(offenceController, "Offense"),
                const SizedBox(height: 10),
                _buildDropdown("Nature", ["Low", "Medium", "High"], (value) {
                  nature = value!;
                }),
                const SizedBox(height: 10),
                _buildDropdown("Type", ["Normal", "Court"], (value) {
                  type = value!;
                }),
                const SizedBox(height: 10),
                _buildTextField(amountController, "Amount"),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (licenseController.text.isNotEmpty &&
                    dateController.text.isNotEmpty &&
                    offenceController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  setState(() {
                    _offenseRecords.add({
                      "License ID": licenseController.text,
                      "Date": dateController.text,
                      "Offense": offenceController.text,
                      "Nature": nature,
                      "Type": type,
                      "Amount": amountController.text,
                    });
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Submit"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> options, Function(String?) onChanged) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      value: options.first,
      items: options.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFebcec7),
      appBar: AppBar(
        title: const Text("Home"),
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
