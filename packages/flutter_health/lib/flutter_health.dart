import 'dart:async';

import 'package:flutter/services.dart';
import 'dart:io' show Platform;

/// Custom Exception for the plugin,
/// thrown whenever the plugin is used on platforms
/// where some health data metric isnt available
class HealthDataNotAvailableException implements Exception {
  String _cause;

  HealthDataNotAvailableException(this._cause);

  @override
  String toString() {
    return _cause;
  }
}

enum HealthKitDataType {
  BODY_FAT,
  HEIGHT,
  BODY_MASS_INDEX,
  WAIST_CIRCUMFERENCE,
  STEPS,
  BASAL_ENERGY_BURNED,
  ACTIVE_ENERGY_BURNED,
  HEART_RATE,
  BODY_TEMPERATURE,
  BLOOD_PRESSURE_SYSTOLIC,
  BLOOD_PRESSURE_DIASTOLIC,
  RESTING_HEART_RATE,
  WALKING_HEART_RATE,
  BLOOD_OXYGEN,
  BLOOD_GLUCOSE,
  ELECTRODERMAL_ACTIVITY,
  HIGH_HEART_RATE_EVENT,
  LOW_HEART_RATE_EVENT,
  IRREGULAR_HEART_RATE_EVENT
}

enum GoogleFitType {
  BODY_FAT,
  HEIGHT,
  STEPS,
  CALORIES,
  HEART_RATE,
  BODY_TEMPERATURE,
  BLOOD_PRESSURE,
  BLOOD_OXYGEN,
  BLOOD_GLUCOSE
}

class FlutterHealth {

  static const MethodChannel _channel = const MethodChannel('flutter_health');
  static PlatformType _platformType =
      Platform.isAndroid ? PlatformType.ANDROID : PlatformType.IOS;

  static String _methodName =
      _platformType == PlatformType.ANDROID ? 'getGFHealthData' : 'getData';

  static Future<bool> checkIfHealthDataAvailable() async {
    final bool isHealthDataAvailable =
        await _channel.invokeMethod('checkIfHealthDataAvailable');
    return isHealthDataAvailable;
  }

  static Future<bool> requestAuthorization() async {
    final bool isAuthorized =
        await _channel.invokeMethod('requestAuthorization');
    return isAuthorized;
  }

  //////// START ENUM FUNCTIONS /////////

  static Future<List<HealthData>> getHeartRate(
      DateTime startDate, DateTime endDate) async {
    var type = _platformType == PlatformType.ANDROID
        ? GoogleFitType.HEART_RATE
        : HealthKitDataType.HEART_RATE;
    return getHealthDataFromEnum(startDate, endDate, type, "getBodyFatPercentage");
  }

  static Future<List<HealthData>> getBasalEnergyBurned(
      DateTime startDate, DateTime endDate) async {
    var type = _platformType == PlatformType.ANDROID
        ? null
        : HealthKitDataType.BASAL_ENERGY_BURNED;
    return getHealthDataFromEnum(startDate, endDate, type, "getBodyFatPercentage");
  }

  static Future<List<HealthData>> getBodyFatPercentage(
      DateTime startDate, DateTime endDate) async {
    var type = _platformType == PlatformType.ANDROID
        ? GoogleFitType.BODY_FAT
        : HealthKitDataType.BODY_FAT;
    return getHealthDataFromEnum(startDate, endDate, type, "getBodyFatPercentage");
  }

  static Future<List<HealthData>> getCalories(
      DateTime startDate, DateTime endDate) async {
    var type =
        _platformType == PlatformType.ANDROID ? GoogleFitType.CALORIES : null;
    return getHealthDataFromEnum(startDate, endDate, type, "getCalories");
  }

  static Future<List<HealthData>> getActiveEnergyBurned(
      DateTime startDate, DateTime endDate) async {
    var type = _platformType == PlatformType.ANDROID
        ? null
        : HealthKitDataType.ACTIVE_ENERGY_BURNED;
    return getHealthDataFromEnum(startDate, endDate, type, "getActiveEnergyBurned");
  }

  static Future<List<HealthData>> getHeight(
      DateTime startDate, DateTime endDate) async {
    var type = _platformType == PlatformType.ANDROID
        ? GoogleFitType.HEIGHT
        : HealthKitDataType.HEIGHT;
    return getHealthDataFromEnum(startDate, endDate, type, "getHeight");
  }

  static Future<List<HealthData>> getBodyMassIndex(
      DateTime startDate, DateTime endDate) async {
    var type = _platformType == PlatformType.ANDROID
        ? null
        : HealthKitDataType.BODY_MASS_INDEX;
    return getHealthDataFromEnum(startDate, endDate, type, "getBodyMassIndex");
  }

  static Future<List<HealthData>> getStepCount(
      DateTime startDate, DateTime endDate) async {
    var type = _platformType == PlatformType.ANDROID
        ? GoogleFitType.STEPS
        : HealthKitDataType.STEPS;
    return getHealthDataFromEnum(startDate, endDate, type, "getStepCount");
  }

  static Future<List<HealthData>> getWaistCircumference(
      DateTime startDate, DateTime endDate) async {
    var type = _platformType == PlatformType.ANDROID
        ? null // Not implemented for Google Fit
        : HealthKitDataType.WAIST_CIRCUMFERENCE;
    return getHealthDataFromEnum(startDate, endDate, type, "getWaistCircumference");
  }

  //////// END ENUM FUNCTIONS /////////

  static Future<List<HealthData>> getHealthDataFromEnum(
      DateTime startDate, DateTime endDate, dynamic dataType, String dataTypeName) async {
    List<HealthData> healthData = new List();

    /// If not implemented on platform, just return the empty list
    if (dataType == null) {
      print("Method $dataTypeName not implemented for platform ${_platformType.toString()}");
      return healthData;
    }

    /// Get the index of the given data type
    int dataTypeIndex = _platformType == PlatformType.ANDROID
        ? GoogleFitType.values.indexOf(dataType)
        : HealthKitDataType.values.indexOf(dataType);

    /// Set parameters for method channel request
    Map<String, dynamic> args = {
      'index': dataTypeIndex,
      'startDate': startDate.millisecondsSinceEpoch,
      'endDate': endDate.millisecondsSinceEpoch
    };


    try {
      List result = await _channel.invokeMethod(_methodName, args);

      /// Process each data point received
      for (var x in result) {
        /// Add the platform_type and data_type fields
        x["platform_type"] = _platformType.toString();
        x["data_type"] = dataType.toString();

        /// Convert to JSON
        Map<String, dynamic> jsonData = Map<String, dynamic>.from(x);

        /// Convert JSON to HealtData object
        HealthData data = HealthData.fromJson(jsonData);
        healthData.add(data);
      }
    } catch (error) {
      print(error);
    }
    return healthData;
  }

  static Future<List<HealthData>> getHKHeartData(
      DateTime startDate, DateTime endDate, int type) async {
    Map<String, dynamic> args = {};
    args.putIfAbsent('index', () => type);
    args.putIfAbsent('startDate', () => startDate.millisecondsSinceEpoch);
    args.putIfAbsent('endDate', () => endDate.millisecondsSinceEpoch);
    try {
      List result = await _channel.invokeMethod('getHeartAlerts', args);
      var hkHealthData = List<HealthData>.from(
          result.map((i) => HealthData.fromJson(Map<String, dynamic>.from(i))));
      return hkHealthData;
    } catch (e) {
      return const [];
    }
  }
}

/// Cachet implementations below
enum PlatformType { IOS, ANDROID, UNKNOWN }

class HealthData {
  double value;
  double value2;
  String unit;
  int dateFrom;
  int dateTo;
  String dataType;
  String platform;

  HealthData(
      {this.value,
      this.unit,
      this.dateFrom,
      this.dateTo,
      this.dataType,
      this.platform});

  HealthData.fromJson(Map<String, dynamic> json) {
    try {
      value = json['value'];
      unit = json['unit'];
      dateFrom = json['date_from'];
      dateTo = json['date_to'];
      dataType = json['data_type'];
      platform = json['platform_type'];
    } catch (error) {
      print(error);
      print('test');
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['value'] = this.value;
    data['unit'] = this.unit;
    data['date_from'] = this.dateFrom;
    data['date_to'] = this.dateTo;
    data['data_type'] = this.dataType;
    data['platform_type'] = this.platform;
    return data;
  }

  String toString() {
    Map<String, dynamic> json = this.toJson();
    return json.toString();
  }
}