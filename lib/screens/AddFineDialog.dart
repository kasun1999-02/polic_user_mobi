import 'package:flutter/material.dart';
import '../services/api_services.dart';

class AddFineDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) onSubmit;
  final VoidCallback onClose;

  const AddFineDialog({
    super.key,
    required this.onSubmit,
    required this.onClose,
  });

  @override
  State<AddFineDialog> createState() => _AddFineDialogState();
}

class _AddFineDialogState extends State<AddFineDialog> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  // Form fields
  final Map<String, dynamic> _formData = {
    'civilNIC': '',
    'civilUserName': '',
    'vehicalNumber': '',
    'offence': '',
    'issueLocation': '',
    'date': '',
    'time': '',
    'policeId': '',
    'fineManagementId': '',
    'isPaid': false,
  };

  bool _isLoading = false;
  bool _isSubmitting = false;
  String? _error;
  List<dynamic> _allUsers = [];
  List<dynamic> _filteredUsers = [];
  List<dynamic> _offences = [];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _formData['date'] =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
    _formData['time'] =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
    _dateController.text = _formData['date'];
    _timeController.text = _formData['time'];
    _formData['policeId'] = ''; // Replace with actual officer ID
    _fetchInitialData();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final offencesResponse = await _apiService.getAllFines();
      if (offencesResponse != null && offencesResponse is List) {
        setState(() {
          _offences = offencesResponse;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load offences';
      });
      debugPrint('Error loading offences: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _selectOffence(String? offenceName) {
    if (offenceName == null) return;

    final selectedOffence =
        _offences.firstWhere((o) => o['offence']?.toString() == offenceName);
    print('selectedOffence: $selectedOffence');
    setState(() {
      _formData['offence'] = offenceName;
      _formData['fineManagementId'] = selectedOffence?['_id'] ?? '';
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _formData['date'] =
            "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        _dateController.text = _formData['date'];
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        _formData['time'] =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
        _timeController.text = _formData['time'];
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _error = 'Please fill all required fields correctly';
      });
      return;
    }

    if (_formData['fineManagementId'].isEmpty) {
      setState(() {
        _error = 'Please select an offence';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      final submitData = Map<String, dynamic>.from(_formData);
      submitData.remove('offence');

      final result = await _apiService.addOffenseRecord(submitData);

      if (result != null && result['success'] == true) {
        widget.onSubmit(submitData);
        widget.onClose();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Fine added successfully')),
        );
      } else {
        setState(() {
          _error = result?['message'] ?? 'Failed to add fine';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Issue New Fine',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(8),
                  color: Colors.red[100],
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Civilian NIC *',
                  hintText: 'Format: 993090809V',
                ),
                initialValue: _formData['civilNIC'],
                onChanged: (value) => _formData['civilNIC'] = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'NIC is required';
                  }
                  if (!RegExp(r'^[0-9]{9}[VvXx]$').hasMatch(value)) {
                    return 'Invalid NIC format';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Civilian Name *'),
                initialValue: _formData['civilUserName'],
                onChanged: (value) => _formData['civilUserName'] = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Name is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Vehicle Number'),
                initialValue: _formData['vehicalNumber'],
                onChanged: (value) => _formData['vehicalNumber'] = value,
              ),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Offence *'),
                value:
                    _formData['offence'].isEmpty ? null : _formData['offence'],
                items: _offences.map<DropdownMenuItem<String>>((offence) {
                  return DropdownMenuItem<String>(
                    value: offence['offence']?.toString(),
                    child: Text(
                        '${offence['offence']} - ${offence['fine']} (LKR)'),
                  );
                }).toList(),
                onChanged: _selectOffence,
                validator: (value) {
                  if (value == null) {
                    return 'Please select an offence';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Issue Location *'),
                initialValue: _formData['issueLocation'],
                onChanged: (value) => _formData['issueLocation'] = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Location is required';
                  }
                  return null;
                },
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Date'),
                      controller: _dateController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      decoration: const InputDecoration(labelText: 'Time'),
                      controller: _timeController,
                      readOnly: true,
                      onTap: () => _selectTime(context),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : widget.onClose,
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitForm,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text('Submit Fine'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
