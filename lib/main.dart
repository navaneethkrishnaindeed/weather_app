
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'presentation/app.dart';


Future<void> main() async {

    WidgetsFlutterBinding.ensureInitialized();
    await Geolocator.requestPermission();

  runApp(const MainApp());
}