import 'dart:async';
import 'dart:convert';
import 'device_provider.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

class AirQuality extends StatelessWidget {
  Timer? _dataReadingTimer;
  bool _isDataReadingScheduled = false;

  String _dataParser(List<int> dataFromDevice) {
    return utf8.decode(dataFromDevice);
  }

  List<double> a1 = [];
  List<double> b1 = [];
  List<double> c1 = [];

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Expanded(
        child: Column(
          children: [
            const SizedBox(height: 20.0),
            AspectRatio(
              aspectRatio: 2, // Adjust the aspect ratio as needed
              child: LineChart(
                LineChartData(
                  lineTouchData: LineTouchData(enabled: false),
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      axisNameWidget: const Text('Time'),
                    ),
                    leftTitles: AxisTitles(
                      axisNameWidget: const Text('PM2.5'),
                    ),
                    rightTitles: AxisTitles(
                      axisNameWidget: const Text('Heart Rate'),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: 10,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 50),
                        const FlSpot(2, 80),
                        const FlSpot(4, 30),
                        const FlSpot(6, 70),
                        const FlSpot(8, 20),
                        const FlSpot(10, 90),
                      ],
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: [
                        const FlSpot(0, 70),
                        const FlSpot(2, 30),
                        const FlSpot(4, 60),
                        const FlSpot(6, 40),
                        const FlSpot(8, 80),
                        const FlSpot(10, 50),
                      ],
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 3,
                      dotData: FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Consumer<DeviceProvider>(builder: (context, deviceProvider, _) {
              return StreamBuilder<List<int>>(
                stream: dataStream1,
                builder:
                    (BuildContext context, AsyncSnapshot<List<int>> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  }

                  if (snapshot.connectionState == ConnectionState.active) {
                    var dataString1 = _dataParser(snapshot.data!);

                    var dataList1 = dataString1.split('w');

                    List<int> intList1 = dataList1
                        .map((String str) => int.tryParse(str) ?? 0)
                        .toList();
                    List<double> doubleList1 = intList1
                        .map((value) => ((value.toDouble())) / 100)
                        .toList();

                    try {
                      a1.add(doubleList1[0]);
                      b1.add(doubleList1[1]);
                      c1.add(doubleList1[2]);
                    } catch (e) {
                      a1.add(0);
                      b1.add(0);
                      c1.add(0);
                    }
                    temp = a1[a1.length - 1];
                    hum = b1[b1.length - 1];
                    PM = c1[c1.length - 1];
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    try {
                      temp = a1[a1.length - 1];
                      hum = b1[b1.length - 1];
                      PM = c1[c1.length - 1];
                    } catch (e) {
                      temp = 0;
                      hum = 0;
                      PM = 0;
                    }
                  } else {
                    return Text(
                        'Check the stream\n${snapshot.connectionState}');
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
                              const SizedBox(height: 15),
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
                                              child: const Text(
                                                "Temperature",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                time,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "${temp}",
                                        style: const TextStyle(
                                            fontSize: 20, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.all(10.0),
                                  width: 350,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
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
                                              child: const Text(
                                                "Humidity",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.blue),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                time,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.blue),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "$hum",
                                        style: const TextStyle(
                                            fontSize: 20, color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
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
                                              child: const Text(
                                                "Particulate Matter (PM2.5)",
                                                style: TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            Expanded(
                                              child: Text(
                                                time,
                                                style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.white),
                                                textAlign: TextAlign.right,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "${PM}",
                                        style: const TextStyle(
                                            fontSize: 20, color: Colors.black),
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
            }),
          ],
        ),
      ),
    ]);
  }
}
