import 'package:flutter/material.dart';
import 'home_widget.dart';
import 'airquality_widget.dart';
import 'health_widget.dart';
//import 'ble.dart';
import 'device_provider.dart';

class Controller extends StatefulWidget {
  @override
  State createState() {
    return _HomeState();
  }
}

class _HomeState extends State {
  int _currentIndex = 0;
  final List _children = [Home(), AirQuality(), Physiology()];

  // DeviceProvider deviceProvider = DeviceProvider();

  @override
  /* void initState() {
    super.initState();
    deviceProvider.ScanDevices(); // Scan and Connect to 2 modules upon opening
    deviceProvider.mqttConnect(); //Connect to MQTT upon opening
  }*/

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("ECE 199 Application"),
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          new BottomNavigationBarItem(
            icon: new Icon(
              Icons.home,
              color: Colors.grey,
            ),
            label: 'Home',
          ),
          new BottomNavigationBarItem(
            icon: new Icon(
              Icons.air,
              color: Colors.grey,
            ),
            label: 'Air Quality',
          ),
          new BottomNavigationBarItem(
            icon: Icon(
              Icons.health_and_safety,
              color: Colors.grey,
            ),
            label: 'Health',
          ),
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}
