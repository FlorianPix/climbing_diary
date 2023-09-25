import 'package:climbing_diary/config/prod_config.dart';

import 'base_config.dart';
import 'dev_config.dart';

class Environment {
  factory Environment() => _singleton;

  Environment._internal();

  static final Environment _singleton = Environment._internal();

  static const String DEV = 'DEV';
  static const String PROD = 'PROD';

  late BaseConfig config;

  initConfig(String environment) {
    config = _getConfig(environment);
  }

  BaseConfig _getConfig(String environment) {
    switch (environment) {
      case Environment.PROD:
        return ProdConfig();
      default:
        return DevConfig();
    }
  }
}