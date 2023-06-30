import 'package:flutter/material.dart';

extension ColorExtension on String {
  toColor() {
    var hexColor = this.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    if (hexColor.length == 8) {
      return Color(int.parse("0x$hexColor"));
    }
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(left: 15, top: 20.0),
              child: Text(
                "Hi User!",
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 15, top: 10.0),
              child: Text(
                "Here is your summary for the day",
                style: TextStyle(fontSize: 20),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 15, top: 10.0),
              child: Text(
                "General AQI Level",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 15, top: 10.0, right: 15),
              width: 400,
              // height: 50,
              decoration: BoxDecoration(
                color: '#b7decc'.toColor(),
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  "Normal",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: '#255A34'.toColor(),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 15, top: 10.0, right: 15),
              child: Text(
                "Good job! Lorem ipsum dolor sit amet, consectetur adipiscing elit.",
                overflow: TextOverflow.clip,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 20,
                  //fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 15, top: 10.0, right: 15),
              child: Row(
                children: [
                  Center(
                    child: Container(
                      width: 100,
                      height: 120,
                      decoration: BoxDecoration(
                          color: '#91C0D0'.toColor(),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/images/heart.png',
                              width: 55,
                              height: 55,
                            ),
                          ),
                          Center(
                            child: Text(
                              "56",
                              style: TextStyle(fontSize: 25),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Center(
                    child: Container(
                      width: 100,
                      height: 120,
                      decoration: BoxDecoration(
                          color: '#C8D2EB'.toColor(),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/images/bubbles.png',
                              width: 55,
                              height: 55,
                            ),
                          ),
                          Center(
                            child: Text(
                              "87",
                              style: TextStyle(fontSize: 25),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Center(
                    child: Container(
                      width: 100,
                      height: 120,
                      decoration: BoxDecoration(
                          color: 'FDEEB4'.toColor(),
                          borderRadius: BorderRadius.all(Radius.circular(10))),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/images/flowers.png',
                              width: 55,
                              height: 55,
                            ),
                          ),
                          Center(
                            child: Text(
                              "93",
                              style: TextStyle(fontSize: 25),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.only(left: 15, top: 10.0, right: 15),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    child: Text(
                      "BPM",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 20),
                  Container(
                    width: 100,
                    child: Text(
                      "SpO2",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(width: 20),
                  Container(
                    width: 100,
                    child: Text(
                      "Exposure Level",
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.clip,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.only(left: 15, top: 10.0, right: 15),
              child: Text(
                "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla ex nunc, faucibus ac sapien id, molestie lacinia nibh. Vivamus quis iaculis magna. Interdum et malesuada fames ac ante ipsum primis in faucibus. ",
                overflow: TextOverflow.clip,
                textAlign: TextAlign.justify,
                style: TextStyle(
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
