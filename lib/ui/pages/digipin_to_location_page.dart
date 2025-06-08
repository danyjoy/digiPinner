import 'package:digipin/utils/digipin_utils.dart';
import 'package:digipin/utils/location_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DigipinToLocationPage extends StatefulWidget {
  const DigipinToLocationPage({Key? key}) : super(key: key);

  @override
  _DigipinToLocationPageState createState() => _DigipinToLocationPageState();
}

class _DigipinToLocationPageState extends State<DigipinToLocationPage> {
  String _statusMessage = 'Please enter a DIGIPIN';
  Map<String, double> _coordinates = {};
  String _digipin = '';

  bool _checkDigipin(String digipin) {
    bool isValidDigipin = false;
    setState(() {
      _coordinates = {};
    });
    if (digipin.isEmpty) return isValidDigipin;
    if (digipin.length < 10) return isValidDigipin;
    if (digipin.length == 10 &&
        RegExp(r'^[23456789CJKLMPFTcjklmpft]{10}$').hasMatch(digipin)) {
      print('Valid DIGIPIN: $digipin');
      isValidDigipin = true;
      _digipin = digipin;
    } else {
      isValidDigipin = false;
    }
    return isValidDigipin;
  }

  void _getCoordinatesFromDigipin(String digipin) {
    final filteredDigipin = digipin.replaceAll('-', '');
    if (!_checkDigipin(filteredDigipin)) {
      setState(() {
        _statusMessage = _getStatusMessage(filteredDigipin);
      });
    } else {
      setState(() {
        try {
          final coordinates = DigiPinUtils.getLatLngFromDigiPin(
            filteredDigipin,
          );
          _coordinates = coordinates;
        } catch (e) {
          _statusMessage = 'Invalid DIGIPIN';
        }
      });
    }
  }

  String _getStatusMessage(String digipin) {
    if (digipin.isEmpty) {
      return 'Please enter a DIGIPIN';
    } else if (digipin.length < 10) {
      return 'DIGIPIN must be 10 characters long';
    } else {
      return 'Invalid DIGIPIN';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade700,
        centerTitle: true,
        title: Text(
          'DigiPinner',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_statusMessage.isNotEmpty && _coordinates.isEmpty)
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                _statusMessage,
                style: TextStyle(color: Colors.redAccent, fontSize: 18),
              ),
            ),
          if (_coordinates.isNotEmpty)
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Coordinates: ${_coordinates['latitude']}, ${_coordinates['longitude']}',
                    style: TextStyle(color: Colors.greenAccent, fontSize: 18),
                  ),
                ),
              ],
            ),
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Enter your DIGIPIN',
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.white),
                ),
                filled: true,
                fillColor: Colors.grey.shade800,
              ),
              style: TextStyle(color: Colors.white),
              onChanged: (value) {
                _getCoordinatesFromDigipin(value);
              },
              maxLines: 1,
              maxLength: 12,
            ),
          ),
          SizedBox(height: 20),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _coordinates.isEmpty
                        ? null
                        : () {
                            final shareText =
                                'DIGIPIN: ${DigiPinUtils.formatDigiPin(_digipin)}\nCoordinates:'
                                ' \nLatitude: ${_coordinates['latitude']}'
                                ' \nLongitude: ${_coordinates['longitude']}'
                                '\nView on Google Maps: https://www.google.com/maps/search/?api=1&query=${_coordinates['latitude']},${_coordinates['longitude']}';

                            Clipboard.setData(ClipboardData(text: shareText));
                          },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.copy),
                        SizedBox(width: 8),
                        Text('Copy'),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _coordinates.isEmpty
                        ? null
                        : () {
                            LocationUtils.openInGoogleMaps(
                              _coordinates['latitude']!,
                              _coordinates['longitude']!,
                            );
                          },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map),
                        SizedBox(width: 8),
                        Text('Maps'),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _coordinates.isEmpty
                        ? null
                        : () async {
                            final mapsURL =
                                await LocationUtils.getGoogleMapsUrl(
                                  _coordinates['latitude']!,
                                  _coordinates['longitude']!,
                                );
                            DigiPinUtils.shareDigiPin(_digipin, mapsURL);
                          },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.share),
                        SizedBox(width: 8),
                        Text('Share'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
