import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:send_sms/message_provider.dart';

class ContactList extends StatefulWidget {
  const ContactList({super.key});

  @override
  State<ContactList> createState() => _ContactListState();
}

class _ContactListState extends State<ContactList>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
   final TextEditingController _numberController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MessageProvider>(context, listen: false).loadSavedNumbers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showNumberDialog(BuildContext context) {
   

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter a Number'),
          content: TextField(
            controller: _numberController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Enter numbers only',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            Consumer<MessageProvider>(
              builder: (context, provider, child) {
                return TextButton(
                  child: const Text('Submit'),
                  onPressed: () {
                    if (_numberController.text.isNotEmpty) {
                      provider.saveNumber(_numberController.text);
                    }
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Contact List'),
            actions: [
              IconButton(
                onPressed: () {
                  _showNumberDialog(context);
                },
                icon: Icon(Icons.add_box),
              ),
            ],

            bottom: TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Saved Numbers'),
                Tab(text: 'Import Contacts'),
              ],
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Saved Numbers Tab
                      ListView.builder(
                        itemCount: provider.savedNumbers.length,
                        itemBuilder: (context, index) {
                          final contact = provider.savedNumbers[index];
                          return Card(
                            color: Colors.green,
                            child: ListTile(
                              title: Text(
                                contact,
                                style: TextStyle(color: Colors.white),
                              ),
                              selectedTileColor: Colors.blue.withOpacity(0.1),
                              trailing: const Icon(
                                Icons.remove,
                                color: Colors.white,
                              ),
                              onTap: () {
                                provider.removeNumber(contact);
                              },
                            ),
                          );
                        },
                      ),
                      // Import Contacts Tab
                      provider.contacts.isEmpty
                          ? const Center(child: Text('No contacts available'))
                          : ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: provider.contacts.length,
                            itemBuilder: (context, index) {
                              final contact = provider.contacts[index];
                              final phoneNumber =
                                  contact.phones.isNotEmpty
                                      ? contact.phones.first.number
                                      : 'No number';
                              return Card(
                                child: ListTile(
                                  leading: const Icon(Icons.person),
                                  title: Text(contact.displayName),
                                  subtitle: Text(phoneNumber),
                                  selected:
                                      provider.selectedPhoneNumber ==
                                      phoneNumber,
                                  selectedTileColor: Colors.blue.withOpacity(
                                    0.1,
                                  ),
                                  trailing: const Icon(Icons.add),
                                  onTap: () {
                                    provider.saveNumber(phoneNumber);
                                  },
                                ),
                              );
                            },
                          ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
