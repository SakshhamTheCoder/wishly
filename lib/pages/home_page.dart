import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:wishly/components/default_scaffold.dart';
import 'package:wishly/pages/add_wish.dart';
import 'package:wishly/pages/landing_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final storage = FlutterSecureStorage();
  Map<String, String> wishes = {};

  @override
  void initState() {
    super.initState();
    _getWishlys();
  }

  void _getWishlys() async {
    final all = await storage.readAll();
    setState(() {
      wishes = all;
      wishes.removeWhere((key, value) => key == "isFirstTime");
    });
  }

  void _removeWishly(String key) async {
    await storage.delete(key: key);
    _getWishlys();
  }

  void editWishly(String key, String newDate, String newMessage) async {
    if (newDate.isEmpty || newMessage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a valid date and message.")),
      );
      return;
    }
    try {
      await storage.write(key: key, value: "$newDate|$newMessage");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("${key.split('|')[1]}'s details updated!"),
        ),
      );
      _getWishlys();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to update Wishly. Please try again.")),
      );
    }
  }

  void _openEditDialog(String key, String currentValue) {
    final TextEditingController messageController = TextEditingController(text: currentValue.split('|')[1]);
    final TextEditingController dateController =
        TextEditingController(text: DateTime.parse(currentValue.split('|')[0]).toLocal().toString().split(' ')[0]);
    DateTime? selectedDate = DateTime.parse(currentValue.split('|')[0]);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Expanded(child: Text("Edit Wishly for ${key.split('|')[1]}")),
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
                      initialDate: selectedDate ?? DateTime.now(),
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
              onPressed: () {
                editWishly(key, dateController.text, messageController.text);
                Navigator.of(context).pop();
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
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("Your"),
            SizedBox(width: 8),
            Text(
              "WISHLY",
              style: TextStyle(
                fontSize: 32,
                height: 0.8,
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
            ),
            Text("'s"),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              storage.deleteAll();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => const LandingPage(),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        label: const Text("Add a WISHLY"),
        onPressed: () => Navigator.of(context)
            .push(
              MaterialPageRoute(
                builder: (context) => const AddPage(),
              ),
            )
            .then((_) => _getWishlys()),
        icon: const Icon(Icons.add),
      ),
      child: wishes.isEmpty
          ? const Center(
              child: Text(
                "No wishes yet. Add some using the button below!",
              ),
            )
          : ListView.builder(
              itemCount: wishes.length,
              itemBuilder: (context, index) {
                final key = wishes.keys.elementAt(index);

                return ListTile(
                  title: Text(key.split("|")[1]),
                  subtitle: Text(
                    () {
                      String dateString = wishes[key]!.split("|")[0];
                      try {
                        DateTime date = DateTime.parse(dateString);
                        var formattedDate = DateFormat('MMMM dd, yyyy').format(date);
                        return formattedDate;
                      } catch (e) {
                        return 'Invalid date';
                      }
                    }(),
                  ),
                  leading: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text("Delete Wishly"),
                            content: const Text("Are you sure you want to delete this Wishly?"),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _removeWishly(key);
                                  Navigator.of(context).pop();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.error,
                                  foregroundColor: Theme.of(context).colorScheme.onError,
                                ),
                                child: const Text("Delete"),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    _openEditDialog(key, wishes[key]!);
                  },
                );
              },
            ),
    );
  }
}
