import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:small_weather/FrostedGlassBox.dart';
import 'package:small_weather/data.dart';
import 'package:geocoding/geocoding.dart';
import 'package:small_weather/new.dart';
import 'package:loading_indicator/loading_indicator.dart';

//29.974901, 31.159794
void main() {
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int? temperatureAvg,
      temperatureMax,
      temperatureMin,
      humidityAvg,
      windSpeedAvg;
  int? weatherCode = 1000;
  String? city, icon1;
  double? hum;
  int state = 0;
  DateTime date = DateTime.now();
  List days = [];
  bool exist = true;
  List<String> times = List.generate(
      7,
      (index) => DateFormat('ha')
          .format(DateTime.now().add(Duration(hours: index)))
          .toLowerCase());
  List<int> temps = [];
  @override
  void initState() {
    super.initState();
    _determinePosition();
    _api();
    date.hour <= 6 || date.hour >= 19 ? state = 1 : state = 0;
  }

  void _check() async {
    try {
      await rootBundle.load('assets/icons/$weatherCode$state.png');
      setState(() {
        exist = true;
      });
    } catch (e) {
      setState(() {
        exist = false;
      });
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  ///
  ///
  void _api() async {
    Position position = await _determinePosition();
    double longitude = position.longitude;
    double latitude = position.latitude;

    var response = await Dio()
        .get(
            'https://api.tomorrow.io/v4/weather/forecast?location=$longitude,$latitude&apikey=y42ABSNO9yyw1404w4vIpCcp4XLbUWXz')
        .timeout(const Duration(seconds: 27));
    List<Placemark> placemarks =
        await placemarkFromCoordinates(latitude, longitude)
            .timeout(const Duration(seconds: 27));
    setState(() {
      var dailyNewData = response.data["timelines"]["daily"];
      var hourlyNewData = response.data["timelines"]["hourly"];
      days = dailyNewData;
      temperatureAvg = dailyNewData[0]["values"]["temperatureAvg"].round();
      humidityAvg = dailyNewData[0]["values"]["humidityAvg"].round();
      temperatureMax = dailyNewData[0]["values"]["temperatureMax"].round();
      temperatureMin = dailyNewData[0]["values"]["temperatureMin"].round();
      weatherCode = dailyNewData[0]["values"]["weatherCodeMax"];
      windSpeedAvg = dailyNewData[0]["values"]["windSpeedAvg"].round();
      city = "${placemarks[0].country},${placemarks[0].locality}";
      hum = humidityAvg! / 100;
      _check();
      //
      for (int i = 0; i < 24; i++) {
        if (hourlyNewData[i]["time"].toString().split(':').first ==
            date.toIso8601String().split(':').first) {
          temps = List.generate(
              7,
              (index) =>
                  hourlyNewData[i + index]["values"]["temperature"].round());

          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          body: Stack(
            children: [
              //! background
              SizedBox(
                  width: double.infinity,
                  child: Image.asset('assets/images/back$state.png',
                      fit: BoxFit.cover)),
              hum == null
                  ? const Center(
                      child: LoadingIndicator(
                      indicatorType: Indicator.ballRotate,
                      colors: [
                        Color(0xffaed6f2),
                        Color(0xffebc717),
                        Color(0xff6fa5de)
                      ],
                    ))
                  : SingleChildScrollView(
                      child: //! content
                          Center(
                              child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(
                            height: 50,
                          ),
                          FrostedGlassBox(
                            theWidth: 400.0,
                            theHeight: 310.0,
                            theChild: Container(
                              padding: const EdgeInsets.only(
                                  right: 20, left: 20, bottom: 5),
                              height: 310,
                              margin: const EdgeInsets.only(top: 20),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Stack(children: [
                                //! content
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //
                                    //
                                    //
                                    Text(
                                      DateFormat('EEEE, d MMM, yyyy')
                                          .format(date),
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontFamily: 'cool',
                                          color: Colors.black),
                                    ),

                                    Text(
                                      '$city',
                                      style: const TextStyle(
                                          fontSize: 25,
                                          fontFamily: 'cool',
                                          color: Colors.black),
                                    ),

                                    const SizedBox(
                                      height: 25,
                                    ),
                                    //
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          children: [
                                            const Text(
                                              'Min/Max',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontFamily: 'cool',
                                                  color: Color.fromARGB(
                                                      145, 0, 0, 0)),
                                            ),
                                            const SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              '$temperatureMin°/$temperatureMax°',
                                              style: const TextStyle(
                                                  fontSize: 20,
                                                  fontFamily: 'cool',
                                                  color: Color.fromARGB(
                                                      145, 0, 0, 0)),
                                            ),
                                          ],
                                        ),
                                        //!icon

                                        SizedBox(
                                          child: Image.asset(
                                            exist
                                                ? 'assets/icons/$weatherCode$state.png'
                                                : 'assets/icons/${weatherCode}0.png',
                                            scale: .9,
                                          ),
                                        ),
                                      ],
                                    ),
                                    //
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    //temp
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '$temperatureAvg°c',
                                          style: const TextStyle(
                                              fontSize: 55,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'cool',
                                              color: Colors.black),
                                        ),
                                        //
                                        SizedBox(
                                          width: 180,
                                          child: Text(
                                            data["weatherCodeFullDay"]
                                                ["$weatherCode"],
                                            textAlign: TextAlign.right,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 2,
                                            style: const TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'cool',
                                                color: Colors.black),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              ]),
                            ),
                          ),
                          //
                          const SizedBox(height: 20),
                          //! Chart
                          FrostedGlassBox(
                            theWidth: double.infinity,
                            theHeight: 200.0,
                            theChild: SizedBox(
                                height: 200,
                                child: WeatherForecast(
                                  times: times,
                                  temperatures: temps,
                                )),
                          ),
                          //
                          const SizedBox(height: 20),
                          //
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              //
                              //
                              //
                              //
                              //!Wind
                              Expanded(
                                  child: FrostedGlassBox(
                                      theWidth: 190.0,
                                      theHeight: 200.0,
                                      theChild: Container(
                                        height: 200,
                                        width: 190,
                                        margin: const EdgeInsets.all(10),
                                        decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(20),
                                          topLeft: Radius.circular(20),
                                        )),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            //
                                            //
                                            const Text(
                                              'WIND',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'cool'),
                                            ),
                                            //
                                            //

                                            //
                                            Image.asset(
                                              'assets/images/wind1.png',
                                              scale: 8,
                                            ),
                                            //
                                            //

                                            //
                                            //
                                            Text(
                                              '$windSpeedAvg km/h',
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'cool'),
                                            ),
                                          ],
                                        ),
                                      ))),
                              //
                              //
                              //
                              //
                              //!Humidity
                              Expanded(
                                  child: FrostedGlassBox(
                                      theWidth: 190.0,
                                      theHeight: 200.0,
                                      theChild: Container(
                                        height: 200,
                                        width: 190,
                                        margin: const EdgeInsets.all(10),
                                        decoration: const BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                          bottomRight: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                        )),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            //
                                            //
                                            const Text(
                                              'HUMIDITY',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'cool'),
                                            ),
                                            //
                                            //
                                            CircularPercentIndicator(
                                              arcBackgroundColor:
                                                  const Color.fromARGB(
                                                      255, 91, 91, 91),
                                              arcType: ArcType.HALF,
                                              radius: 60,
                                              percent: hum!,
                                              lineWidth: 7,
                                              center: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    const Icon(
                                                        Icons
                                                            .water_drop_outlined,
                                                        color: Colors.black,
                                                        size: 35),
                                                    Text(
                                                      '$humidityAvg%',
                                                      style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 25,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontFamily: 'cool'),
                                                    )
                                                  ]),
                                              progressColor: Colors.white,
                                              animation: true,
                                              animationDuration: 800,
                                              circularStrokeCap:
                                                  CircularStrokeCap.round,
                                            ),
                                          ],
                                        ),
                                      ))),
                            ],
                          ),
                          //
                          const SizedBox(height: 10),
                          //
                          SizedBox(
                            height: 180,
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: days.length,
                                itemBuilder: (context, index) {
                                  return FrostedGlassBox(
                                      theWidth: 140.0,
                                      theHeight: 160.0,
                                      theChild: Container(
                                          margin: const EdgeInsets.all(5),
                                          //height: 60,
                                          width: 120,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(15),
                                          ),
                                          child: Column(
                                            children: [
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                DateFormat('EEEE').format(
                                                    DateTime.parse(
                                                        days[index]["time"])),
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'cool'),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Image.asset(
                                                'assets/icons/${days[index]["values"]["weatherCodeMax"]}0.png',
                                                scale: 1.5,
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                '${days[index]["values"]["temperatureAvg"].round()}°c',
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 25,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'cool'),
                                              ),
                                              const SizedBox(
                                                height: 1,
                                              ),
                                              Text(
                                                '${days[index]["values"]["temperatureMin"].round()}°c/${days[index]["values"]["temperatureMax"].round()}°c',
                                                style: const TextStyle(
                                                    color: Color.fromARGB(
                                                        145, 255, 255, 255),
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    fontFamily: 'cool'),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                            ],
                                          )));
                                }),
                          ),
                          //
                          const SizedBox(
                            height: 50,
                          )
                        ],
                      )),
                    ),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 255, 255, 255)),
    );
  }
}
