import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class InitialLocationModel{
  final LocationData currentLocation;
  final CameraPosition cameraPosition;

  InitialLocationModel(this.currentLocation, this.cameraPosition);
}