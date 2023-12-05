import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:weather_app/application/weather_bloc_bloc.dart';

import '../../domain/utils/get_location.dart';
import '../../domain/utils/home.dart';

class AnimatedMapControllerPage extends StatefulWidget {
  static const String route = '/map_controller_animated';

  const AnimatedMapControllerPage({super.key});

  @override
  AnimatedMapControllerPageState createState() =>
      AnimatedMapControllerPageState();
}

class AnimatedMapControllerPageState extends State<AnimatedMapControllerPage>
    with TickerProviderStateMixin {
  static const _startedId = 'AnimatedMapController#MoveStarted';
  static const _inProgressId = 'AnimatedMapController#MoveInProgress';
  static const _finishedId = 'AnimatedMapController#MoveFinished';

  static var currentPos = LatLng(CurrentPositions.currentLattitude.value,
      CurrentPositions.currentLongitude.value);
  // static const _paris = LatLng(48.8566, 2.3522);
  // static const _dublin = LatLng(53.3498, -6.2603);

  static final _markers = [
    Marker(
        width: 1,
        height: 1,
        point: currentPos,
        child: Image.asset("assets/1.png")
        // child: FlutterLogo(key: ValueKey('blue')),
        ),
  ];

  final mapController = MapController();

  void _animatedMapMove(LatLng destLocation, double destZoom) {
    final camera = mapController.camera;
    final latTween = Tween<double>(
        begin: camera.center.latitude, end: destLocation.latitude);
    final lngTween = Tween<double>(
        begin: camera.center.longitude, end: destLocation.longitude);
    final zoomTween = Tween<double>(begin: camera.zoom, end: destZoom);

    final controller = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this);
    final Animation<double> animation =
        CurvedAnimation(parent: controller, curve: Curves.fastOutSlowIn);

    final startIdWithTarget =
        '$_startedId#${destLocation.latitude},${destLocation.longitude},$destZoom';
    bool hasTriggeredMove = false;

    controller.addListener(() {
      final String id;
      if (animation.value == 1.0) {
        id = _finishedId;
      } else if (!hasTriggeredMove) {
        id = startIdWithTarget;
      } else {
        id = _inProgressId;
      }

      hasTriggeredMove |= mapController.move(
        LatLng(latTween.evaluate(animation), lngTween.evaluate(animation)),
        zoomTween.evaluate(animation),
        id: id,
      );
    });

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        controller.dispose();
      } else if (status == AnimationStatus.dismissed) {
        controller.dispose();
      }
    });

    controller.forward();
  }

  @override
  void initState() {
    super.initState();
    getPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Animated MapController')),
        // drawer: const MenuDrawer(AnimatedMapControllerPage.route),
        body: FutureBuilder(
            future: getPosition(),
            builder: (context, snap) {
              if (snap.hasData) {
                return BlocProvider<WeatherBlocBloc>(
                  create: (context) {
                    return WeatherBlocBloc()
                      ..add(FetchWeather(snap.data as Position));
                  },
                  child: BlocBuilder<WeatherBlocBloc, WeatherBlocState>(
                    builder: (context, state) {
                      if (state is WeatherBlocSuccess) {
                        _markers.add(Marker(
                            width: 80,
                            height: 80,
                            point: currentPos,
                            child: getWeatherIcon(
                                state.weather.weatherConditionCode!)));
                      }
                      return _body();
                    },
                  ),
                );
              } else {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            })

        //  BlocBuilder<WeatherBlocBloc, WeatherBlocState>(
        //   builder: (context, state) {
        //     if (state is WeatherBlocSuccess) {
        //       _markers.add(Marker(
        //           width: 80,
        //           height: 80,
        //           point: currentPos,
        //           child: getWeatherIcon(state.weather.weatherConditionCode!)));
        //     }
        //     return _body();
        //   },
        // ),
        );
  }

  Column _body() {
    return Column(
      children: [
        Flexible(
          child: FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: currentPos,
              initialZoom: 15,
              maxZoom: 10,
              minZoom: 3,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'dev.fleaflet.flutter_map.example',
                // tileProvider: CancellableNetworkTileProvider(),
                // tileUpdateTransformer: _animatedMoveTileUpdateTransformer,
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
        ),
      ],
    );
  }
}

/// Causes tiles to be prefetched at the target location and disables pruning
/// whilst animating movement. When proper animated movement is added (see
/// #1263) we should just detect the appropriate AnimatedMove events and
/// use their target zoom/center.
// final _animatedMoveTileUpdateTransformer = TileUpdateTransformer.fromHandlers(handleData: (updateEvent, sink) {
//   final mapEvent = updateEvent.mapEvent;

//   final id = mapEvent is MapEventMove ? mapEvent.id : null;
//   if (id?.startsWith(AnimatedMapControllerPageState._startedId) ?? false) {
//     final parts = id!.split('#')[2].split(',');
//     final lat = double.parse(parts[0]);
//     final lon = double.parse(parts[1]);
//     final zoom = double.parse(parts[2]);

//     // When animated movement starts load tiles at the target location and do
//     // not prune. Disabling pruning means existing tiles will remain visible
//     // whilst animating.
//     sink.add(
//       updateEvent.loadOnly(
//         loadCenterOverride: LatLng(lat, lon),
//         loadZoomOverride: zoom,
//       ),
//     );
//   } else if (id == AnimatedMapControllerPageState._inProgressId) {
//     // Do not prune or load whilst animating so that any existing tiles remain
//     // visible. A smarter implementation may start pruning once we are close to
//     // the target zoom/location.
//   } else if (id == AnimatedMapControllerPageState._finishedId) {
//     // We already prefetched the tiles when animation started so just prune.
//     sink.add(updateEvent.pruneOnly());
//   } else {
//     sink.add(updateEvent);
//   }
// });
