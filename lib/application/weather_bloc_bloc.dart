import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weather/weather.dart';

import '../infrastructure/weather_repo/i_repo.dart';

part 'weather_bloc_event.dart';
part 'weather_bloc_state.dart';

class WeatherBlocBloc extends Bloc<WeatherBlocEvent, WeatherBlocState> {
  WeatherBlocBloc() : super(WeatherBlocInitial()) {
    IWeatherRepo repository = IWeatherRepo();
    on<FetchWeather>((event, emit) async {
      emit(WeatherBlocLoading());
      try {
        Weather weatherResult =await repository.getCurrentWeather(
            latitude: event.position.latitude,
            longitude: event.position.longitude);
            
        emit(WeatherBlocSuccess(weatherResult));
      } catch (e) {
        emit(WeatherBlocFailure());
      }
    });
  }
}
