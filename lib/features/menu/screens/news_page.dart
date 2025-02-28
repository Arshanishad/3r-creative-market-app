import 'package:flutter/material.dart';
import '../../../core/globals.dart';
import '../../../core/widgets/customtext_widget.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsListingPage extends StatefulWidget {
  const NewsListingPage({super.key});

  @override
  State<NewsListingPage> createState() => _NewsListingPageState();
}

class _NewsListingPageState extends State<NewsListingPage> {



  final Map<int, bool> isExpandedMap = {};
  Future<List<dynamic>> getNews() async {
    var headers = {
      'X-Secret-Key': 'IfiuH/Ox6QKC3jP6ES6Y+aGYuGJEAOkbJb'
    };
    var request = http.Request(
        'GET', Uri.parse('https://api.task.aurify.ae/user/get-news/66e994239654078fd531dc2a'));
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();

    if (response.statusCode == 200) {
      String responseString = await response.stream.bytesToString();
      Map<String, dynamic> jsonResponse = json.decode(responseString);
      return jsonResponse['news']['news']; // Extracting the news list
    } else {
      throw Exception("Failed to load news: ${response.reasonPhrase}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const CustomTextWidget(
          text: "News",
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
          icon: const Icon(
            Icons.arrow_back_outlined,
            color: Colors.white,
          ),
        ),
      ),
      body:FutureBuilder<List<dynamic>>(
          future: getNews(),
        builder: (context,snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No news available'));
          }
          List<dynamic> newsList = snapshot.data!;
          return ListView.builder(
            padding: EdgeInsets.all(w*0.03),
            itemCount: newsList.length,
            itemBuilder: (context, index) {
              return NewsCard(
                news: newsList[index],
                isExpanded: isExpandedMap[index] ?? false,
                onExpandToggle: () {
                  setState(() {
                    isExpandedMap[index] = !(isExpandedMap[index] ?? false);
                  });
                },
              );
            },
          );
        }


      ),
    );
  }
}

class NewsCard extends StatefulWidget {
  final Map<String, dynamic> news; // Changed from Map<String, String>
  final bool isExpanded;
  final VoidCallback onExpandToggle;

  const NewsCard({
    super.key,
    required this.news,
    required this.isExpanded,
    required this.onExpandToggle,
  });

  @override
  NewsCardState createState() => NewsCardState();
}

class NewsCardState extends State<NewsCard> {
  bool isOverflowing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkOverflow());
  }

  void _checkOverflow() {
    final textSpan = TextSpan(
      text: widget.news['description']?.toString() ?? "", // Ensuring null safety
      style: const TextStyle(),
    );

    final textPainter = TextPainter(
      text: textSpan,
      maxLines: 2,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: w * 0.9);
    setState(() {
      isOverflowing = textPainter.didExceedMaxLines;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: w * 0.025),
      child: ListTile(
        contentPadding: EdgeInsets.all(w * 0.03),
        title: Text(
          widget.news['title']?.toString() ?? "No Title", // Null check
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.news['createdAt']?.toString() ?? "No Date",
              style: TextStyle(fontSize: w * 0.033, color: Colors.grey),
            ),
            SizedBox(height: w * 0.02),
            SizedBox(
              width: w * 0.9,
              child: Text(
                widget.news['description']?.toString() ?? "No Description",
                maxLines: widget.isExpanded ? null : 2,
                overflow: widget.isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              ),
            ),
            if (isOverflowing)
              Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: widget.onExpandToggle,
                  child: Text(
                    widget.isExpanded ? "Read Less" : "Read More",
                    style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
