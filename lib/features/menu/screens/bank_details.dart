
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '../../../core/widgets/customtext_widget.dart';

class BankDetails extends StatefulWidget {
  const BankDetails({super.key});

  @override
  State<BankDetails> createState() => _BankDetailsState();
}

class _BankDetailsState extends State<BankDetails> {
  Future<List<dynamic>> getBanks() async {
    var headers = {
      'X-Secret-Key': 'IfiuH/Ox6QKC3jP6ES6Y+aGYuGJEAOkbJb',
    };
    var request = http.Request(
        'GET', Uri.parse('https://api.task.aurify.ae/user/get-banks/66e994239654078fd531dc2a'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseString = await response.stream.bytesToString();
      Map<String, dynamic> jsonResponse = json.decode(responseString);
      return jsonResponse['bankInfo']['bankDetails']; // Extracting bank list
    } else {
      throw Exception("Failed to load banks: ${response.reasonPhrase}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const CustomTextWidget(
          text: "Bank Details",
          color: Colors.white,
          weight: FontWeight.w700,
          fontSizeMultiplier: 0.05,
        ),
        centerTitle: false,
        titleSpacing: 0,
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_outlined, color: Colors.white),
        ),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: getBanks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: const TextStyle(color: Colors.white)));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
                child: Text('No bank details available',
                    style: TextStyle(color: Colors.white)));
          }

          List<dynamic> bankList = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: bankList.length,
            itemBuilder: (context, index) {
              var bank = bankList[index];
              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  title: Text(
                    bank['holderName'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Bank: ${bank['bankName']}"),
                      Text("Account: ${bank['accountNumber']}"),
                      Text("IBAN: ${bank['iban']}"),
                      Text("IFSC: ${bank['ifsc']}"),
                      Text("Branch: ${bank['branch']}"),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: bank['accountNumber']));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("${bank['bankName']} Account Number copied")),
                      );
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
