import 'package:flutter/material.dart';
import 'package:weather_app/application/weather_bloc_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';

import '../domain/utils/get_location.dart';
import 'home_screen/home.dart';


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
			debugShowCheckedModeBanner: false,
      home: FutureBuilder(
				future: getPosition(),
        builder: (context, snap) {
					if(snap.hasData) {
						return BlocProvider<WeatherBlocBloc>(
							create: (context) => WeatherBlocBloc()..add(
								FetchWeather(snap.data as Position)
							),
							child: const HomeScreen(),
						);
					} else {
						return const Scaffold(
							body: Center(
								child: CircularProgressIndicator(),
							),
						);
					}
        }
      )
    );
  }
}

