import 'package:climbing_diary/config/base_config.dart';

class ProdConfig implements BaseConfig {
  @override
  String get climbingApiHost => "https://climbing-api.florianpix.de";
  @override
  String get mediaApiHost => "https://media-api.florianpix.de";
}