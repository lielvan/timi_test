import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import 'main.dart';

class GMap extends StatefulWidget {
  const GMap({Key? key}) : super(key: key);

  @override
  _GMapState createState() => _GMapState();
}

class _GMapState extends State<GMap> {
  Completer<GoogleMapController> _controller = Completer();
  LatLng currentLocation = LatLng(32.08, 34.8);

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(32.08, 34.8),
    zoom: 14.4746,
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentLocation = Provider.of<TimiState>(context, listen: false).mapLocation;
  }

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      mapType: MapType.hybrid,
      initialCameraPosition: _kGooglePlex,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      onTap: (LatLng loc) {
        print(loc);
        Provider.of<TimiState>(context, listen: false).updateLocation(loc);
        setState(() {
          currentLocation = loc;
        });
      },
      markers: {
        Marker(
          markerId: MarkerId('BursaID'),
          position: currentLocation,
        ),
      },
    );
  }
}
