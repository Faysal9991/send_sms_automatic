// home_page.dart
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:send_sms/message_provider.dart';
import 'package:send_sms/select_from_contract.dart';
import 'package:send_sms/time_picker.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final List<String> simOptions = ['SIM 1', 'SIM 2', 'Dual SIM'];
 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MessageProvider>(context, listen: false).loadSavedNumbers();
      Provider.of<MessageProvider>(context, listen: false).sendSms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MessageProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.teal,
            leading: IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ContactList()),
                );
              },
              icon: Icon(Icons.contact_page),
            ),
            centerTitle: true,
            title: const Text('SMS Provider'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                spacing: 10,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              8.0,
                            ), // Adjust radius as needed
                          ),
                        ),
                        onPressed: () {
                          showMaterialModalBottomSheet(
                            context: context,
                            builder:
                                (context) => SizedBox(
                                  height: 400,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          itemCount: 20,
                                          itemBuilder: (context, index) {
                                            return InkWell(
                                              onTap: () {
                                                provider.changeDelayDuration(
                                                  index+1,context
                                                );
                                                Navigator.of(context).pop();
                                              },
                                              child: Card(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "Time ${index + 1} second",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          );
                        }, // Empty function, add your logic here
                        child: const Text(
                          "Duration",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              8.0,
                            ), // Adjust radius as needed
                          ),
                        ),
                        onPressed: () {
                                  showMaterialModalBottomSheet(
                            context: context,
                            builder:
                                (context) => SizedBox(
                                  height: 400,
                                  child: Column(
                                    children: [
                                      Expanded(
                                        child: ListView.builder(
                                          scrollDirection: Axis.vertical,
                                          itemCount: 20,
                                          itemBuilder: (context, index) {
                                            return InkWell(
                                              onTap: () {
                                                provider.changeSMSQuantity(
                                                  index + 1,
                                                  context,
                                                );
                                                Navigator.of(context).pop();
                                              },
                                              child: Card(
                                                child: Padding(
                                                  padding: const EdgeInsets.all(
                                                    8.0,
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "SMS Quantity ${index + 1}",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                          );
                    
                        }, // Empty function, add your logic here
                        child: const Text(
                          "Quantity",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      TimePickerButton(),
                    ],
                  ),
                  // SIM Selection
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: DropdownButton<String>(
                      value: provider.selectedSim,
                      isExpanded: true,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down),
                      onChanged: (String? newValue) {
                        provider.setSim(newValue);
                      },
                      items:
                          simOptions.map<DropdownMenuItem<String>>((
                            String value,
                          ) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.sim_card,
                                    color: Colors.blue,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(value),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      labelText: 'Write message',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onChanged: (value) => provider.setMessage(value),
                  ),
                  const SizedBox(height: 16),

                  // Send Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),),
                    onPressed:
                        provider.isProcessing
                            ? null
                            : () {

                              if(provider.smsQantity <=0){
                                   ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      "Please  select Minimum 1 Message",
                                    ),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }else{
                                provider.sendSmsUsingSim(
                                  context,
                                  _messageController.text,
                                  provider.simValue,
                                );
                              }
                            
                            },
                    child:
                        provider.isProcessing
                            ? const CircularProgressIndicator(
                              color: Colors.teal,
                            )
                            : const Text('Send SMS',style: TextStyle(color: Colors.white),),
                  ),

                  // Contact List
                  if (provider.contacts.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Saved Contacts:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                  ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
