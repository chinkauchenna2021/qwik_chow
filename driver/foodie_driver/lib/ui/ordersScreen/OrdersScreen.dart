import 'package:audioplayers/audioplayers.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodie_driver/constants.dart';
import 'package:foodie_driver/main.dart';
import 'package:foodie_driver/model/OrderModel.dart';
import 'package:foodie_driver/model/OrderProductModel.dart';
import 'package:foodie_driver/model/variant_info.dart';
import 'package:foodie_driver/services/FirebaseHelper.dart';
import 'package:foodie_driver/services/helper.dart';

class OrdersScreen extends StatefulWidget {
  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late Future<List<OrderModel>> ordersFuture;
  FireStoreUtils _fireStoreUtils = FireStoreUtils();
  List<OrderModel> ordersList = [];

  @override
  void initState() {
    super.initState();
    print("------>${ordersList.length}");
    ordersFuture = _fireStoreUtils.getDriverOrders(MyAppState.currentUser!.userID);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<OrderModel>>(
          future: ordersFuture,
          initialData: [],
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return Container(
                child: Center(
                  child: CircularProgressIndicator.adaptive(
                    valueColor: AlwaysStoppedAnimation(
                      Color(COLOR_PRIMARY),
                    ),
                  ),
                ),
              );
            if (!snapshot.hasData || (snapshot.data?.isEmpty ?? true)) {
              return Center(
                child: showEmptyState('No Previous Orders'.tr(), description: "Let's deliver food!".tr()),
              );
            } else {
              ordersList = snapshot.data!;
              return ListView.builder(itemCount: ordersList.length, padding: const EdgeInsets.all(12), itemBuilder: (context, index) => buildOrderItem(ordersList[index]));
            }
          }),
    );
  }

  Widget buildOrderItem(OrderModel orderModel) {
    double total = 0.0;
    total = 0.0;
    String extrasDisVal = '';
    orderModel.products.forEach((element) {
      total += element.quantity * double.parse(element.price);

      for (int i = 0; i < element.extras.length; i++) {
        extrasDisVal += '${element.extras[i].toString().replaceAll("\"", "")} ${(i == element.extras.length - 1) ? "" : ","}';
      }
    });

    print("id is ${orderModel.id}");
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(2),
            border: Border.all(color: Colors.grey.shade100, width: 0.1),
            boxShadow: [
              BoxShadow(color: Colors.grey.shade200, blurRadius: 2.0, spreadRadius: 0.4, offset: Offset(0.2, 0.2)),
            ],
            color: Colors.white),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              child: Container(
                height: 140,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(orderModel.products.first.photo),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(Colors.black.withOpacity(0.5), BlendMode.darken),
                  ),
                ),
                child: Center(
                  child: Text(
                    '${orderDate(orderModel.createdAt)} - ${orderModel.status}',
                    style: TextStyle(color: Colors.white, fontSize: 17),
                  ),
                ),
              ),
            ),
            ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: orderModel.products.length,
                padding: EdgeInsets.only(),
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  OrderProductModel product = orderModel.products[index];
                  VariantInfo? variantIno = product.variantInfo;
                  List<dynamic>? addon = product.extras;
                  String extrasDisVal = '';
                  for (int i = 0; i < addon!.length; i++) {
                    extrasDisVal += '${addon[i].toString().replaceAll("\"", "")} ${(i == addon.length - 1) ? "" : ","}';
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        minLeadingWidth: 10,
                        contentPadding: EdgeInsets.only(left: 10, right: 10),
                        visualDensity: VisualDensity(horizontal: 0, vertical: -4),
                        leading: CircleAvatar(
                          radius: 13,
                          backgroundColor: Color(COLOR_PRIMARY),
                          child: Text(
                            '${product.quantity}',
                            style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(
                          product.name,
                          style: TextStyle(color: isDarkMode(context) ? Colors.white : Color(0XFF333333), fontSize: 18, letterSpacing: 0.5, fontFamily: 'Poppinsr'),
                        ),
                        trailing: Text(
                          amountShow(
                              amount: double.parse((product.extrasPrice!.isNotEmpty && double.parse(product.extrasPrice!) != 0.0)
                                  ? (double.parse(product.extrasPrice!) + double.parse(product.price)).toString()
                                  : product.price)
                                  .toString()),
                          style: TextStyle(color: isDarkMode(context) ? Colors.grey.shade200 : Color(0XFF333333), fontSize: 17, letterSpacing: 0.5, fontFamily: 'Poppinsr'),
                        ),
                      ),
                      variantIno == null || variantIno.variantOptions!.isEmpty
                          ? Container()
                          : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Wrap(
                          spacing: 6.0,
                          runSpacing: 6.0,
                          children: List.generate(
                            variantIno.variantOptions!.length,
                                (i) {
                              return _buildChip("${variantIno.variantOptions!.keys.elementAt(i)} : ${variantIno.variantOptions![variantIno.variantOptions!.keys.elementAt(i)]}", i);
                            },
                          ).toList(),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 55, right: 10),
                        child: extrasDisVal.isEmpty
                            ? Container()
                            : Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            extrasDisVal,
                            style: TextStyle(fontSize: 16, color: Colors.grey, fontFamily: 'Poppinsr'),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Center(
                child: Text(
                  'Total : '.tr() + amountShow(amount: total.toString()),
                  style: TextStyle(color: Color(COLOR_PRIMARY), fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  final audioPlayer = AudioPlayer(playerId: "playerId");
  bool isPlaying = false;

  playSound() async {
    final path = await rootBundle.load("assets/audio/mixkit-happy-bells-notification-937.mp3");

    audioPlayer.setSourceBytes(path.buffer.asUint8List());
    audioPlayer.setReleaseMode(ReleaseMode.loop);
    //audioPlayer.setSourceUrl(url);
    audioPlayer.play(BytesSource(path.buffer.asUint8List()),
        volume: 15,
        ctx: AudioContext(
            android: AudioContextAndroid(
                contentType: AndroidContentType.music, isSpeakerphoneOn: true, stayAwake: true, usageType: AndroidUsageType.alarm, audioFocus: AndroidAudioFocus.gainTransient),
            iOS: AudioContextIOS(category: AVAudioSessionCategory.playback, options: [])));
  }
}

Widget _buildChip(String label, int attributesOptionIndex) {
  return Container(
    decoration: BoxDecoration(color: const Color(0xffEEEDED), borderRadius: BorderRadius.circular(4)),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.black,
        ),
      ),
    ),
  );
}
