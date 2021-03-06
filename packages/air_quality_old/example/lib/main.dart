/*
 * Copyright 2018 Copenhagen Center for Health Technology (CACHET) at the
 * Technical University of Denmark (DTU).
 * Use of this source code is governed by a MIT-style license that can be
 * found in the LICENSE file.
 */
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:air_quality/air_quality.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String message = 'Unknown';
  String key = '9e538456b2b85c92647d8b65090e29f957638c77';
  AirQuality airQuality;

  @override
  void initState() {
    super.initState();
    airQuality = new AirQuality(key);
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    sendQuery();
  }

  void sendQuery() async {
    /// Via city name (Munich)
    AirQualityData feedFromCity = await airQuality.feedFromCity('munich');

    /// Via station ID (Gothenburg weather station)
    AirQualityData feedFromStationId =
        await airQuality.feedFromStationId('7867');

    /// Via Geo Location (Berlin)
    AirQualityData feedFromGeoLocation =
        await airQuality.feedFromGeoLocation('52.6794', '12.5346');

    /// Via IP (depends on service provider)
    AirQualityData fromIP = await airQuality.feedFromIP();

    // Update screen state
    setState(() {
      message = feedFromCity.toString() +
          '\n' +
          feedFromStationId.toString() +
          '\n' +
          feedFromGeoLocation.toString() +
          '\n' +
          fromIP.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Air Quality API Example"),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                message,
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: sendQuery, child: Icon(Icons.cloud_download)),
      ),
    );
  }
}
