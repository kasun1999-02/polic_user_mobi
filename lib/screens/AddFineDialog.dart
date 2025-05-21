import 'package:flutter/material.dart';
import '../services/api_services.dart';

class AddFineDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;

  const AddFineDialog({Key? key, required this.onSubmit}) : super(key: key);

  @override
  State<AddFineDialog> createState() => _AddFineDialogState();
}

class _AddFineDialogState extends State<AddFineDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nicController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  String selectedOffence = "Speeding";
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  final ApiService apiService = ApiService();
  bool _isLoading = false;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  Future<void> _submitFine() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final fineData = {
      "NIC": nicController.text.trim(),
      "Name": nameController.text.trim(),
      "Vehicle": vehicleController.text.trim(),
      "Offense": selectedOffence,
      "Location": locationController.text.trim(),
      "Date": selectedDate != null
          ? "${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}"
          : "",
      "Time": selectedTime != null ? selectedTime!.format(context) : "",
    };

    final result = await apiService.addOffenseRecord(fineData);

    setState(() => _isLoading = false);

    if (result != null && result['success'] == true) {
      if (mounted) {
        widget.onSubmit(fineData); // Notify parent
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(result['message'] ?? 'Fine added successfully')),
        );
        Navigator.pop(context, true);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result?['message'] ?? 'Failed to add fine')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Issue New Fine"),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nicController, "Civilian NIC",
                  required: true, hint: "Format: 993090809V"),
              _buildTextField(nameController, "Civilian Name", required: true),
              _buildTextField(vehicleController, "Vehicle Number"),
              DropdownButtonFormField<String>(
                value: selectedOffence,
                decoration: const InputDecoration(labelText: "Offence *"),
                items: ["Speeding", "No Helmet", "Signal Violation", "DUI"]
                    .map((o) => DropdownMenuItem(value: o, child: Text(o)))
                    .toList(),
                onChanged: (val) => setState(() => selectedOffence = val!),
              ),
              _buildTextField(locationController, "Issue Location *",
                  required: true),
              const SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Date",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.calendar_today),
                    onPressed: _selectDate,
                  ),
                ),
                readOnly: true,
                controller: TextEditingController(
                  text: selectedDate != null
                      ? "${selectedDate!.month}/${selectedDate!.day}/${selectedDate!.year}"
                      : "",
                ),
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: "Time",
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.access_time),
                    onPressed: _selectTime,
                  ),
                ),
                readOnly: true,
                controller: TextEditingController(
                  text:
                      selectedTime != null ? selectedTime!.format(context) : "",
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitFine,
          child: _isLoading
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2))
              : const Text("Submit Fine"),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool required = false, String? hint}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            required && (value == null || value.isEmpty) ? 'Required' : null,
      ),
    );
  }
}
