import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:marquee/marquee.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../core/globals.dart';

class SpotRate extends StatefulWidget {
  const SpotRate({super.key});

  @override
  State<SpotRate> createState() => _SpotRateState();
}

class _SpotRateState extends State<SpotRate> {
  final controller = PageController(viewportFraction: 0.8, keepPage: true);

  int currentIndex = 0;
  final String adminId = '66e994239654078fd531dc2a';
  final String socketSecretKey = 'aurify@123';
  final String baseUrl = "https://api.task.aurify.ae";
  Map<String, dynamic> marketData = {};
  List<dynamic> commodities = [];
  List<dynamic> commoditiesList = [];
  List<dynamic> news = [];
  String? serverURL;
  String? error;
  late Future<String> futureNewsTitle;

  @override
  void initState() {
    super.initState();
    fetchData();
    futureNewsTitle = fetchNewsTitle();
  }

  Color getMetalColor(String metalName) {
    switch (metalName.toLowerCase()) {
      case "gold":
        return Colors.amber;
      case "silver":
        return Colors.grey;
      case "copper":
        return Colors.brown;
      case "platinum":
        return Colors.blueGrey;
      default:
        return Colors.white;
    }
  }

  Future<void> fetchData() async {
    try {
      final spotRatesRes = await fetchSpotRates(adminId);
      final serverURLRes = await fetchServerURL();
      final commoditiesRes = await fetchCommodities(adminId);
      // final newsRes = await fetchNews(adminId);

      setState(() {
        commodities = commoditiesRes['commodities'];
        commoditiesList = spotRatesRes['info']['commodities'];
        serverURL = serverURLRes['info']['serverURL'];
        // news = newsRes['news']['news'];
      });
      if (serverURL != null) {
        connectSocket(serverURL!);
      }
    } catch (e) {
      setState(() => error = "An error occurred while fetching data");
      if (kDebugMode) {
        print("Error fetching data: $e");
      }
    }
  }

  Future<String> fetchNewsTitle() async {
    try {
      print("Fetching news...");

      final response = await http.get(
        Uri.parse("https://api.task.aurify.ae/user/get-news/66e994239654078fd531dc2a"),
        headers: {
          "Accept": "application/json",
          "X-Secret-Key": "IfiuH/Ox6QKC3jP6ES6Y+aGYuGJEAOkbJb" // Corrected header
        },
      );

      print("Response Status Code: ${response.statusCode}");
      print("Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Parsed Data: $data");

        if (data['success'] == true && data.containsKey("news")) {
          List<dynamic> newsList = data["news"]["news"] ?? [];

          if (newsList.isNotEmpty) {
            String titles = newsList.map((news) => news['title']).join("  |  ");
            print("Extracted Titles: $titles");
            return titles;
          } else {
            return "No news available";
          }
        } else {
          return "No news available";
        }
      } else {
        print("Failed to load news: ${response.reasonPhrase}");
        return "Failed to load news: ${response.statusCode}";
      }
    } catch (e) {
      print("Error fetching news: $e");
      return "Error fetching news";
    }
  }



  void connectSocket(String url) {
    IO.Socket socket = IO.io(url, <String, dynamic>{
      'query': {'secret': socketSecretKey},
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.on('connect', (data) {
      if (kDebugMode) {
        print('Connected to WebSocket server');
      }
      Timer.periodic(const Duration(seconds: 1), (timer) {
        socket.emit('request-data', [commodities]);
      });
    });

    socket.on('disconnect', (_) => print('Disconnected from WebSocket server'));

    // socket.on('market-data', (data) {
    //   if (kDebugMode) {
    //     print("Received market data: $data");
    //   }
    //   if (data != null && data['epic'] != null) {
    //     if (mounted) {
    //       setState(() {
    //         marketData[data['epic']] = {
    //           ...?marketData[data['epic']],
    //           ...data,
    //           'bidChanged': marketData[data['epic']] != null &&
    //               data['bid'] != marketData[data['epic']]['bid']
    //               ? (data['bid'] > marketData[data['epic']]['bid'] ? 'up' : 'down')
    //               : null,
    //         };
    //       });
    //     }
    //
    //   } else {
    //     if (kDebugMode) {
    //       print("Received malformed market data: $data");
    //     }
    //   }
    // });
    socket.on('market-data', (data) {
      if (kDebugMode) {
        print("Received market data: $data");
      }
      if (data != null && data['epic'] != null) {
        if (mounted) {
          setState(() {
            marketData[data['epic']] = {
              ...?marketData[data['epic']],
              ...data,
              'bidChanged': marketData[data['epic']] != null &&
                      data['bid'] != marketData[data['epic']]['bid']
                  ? (data['bid'] > marketData[data['epic']]['bid']
                      ? 'up'
                      : 'down')
                  : null,
            };
          });
        }
      } else {
        if (kDebugMode) {
          print("Received malformed market data: $data");
        }
      }
    });

    socket.on('error', (error) {
      if (kDebugMode) {
        print("WebSocket error: $error");
      }
      setState(() => this.error = "An error occurred while receiving data");
    });
  }

  Map<String, double> getPrice({required Map<String, dynamic> commodity}) {
    if (commodity == null || marketData == null) {
      return {"buy": 0.0, "sell": 0.0};
    }

    String metalKey = commodity['metal']?.toUpperCase();
    if (metalKey == null || marketData[metalKey] == null) {
      return {"buy": 0.0, "sell": 0.0};
    }

    var marketDetails = marketData[metalKey];
    double bid = marketDetails['bid'] != null
        ? double.parse(marketDetails['bid'].toString())
        : 0.0;
    double ask = marketDetails['offer'] != null
        ? double.parse(marketDetails['offer'].toString())
        : 0.0;
    double unit = commodity['unit'] != null
        ? double.parse(commodity['unit'].toString())
        : 0.0;
    String weight = commodity['weight']?.toString() ?? "GM";
    double buyCharge = commodity['buyCharge'] != null
        ? double.parse(commodity['buyCharge'].toString())
        : 0.0;
    double sellCharge = commodity['sellCharge'] != null
        ? double.parse(commodity['sellCharge'].toString())
        : 0.0;
    double buyPremium = commodity['buyPremium'] != null
        ? double.parse(commodity['buyPremium'].toString())
        : 0.0;
    double sellPremium = commodity['sellPremium'] != null
        ? double.parse(commodity['sellPremium'].toString())
        : 0.0;
    double purity = commodity['purity'] != null
        ? double.parse(commodity['purity'].toString())
        : 0.0;

    Map<String, double> unitMultiplierMap = {
      "GM": 1.0,
      "KG": 1000.0,
      "TTB": 116.64,
      "TOLA": 11.664,
      "OZ": 31.1034768,
    };

    double unitMultiplier = unitMultiplierMap[weight] ?? 1.0;
    double purityPower = purity / 1000;

    double biddingValue = bid + buyPremium;
    double askingValue = ask + sellPremium;
    double biddingPrice = (biddingValue / 31.103) * 3.674;
    double askingPrice = (askingValue / 31.103) * 3.674;

    double buyPrice =
        (biddingPrice * unitMultiplier * unit * purityPower) + buyCharge;
    double sellPrice =
        (askingPrice * unitMultiplier * unit * purityPower) + sellCharge;

    return {
      "buy": buyPrice,
      "sell": sellPrice,
    };
  }

  Widget _buildRateCard({
    required String title,
    required String bid,
    required String ask,
    required String low,
    required String high,
    required Color color,
    required Color textColor,
    required bool isDarkMode,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'BID: $bid',
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                Text(
                  'ASK: $ask',
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'LOW: $low',
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                Text(
                  'HIGH: $high',
                  style: TextStyle(
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(w * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: w * 0.15,
              ),
              Center(
                child: Text(
                  "SPOT RATE",
                  style: TextStyle(
                      color: Colors.amber,
                      fontSize: w * 0.06,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: w * 0.05),
              if (marketData.isEmpty)
                const Center(child: CircularProgressIndicator())
              else
                // CarouselSlider(
                //       options: CarouselOptions(
                //   autoPlay: true,
                //   autoPlayAnimationDuration: const Duration(milliseconds: 200),
                //   onPageChanged: (index, reason) {
                //     currentIndex = index;
                //     setState(() {});
                //   },
                //   height: w * 0.4,
                //   // enlargeCenterPage: true
                // ),
                //   items: commodities.map((commodity) {
                //     final data = marketData[commodity.toUpperCase()];
                //     if (data == null) return const SizedBox.shrink();
                //     return _buildRateCard(
                //       title: commodity,
                //       bid: data['bid'].toString(),
                //       ask: data['offer'].toString(),
                //       low: data['low'].toString(),
                //       high: data['high'].toString(),
                //       color: getMetalColor(commodity),
                //       textColor: Colors.white,
                //       isDarkMode: false,
                //     );
                //   }).toList(),),
                CarouselSlider(
                  options: CarouselOptions(
                    autoPlay: true,
                    autoPlayAnimationDuration:
                        const Duration(milliseconds: 200),
                    onPageChanged: (index, reason) {
                      currentIndex = index;
                      setState(() {});
                    },
                    height: w * 0.4,
                  ),
                  items: commodities.map((commodity) {
                    if (kDebugMode) {
                      print("Commodity: $commodity");
                      print(
                          "Market Data for $commodity: ${marketData[commodity.toUpperCase()]}");
                    }
                    final data = marketData[commodity.toUpperCase()];
                    if (data == null) return const SizedBox.shrink();
                    return _buildRateCard(
                      title: commodity,
                      bid: data['bid'].toString(),
                      ask: data['offer'].toString(),
                      low: data['low'].toString(),
                      high: data['high'].toString(),
                      color: getMetalColor(commodity),
                      textColor: Colors.white,
                      isDarkMode: false,
                    );
                  }).toList(),
                ),
              Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: w * 0.03),
                  child: AnimatedSmoothIndicator(
                    activeIndex: (currentIndex.isFinite && !currentIndex.isNaN)
                        ? currentIndex.clamp(
                            0,
                            (commodities.length - 1)
                                .clamp(0, double.infinity)
                                .toInt())
                        : 0,
                    // Default to 0 if NaN or Infinity
                    count: commodities.isNotEmpty ? commodities.length : 1,
                    // Ensure count is at least 1
                    effect: ExpandingDotsEffect(
                      dotHeight: w * 0.02,
                      dotWidth: w * 0.02,
                      spacing: 6,
                      dotColor: Colors.amber.shade50,
                      activeDotColor: Colors.amber,
                      paintStyle: PaintingStyle.fill,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: w * 0.05,
              ),
              CommodityRatesTable(
                commoditiesList: commoditiesList
                    .map((e) => e as Map<String, dynamic>)
                    .toList(),
                marketData: marketData,
                getPriceFn: getPrice,
              ),
              FutureBuilder<String>(
                future: futureNewsTitle,
                builder: (context, snapshot) {
                  print("FutureBuilder State: ${snapshot.connectionState}");

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return SizedBox(
                      height: w * 0.05,
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );
                  }

                  if (snapshot.hasError || !snapshot.hasData) {
                    print("FutureBuilder Error: ${snapshot.error}");
                    return SizedBox(
                      height: w * 0.05,
                      child: const Center(
                        child: Text(
                          "Failed to load news",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }

                  print("FutureBuilder Data: ${snapshot.data}");
                  return SizedBox(
                    height: w * 0.05,
                    child: Marquee(
                      text: snapshot.data ?? "No news available",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: w * 0.045,
                      ),
                      scrollAxis: Axis.horizontal,
                      blankSpace: 20.0,
                      velocity: 100.0,
                      pauseAfterRound: const Duration(seconds: 1),
                      startPadding: 10.0,
                      accelerationDuration: const Duration(seconds: 1),
                      accelerationCurve: Curves.linear,
                      decelerationDuration: const Duration(milliseconds: 500),
                      decelerationCurve: Curves.easeOut,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              if (error != null)
                Text(
                  error!,
                  style: const TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<Map<String, dynamic>> fetchSpotRates(String adminId) async {
  var headers = {'X-Secret-Key': 'IfiuH/Ox6QKC3jP6ES6Y+aGYuGJEAOkbJb'};
  var request = http.Request('GET',
      Uri.parse('https://api.task.aurify.ae/user/get-spotrates/$adminId'));
  request.headers.addAll(headers);
  http.StreamedResponse response = await request.send();
  var res = await response.stream.bytesToString();
  return response.statusCode == 200
      ? jsonDecode(res)
      : throw Exception("Failed to load spot rates");
}

Future<Map<String, dynamic>> fetchServerURL() async {
  var headers = {'X-Secret-Key': 'IfiuH/Ox6QKC3jP6ES6Y+aGYuGJEAOkbJb'};
  var request = http.Request(
      'GET', Uri.parse('https://api.task.aurify.ae/user/get-server'));
  request.headers.addAll(headers);
  http.StreamedResponse response = await request.send();
  var res = await response.stream.bytesToString();
  return response.statusCode == 200
      ? jsonDecode(res)
      : throw Exception("Failed to load server URL");
}



Future<Map<String, dynamic>> fetchCommodities(String adminId) async {
  var headers = {'X-Secret-Key': 'IfiuH/Ox6QKC3jP6ES6Y+aGYuGJEAOkbJb'};
  var request = http.Request('GET',
      Uri.parse('https://api.task.aurify.ae/user/get-commodities/$adminId'));
  request.headers.addAll(headers);
  http.StreamedResponse response = await request.send();
  var res = await response.stream.bytesToString();
  return response.statusCode == 200
      ? jsonDecode(res)
      : throw Exception("Failed to load commodities");
}

class CommodityRatesTable extends StatelessWidget {
  final List<Map<String, dynamic>> commoditiesList;
  final Map<String, dynamic> marketData;
  final Map<String, double> Function({required Map<String, dynamic> commodity})
      getPriceFn;

  const CommodityRatesTable({
    super.key,
    required this.commoditiesList,
    required this.marketData,
    required this.getPriceFn,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.amber.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              'Commodity Rates',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
              },
              children: [
                // Table Header
                const TableRow(
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: Colors.grey)),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Commodity',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Weight',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text('Price (AED)',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                ...commoditiesList.map(
                  (commodity) {
                    String commodityKey =
                        "${commodity['metal']} ${commodity['purity']}"
                            .toUpperCase();
                    String kg = "${commodity['unit']} ${commodity['weight']}";
                    var marketDetails = marketData[commodityKey] ?? {};
                    String price = marketDetails.isNotEmpty
                        ? marketDetails['bid']?.toString() ?? 'N/A'
                        : 'N/A';
                    final priceMap = getPriceFn(commodity: commodity);
                    final buyPrice =
                        priceMap['buy']?.toStringAsFixed(2) ?? 'N/A';
                    final sellPrice =
                        priceMap['sell']?.toStringAsFixed(2) ?? 'N/A';
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(commodityKey),
                        ),
                        Padding(
                          padding: EdgeInsets.all(8),
                          child: Text(kg),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(sellPrice),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
