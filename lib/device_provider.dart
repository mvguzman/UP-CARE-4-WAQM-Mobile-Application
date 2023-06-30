import 'dart:async';
import 'dart:ffi';
import 'package:provider/provider.dart';

//For Bluetooth
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

//For GPS
import 'dart:async';
import 'package:location/location.dart' as loc;

//For MQTT
import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

// Initializations for Bluetooth
Stream<List<int>>? stream1;
Stream<List<int>>? stream2;

StreamSubscription<List<int>>? _streamSubscription1;
StreamSubscription<List<int>>? _streamSubscription2;
StreamController<List<int>> _streamController1 =
    StreamController<List<int>>.broadcast();
StreamController<List<int>> _streamController2 =
    StreamController<List<int>>.broadcast();

Stream<List<int>> get dataStream1 => _streamController1.stream;
Stream<List<int>> get dataStream2 => _streamController2.stream;

//Initializations for MQTT
String broker = 'ed7632329e6e4fbcbe77b1fa917585a1.s1.eu.hivemq.cloud';
int port = 8883;
String username = 'guzman.m';
String password = 'up.CAREg4';
String clientIdentifier = 'UPCARE_G4';
const topic = 'jsontest/ECE199_WEARABLEAQM';

StreamSubscription? subscription;

final MqttServerClient client = MqttServerClient(broker, '');

//Initialization for Global Variables
late var temp;
late var hum;
late var PM;
late var hr;
late var spo2;
late DateTime today;
late String time;

class DeviceProvider extends ChangeNotifier {
  //For Bluetooth
  FlutterBluePlus flutterBlue = FlutterBluePlus.instance;
  List<BluetoothDevice> devices = [];
  bool connectedToDevice1 = false;
  bool connectedToDevice2 = false;

  final String SERVICE_UUID = "6e400001-b5a3-f393-e0a9-e50e24dcca9e";
  final String CHARACTERISTIC_UUID = "6e400003-b5a3-f393-e0a9-e50e24dcca9e";

  final String DEVICEID_1 = "F7:F9:9B:95:D6:0E"; //Air Quality Module
  final String DEVICEID_2 = "D5:AE:84:F0:CD:46"; //Physiology Module

  String deviceId1 = '';
  String deviceId2 = '';

  DeviceProvider() {
    initState();
  }

  void initState() {
    ScanDevices();
  }

  void ScanDevices() {
    flutterBlue.startScan(timeout: Duration(seconds: 4));

    flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        if (!devices.contains(r.device)) {
          devices.add(r.device);
          connectToDevice(r.device);
        }
      }
    });
  }

  void connectToDevice(BluetoothDevice device) async {
    if (device.id.toString() == DEVICEID_1) {
      await device.connect();
      deviceId1 = device.id.toString();
      connectedToDevice1 = true;
      readDeviceData(deviceId1);
    }

    if (device.id.toString() == DEVICEID_2) {
      await device.connect();
      deviceId2 = device.id.toString();
      connectedToDevice2 = true;

      readDeviceData(deviceId2);
    }
  }

  void disconnectToDevice(BluetoothDevice device) async {
    device.disconnect();
  }

  void readDeviceData(deviceId) async {
    List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;

    late BluetoothCharacteristic charRead1;

    if (connectedToDevice1) {
      BluetoothDevice? device1 = connectedDevices
          .firstWhere((device) => device.id.id == deviceId1, orElse: null);
      List<BluetoothService> services1 = await device1.discoverServices();
      for (BluetoothService service in services1) {
        if (service.uuid.toString() == SERVICE_UUID) {
          for (BluetoothCharacteristic characteristic
              in service.characteristics) {
            if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
              characteristic.setNotifyValue(true);

              startDataStreaming1(characteristic);
            }
          }
        }
      }
    }

    if (connectedToDevice2) {
      BluetoothDevice? device2 = connectedDevices
          .firstWhere((device) => device.id.id == deviceId2, orElse: null);

      List<BluetoothService> services2 = await device2.discoverServices();
      services2.forEach((service) {
        if (service.uuid.toString() == SERVICE_UUID) {
          service.characteristics.forEach((characteristic) {
            if (characteristic.uuid.toString() == CHARACTERISTIC_UUID) {
              characteristic.setNotifyValue(true);
              startDataStreaming2(characteristic);
            }
          });
        }
      });
    }
  }

  void startDataStreaming1(BluetoothCharacteristic characteristic) {
    _streamSubscription1 = characteristic.value.listen((data) {
      _streamController1.add(data);
    });
  }

  void startDataStreaming2(BluetoothCharacteristic characteristic) {
    _streamSubscription2 = characteristic.value.listen((data) {
      _streamController2.add(data);
    });
  }

  checkConnectedDevice() async {
    List<BluetoothDevice> connectedDevices = await flutterBlue.connectedDevices;
    List<String> name = [];
    for (BluetoothDevice d in connectedDevices) {
      name.add(d.name.toString());
    }

    return connectedDevices;
  }

  //For GPS Data
  double? lat_data;
  double? long_data;
  final loc.Location location = loc.Location();
  String? currDateTime;

  void getLocation() async {
    try {
      final loc.LocationData _locationResult = await location.getLocation();

      lat_data = _locationResult.latitude;
      long_data = _locationResult.longitude;

      currDateTime = DateTime.now().toIso8601String();

      String geoData = '${lat_data}, ${long_data}, ${currDateTime}';
    } catch (e) {}
  }

  //For MQTT Publish
  String statusText = "Status Text";
  bool isConnected = false;
  late double tempMQ;
  late double humMQ;

  void setStatus(String content) {
    statusText = content;
  }

  void onConnected() {
    setStatus("Client connection was successful");
  }

  void onDisconnected() {
    setStatus("Client Disconnected");
    isConnected = false;
  }

  void pong() {
    print('Ping response client callback invoked');
  }

  void publishMessage(temp_data, hum_data, pm_data, hr_data, spo2_data, time,
      lat_data, long_data) {
    var payload = {
      'BME680_Temp': temp_data,
      'BME680_Humidity': hum_data,
      'SPS30_PM': pm_data,
      'MAX30101_heartRate': hr_data,
      'MAX30101_SPO2': spo2_data,
      'AppGPS_latitude': lat_data,
      'AppGPS_longitude': long_data,
      'TIME_RECORDED': time
    };

    final builder = MqttClientPayloadBuilder();
    String payloadString = json.encode(payload);
    String emptyString = '.';

    builder.addString(payloadString);
    builder.addString(emptyString);

    client.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
  }

  void subscribeToDatabase() {
    String databaseTopic = "jsontest/ECE199_WEARABLEAQM";
    client.subscribe(databaseTopic, MqttQos.atLeastOnce);

    client.updates?.listen((List<MqttReceivedMessage<MqttMessage>> messages) {
      for (MqttReceivedMessage<MqttMessage> message in messages) {
        final payload = message.payload.toString();
        // Process the received data from the database
        processData(payload);
      }
    });
  }

  void processData(String data) {
    // Parse and process the received data from the database
    Map<String, dynamic> parsedData = json.decode(data);

    // Extract the required fields from the parsed data
    tempMQ = parsedData['WAQMTemp_test'];
    humMQ = parsedData['WAQMHum_test'];
  }

  Future<bool> mqttConnect() async {
    setStatus("Connecting MQTT Broker");

    client.logging(on: true);
    client.keepAlivePeriod = 20;
    client.port = port;
    client.secure = true;
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.pongCallback = pong;

    final MqttConnectMessage connMess = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean();
    client.connectionMessage = connMess;

    await client.connect(username, password);
    //Checks the connection status of the mobile application to the database
    if (client.connectionStatus!.state == MqttConnectionState.connected) {
      getLocation();

      try {
        publishMessage(temp, hum, PM, hr, spo2, time, lat_data, long_data);
      } catch (e) {}

      return true;
    } else {
      return false;
    }
  }
}
