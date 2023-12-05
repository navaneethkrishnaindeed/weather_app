
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

import 'domain/utils/get_location.dart';
import 'presentation/app.dart';


Future<void> main() async {

    WidgetsFlutterBinding.ensureInitialized();
    await Geolocator.requestPermission();
Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high);
  CurrentPositions.currentLattitude.value = position.latitude;
  CurrentPositions.currentLongitude.value = position.longitude;
  runApp(const MainApp());
}