import 'package:weather_app/domain/api/api_key.dart';
import 'package:weather/weather.dart';

abstract class IWeatherRepo {
  factory IWeatherRepo() = RepositoryImpl;
  getCurrentWeather({required double latitude, required double longitude});
}

class RepositoryImpl implements IWeatherRepo {
  @override
  getCurrentWeather(
      {required double latitude, required double longitude}) async {
    WeatherFactory wf = WeatherFactory(API_KEY, language: Language.ENGLISH);

    Weather weather = await wf.currentWeatherByLocation(
      latitude,
      longitude,
    );
    return weather;
  }
}
