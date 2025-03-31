import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:wishly/components/default_scaffold.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}

class _AddPageState extends State<AddPage> {
  List<Contact> contacts = [];
  List<Contact> filteredContacts = [];
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  bool isLoading = false; // To track loading state

  @override
  void initState() {
    super.initState();
    _fetchContacts();
  }

  void _fetchContacts() {
    setState(() {
      isLoading = true; // Start loading
    });

    Permission.contacts.status.then((status) {
      if (status.isDenied) {
        Permission.contacts.request().then((result) {
          if (result.isDenied || result.isPermanentlyDenied) {
            _showPermissionDeniedSnackBar();
          } else if (result.isGranted) {
            _loadContacts();
          }
        });
      } else if (status.isGranted) {
        _loadContacts();
      }
    });
  }

  void _loadContacts() {
    FlutterContacts.getContacts(withProperties: true, withThumbnail: true).then((fetchedContacts) {
      setState(() {
        contacts = fetchedContacts;
        filteredContacts = fetchedContacts;
        isLoading = false; // Stop loading when contacts are fetched
      });
    });
  }

  void _showPermissionDeniedSnackBar() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Permission denied"),
          action: SnackBarAction(
            label: "Settings",
            onPressed: () async {
              await openAppSettings();
            },
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _openContactDialog(Contact contact) {
    TextEditingController messageController = TextEditingController(text: "Happy Birthday, ${contact.displayName}!");
    TextEditingController dateController = TextEditingController();
    DateTime? selectedDate;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              const SizedBox(width: 8),
              Expanded(child: Text("Create Wishly for ${contact.displayName}")),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  controller: messageController,
                  decoration: const InputDecoration(
                    labelText: "Custom Message",
                    prefixIcon: Icon(Icons.message),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: "Birth Date",
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        selectedDate = pickedDate;
                        dateController.text = pickedDate.toLocal().toString().split(' ')[0];
                      });
                    }
                  },
                ),
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
              onPressed: () async {
                if (selectedDate != null) {
                  await _storage.write(
                    key: "${contact.id}|${contact.displayName}|${contact.phones.first.number}",
                    value: "${selectedDate!.toIso8601String()}|${messageController.text}|false",
                  );
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("${contact.displayName}'s details saved!"),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Please select a birth date.")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
              ),
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DefaultScaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Add a"),
            SizedBox(width: 8),
            Text(
              "WISHLY",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchBar(
              elevation: WidgetStateProperty.all(0),
              backgroundColor: WidgetStateProperty.all(colorScheme.surfaceContainer),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 16)),
              hintText: "Search contacts",
              leading: const Icon(Icons.search),
              onChanged: (value) {
                setState(() {
                  filteredContacts = contacts.where((contact) {
                    return contact.displayName.toLowerCase().contains(value.toLowerCase());
                  }).toList();
                });
              },
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator()) // Show loader while fetching contacts
                : filteredContacts.isEmpty
                    ? const Center(child: Text("No contacts found"))
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: filteredContacts.length,
                          itemBuilder: (context, index) {
                            final contact = filteredContacts[index];
                            return Card(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 4,
                              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: ListTile(
                                leading: CircleAvatar(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(100),
                                    child: contact.thumbnail != null
                                        ? Image.memory(contact.thumbnail!)
                                        : const Icon(Icons.person, color: Colors.white),
                                  ),
                                ),
                                title: Text(contact.displayName),
                                subtitle: Text(
                                  contact.phones.isNotEmpty ? contact.phones.first.number : "No phone number available",
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () => _openContactDialog(contact),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
