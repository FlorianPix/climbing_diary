
import 'base_config.dart';

class DevConfig implements BaseConfig {
  @override
  String get climbingApiHost => "http://10.0.2.2:8000";
  @override
  String get mediaApiHost => "http://10.0.2.2:8001";
}