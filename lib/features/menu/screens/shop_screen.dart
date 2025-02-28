
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/widgets/customtext_widget.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  Future<List<Map<String, dynamic>>> getShopCategories() async {
    var headers = {
      'X-Secret-Key': 'IfiuH/Ox6QKC3jP6ES6Y+aGYuGJEAOkbJb'
    };
    var request = http.Request(
        'GET', Uri.parse('https://api.task.aurify.ae/user/main-categories/66e994239654078fd531dc2a'));

    request.headers.addAll(headers);
    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseString = await response.stream.bytesToString();
      Map<String, dynamic> jsonResponse = json.decode(responseString);
      List<dynamic> data = jsonResponse['data'];

      return data.map((item) => {
        "id": item['_id'],
        "name": item['name'],
        "description": item['description'] ?? 'No description available',
        "image": item['image'] ?? 'https://via.placeholder.com/150', // Fallback image
      }).toList();
    } else {
      throw Exception("Failed to load categories: ${response.reasonPhrase}");
    }
  }

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width; // Define `w`

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_outlined,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.amber,
        automaticallyImplyLeading: false,
        title: const CustomTextWidget(
          text: "Shop",
          color: Colors.black,
          weight: FontWeight.w700,
          fontSizeMultiplier: 0.05,
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(w * 0.03),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: getShopCategories(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No categories found', style: TextStyle(color: Colors.white)));
            }

            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: w * 0.02,
                crossAxisSpacing: w * 0.02,
                childAspectRatio: 0.8,
              ),
              itemCount: snapshot.data!.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                var category = snapshot.data![index];
                return CardWidget(
                  name: category['name'],
                  image: category['image'],
                  description: category['description'],
                );
              },
            );
          },
        ),
      ),
    );
  }
}




class CardWidget extends StatelessWidget {
  final String name;
  final String image;
  final String description;

  const CardWidget({super.key, required this.name, required this.image, required this.description});

  @override
  Widget build(BuildContext context) {
    double w = MediaQuery.of(context).size.width;

    return Card(
      color: Colors.amber.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Stack(
              children: [
                Container(
                  height: w * 0.25,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: image,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(), // Show loading indicator
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade300, // Background for error case
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.broken_image,
                        size: w * 0.1,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: w * 0.02,
                  top: w * 0.02,
                  child: CircleAvatar(
                    radius: w * 0.03,
                    backgroundColor: Colors.grey.shade200,
                    child: Icon(
                      CupertinoIcons.heart_fill,
                      color: Colors.red,
                      size: w * 0.04,
                    ),
                  ),
                ),
              ],
            ),
            CustomTextWidget(
              text: name,
              fontSizeMultiplier: 0.035,
            ),
            CustomTextWidget(
              text: description,
              fontSizeMultiplier: 0.025,
              color: Colors.grey,
              maxLines: 2,
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  CupertinoIcons.cart_fill_badge_plus,
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


