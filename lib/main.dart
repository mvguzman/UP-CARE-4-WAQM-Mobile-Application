import 'package:flutter/material.dart';
import 'controller_widget.dart';
import 'package:provider/provider.dart';
import 'device_provider.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (_) => DeviceProvider(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "ECE 196 Application",
      home: Controller(),
    );
  }
}
