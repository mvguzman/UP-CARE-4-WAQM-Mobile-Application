import 'package:flutter/material.dart';
import 'dart:math';
import 'device_provider.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'dart:async';

const TWO_PI = 2 * 3.14;

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

class Physiology extends StatelessWidget {
  Timer? _dataReadingTimer;
  bool _isDataReadingScheduled = false;

  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  List<int> a2 = [];
  List<int> b2 = [];

  final size = 275.0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Consumer<DeviceProvider>(builder: (context, deviceProvider, _) {
          return StreamBuilder<List<int>>(
            stream: dataStream2,
            builder: (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
              return Consumer<DeviceProvider>(
                  builder: (context, deviceProvider, _) {
                return StreamBuilder<List<int>>(
                  stream: dataStream2,
                  builder: (BuildContext context,
                      AsyncSnapshot<List<int>> snapshot) {
                    if (snapshot.hasError)
                      return Text('Error: ${snapshot.error}');

                    if (snapshot.connectionState == ConnectionState.active) {
                      var dataString2 = _dataParser(snapshot.data!);
                      var dataList2 = dataString2.split('w');

                      List<int> intList2 = dataList2
                          .map((String str) => int.tryParse(str) ?? 0)
                          .toList();

                      try {
                        a2.add(intList2[0]);
                        b2.add(intList2[1]);
                      } catch (e) {
                        a2.add(0);
                        b2.add(0);
                      }
                      hr = a2[a2.length - 1];
                      spo2 = b2[b2.length - 1];
                    } else if (snapshot.connectionState ==
                        ConnectionState.waiting) {
                      try {
                        hr = a2[a2.length - 1];
                        spo2 = b2[b2.length - 1];
                      } catch (e) {
                        hr = 0;
                        spo2 = 0;
                      }
                    } else {
                      return Text(
                          "Check the Stream: ${snapshot.connectionState}");
                    }

                    today = DateTime.now();
                    time = "${today.hour}:${today.minute}:${today.second}";

                    if (!_isDataReadingScheduled) {
                      _dataReadingTimer =
                          Timer.periodic(const Duration(minutes: 1), (_) {
                        deviceProvider.mqttConnect();
                      });
                      _isDataReadingScheduled = true;
                    }

                    return Center(
                        child: Column(
                      children: <Widget>[
                        Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                SizedBox(height: 30),
                                Center(
                                  child: TweenAnimationBuilder(
                                    tween: Tween(begin: 0.0, end: 1.0),
                                    duration: Duration(seconds: 4),
                                    builder: (context, value, child) {
                                      value = spo2 / 100;
                                      int percentage = (value * 100).ceil();
                                      return Container(
                                        width: size,
                                        height: size,
                                        child: Stack(
                                          children: [
                                            ShaderMask(
                                              shaderCallback: (rect) {
                                                return SweepGradient(
                                                    startAngle: 0.0,
                                                    endAngle: TWO_PI,
                                                    stops: [value, value],
                                                    center: Alignment.center,
                                                    colors: [
                                                      '#DF4933'.toColor(),
                                                      Colors.grey.withAlpha(55)
                                                    ]).createShader(rect);
                                              },
                                              child: Container(
                                                width: size,
                                                height: size,
                                                decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: '#DF4933'.toColor()),
                                              ),
                                            ),
                                            Center(
                                              child: Container(
                                                width: size - 40,
                                                height: size - 40,
                                                decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    shape: BoxShape.circle),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Center(
                                                      child: Image.asset(
                                                        'assets/images/bpm_symbol.png',
                                                        width: 70,
                                                        height: 70,
                                                      ),
                                                    ),
                                                    Center(
                                                      child: Text(
                                                        "${hr} BPM",
                                                        style: TextStyle(
                                                            fontSize: 25),
                                                      ),
                                                    ),
                                                    Center(
                                                      child: Text(
                                                        "${spo2}% SPO2",
                                                        style: TextStyle(
                                                            fontSize: 25),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(height: 30),
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(10.0),
                                    width: 350,
                                    height: 80,
                                    decoration: const BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      color: Colors.blue,
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Row(
                                            children: <Widget>[
                                              Container(
                                                child: Text(
                                                  "Heart Rate and Oxygen Level",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  time,
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.white),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          "${hr} bpm, ${spo2}%",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 15),
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(10.0),
                                    width: 350,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(10)),
                                      color: Colors.grey[300],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Center(
                                          child: Row(
                                            children: <Widget>[
                                              Container(
                                                child: Text(
                                                  "Inhaled Dosage",
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.blue),
                                                ),
                                              ),
                                              Expanded(
                                                child: Text(
                                                  time,
                                                  style: TextStyle(
                                                      fontSize: 15,
                                                      color: Colors.blue),
                                                  textAlign: TextAlign.right,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Text(
                                          "51",
                                          style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.black),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                      ],
                    ));
                  },
                );
              });
            },
          );
        }),
      ),
    );
  }
}
