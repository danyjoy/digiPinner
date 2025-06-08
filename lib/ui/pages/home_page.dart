import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/digipin_utils.dart';
import '../../utils/location_utils.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'digipin_to_location_page.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  double? _latitude;
  double? _longitude;
  double? _accuracy;
  String _status = '';
  String _digiPin = '';
  String? _googleMapsUrl;
  bool _isLoading = false;

  void _reset() {
    setState(() {
      _latitude = null;
      _longitude = null;
      _accuracy = null;
      _status = '';
      _digiPin = '';
    });
  }

  Future<void> _getLocation() async {
    setState(() {
      _status = 'Checking permissions...';
      _isLoading = true;
    });

    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _status = 'Location services are disabled.';
        _isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _status = 'Location permissions are denied';
          _isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _status =
            'Location permissions are permanently denied, we cannot request permissions.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _status = 'Getting location...';
    });

    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
    );

    Position position = await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );

    setState(() {
      _latitude = position.latitude;
      _longitude = position.longitude;
      _accuracy = position.accuracy;
      _status = 'Location fetched!';
      _isLoading = false;
    });

    try {
      String digiPin = DigiPinUtils.getDigiPin(_latitude!, _longitude!);
      String url = await LocationUtils.getGoogleMapsUrl(
        _latitude!,
        _longitude!,
      );
      setState(() {
        _digiPin = digiPin;
        _googleMapsUrl = url;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error generating DigiPin: $e';
        _isLoading = false;
      });
    }
  }

  void _loadMoreInfo() {
    const String url = "https://www.indiapost.gov.in/VAS/Pages/digipin.aspx";
    launchUrl(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade700,
        centerTitle: true,
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: 'About',
            onPressed: () {
              showAdaptiveAboutDialog(
                context: context,
                applicationName: 'DigiPinner',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.location_on),
                children: [
                  const Text(
                    'DigiPinner is an app to generate a unique DIGIPIN based on your current location.\n\nDIGIPIN is an initiative by India Post',
                  ),
                  const SizedBox(height: 16),
                  RichText(
                    text: TextSpan(
                      text: 'More Info: ',
                      style: TextStyle(color: Colors.white),
                      children: [
                        TextSpan(
                          text: 'DIGIPIN India Post',
                          style: TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                          recognizer: TapGestureRecognizer()
                            ..onTap = _loadMoreInfo,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (_digiPin.isNotEmpty)
              Column(
                children: [
                  Text(
                    'Your DigiPin 🎯',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.red.shade500,
                            width: 4,
                            style: BorderStyle.solid,
                          ),
                          borderRadius: BorderRadius.circular(8),
                          gradient: LinearGradient(
                            colors: [Colors.red.shade700, Colors.red.shade300],
                            transform: GradientRotation(0.785398), // 45 degrees
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _digiPin,
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.copy, color: Colors.white),
                              tooltip: 'Copy to clipboard',
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: _digiPin),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_googleMapsUrl != null)
                    Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: QrImageView(
                          data: _googleMapsUrl!,
                          version: QrVersions.auto,
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.all(16.0),
                        ),
                      ),
                    ),
                ],
              ),
            if (_latitude != null && _longitude != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Lat: ${_latitude!.toStringAsFixed(6)}, Long: ${_longitude!.toStringAsFixed(6)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            if (_status.isNotEmpty && _isLoading)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _status,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            if (_digiPin.isEmpty)
              Column(
                children: [
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16.0),
                      child: CircularProgressIndicator(),
                    ),
                  if (!_isLoading)
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            onPressed: _isLoading ? null : _getLocation,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 16.0,
                              ),
                              textStyle: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                              iconSize: 30,
                              side: BorderSide(
                                color: const Color(0xFFB39DDB),
                                width: 2,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.room),
                                const Text('Get My DIGIPIN'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DigipinToLocationPage(),
                                ),
                              );
                            },
                            label: const Text(
                              "Have a DIGIPIN? Find the location",
                              style: TextStyle(color: Colors.black87),
                            ),
                            icon: Icon(Icons.swap_horiz),
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.deepPurple.shade200,
                              iconColor: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          LocationUtils.openInGoogleMaps(
                            _latitude!,
                            _longitude!,
                          );
                        },
                        icon: const Icon(Icons.location_searching),
                        label: const Text('Verify'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _reset,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Reset'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          DigiPinUtils.shareDigiPin(_digiPin, _googleMapsUrl);
                        },
                        icon: const Icon(Icons.share),
                        label: const Text('Share'),
                      ),
                    ),
                  ],
                ),
              ),
            if (_accuracy != null && _accuracy! > 0.0)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  '*Accuracy: ${_accuracy!.toStringAsFixed(2)} meters',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade300),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
