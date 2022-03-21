import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_gojek/models/initial_location_model.dart';
import 'package:flutter_gojek/models/set_polyline_model.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

const double CAMERA_ZOOM = 16;
const double CAMERA_TILT = 0;
const double CAMERA_BEARING = 0;
const LatLng SOURCE_LOCATION = LatLng(42.747932, -71.167889);
const LatLng DEST_LOCATION = LatLng(-7.410045, 109.2520442);
const String GOOGLE_API_KEY = 'AIzaSyDEe9EjuF21rOBnxAcsTi5ymhQX8jMcsyA';

class MainRepo {

  // wrapper around the location API
  Location _location = Location();

  // listen on location changed
  Stream<LocationData> getLocationChange() {
    return _location.onLocationChanged;
  }

  // set inital location
  Future<InitialLocationModel> setInitialLocation(LocationData currentLocation) async {
    // set init location
    currentLocation = await _location.getLocation();
    print('Current location: $currentLocation');

    // set cameraPosition location
    CameraPosition cameraPosition = CameraPosition(
      bearing: CAMERA_BEARING,
      target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
    );
    return InitialLocationModel(currentLocation,cameraPosition);
  }

  // show pin marker on map
  Future<Set<Marker>> showPinOnMap(
      {LocationData? currentLocation,
      LocationData? destinationLocation}) async {
    // marker
    Set<Marker> _markers = Set<Marker>();
    // pin position
    LatLng pinPosition = LatLng(currentLocation!.latitude!, currentLocation.longitude!);
    LatLng destPosition = LatLng(destinationLocation!.latitude!, destinationLocation.longitude!);

    // for custom marker pins
    BitmapDescriptor _sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(
          devicePixelRatio: 2.5,
        ),
        'images/driving_pin.png');
    BitmapDescriptor _destinationIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(
          devicePixelRatio: 2.5,
        ),
        'images/destination_map_marker.png');

    // add source & destination markers
    _markers.add(
      Marker(
        markerId: MarkerId('sourcePin'),
        position: pinPosition,
        icon: _sourceIcon,
      ),
    );
    _markers.add(
      Marker(
        markerId: MarkerId('destPin'),
        position: destPosition,
        icon: _destinationIcon,
      ),
    );
    return _markers;
  }

  //update pin marker on map
  Future<void> updatePinOnMap({
    required LocationData currentLocation,required Completer<GoogleMapController> controller,
  })async{
    // create a new CameraPosition instance
    // every time the location changes, so the camera
    // follows the pin as it moves with an animation
    CameraPosition cPosition = CameraPosition(
      zoom: CAMERA_ZOOM,
      tilt: CAMERA_TILT,
      bearing: CAMERA_BEARING,
      target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
    );
    // update camera position
    final _controller = await controller.future;
    _controller.animateCamera(CameraUpdate.newCameraPosition(cPosition));
    Set<Marker> markers = Set<Marker>();

    final markerPosition = LatLng(currentLocation.latitude!, currentLocation.longitude!);
    BitmapDescriptor _sourceIcon = await BitmapDescriptor.fromAssetImage(
        ImageConfiguration(
          devicePixelRatio: 2.5,
        ),
        'images/driving_pin.png');
    markers.add(
      Marker(
        markerId: MarkerId('sourcePin'),
        position: markerPosition,
        icon: _sourceIcon,
      ),
    );
    markers.removeWhere((m) => m.markerId.value == 'sourcePin');
    markers.add(Marker(
      markerId: MarkerId('sourcePin'),
      position: markerPosition,
      icon: _sourceIcon,
    ));
  }

  // set poly lines direction from source to destination
  Future<SetPolylineModel> setPolylines(
      {LocationData? currentLocation,
      LocationData? destinationLocation}) async {

    // drawn routes on map
    Set<Polyline> _polylines = Set<Polyline>();
    List<LatLng> _polylinesCoordinates = [];
    PolylinePoints _polylinePoints = PolylinePoints();

    // get route coordinates
    PolylineResult _result = await _polylinePoints.getRouteBetweenCoordinates(
      GOOGLE_API_KEY,
      PointLatLng(
        currentLocation!.latitude!,
        currentLocation.longitude!,
      ),
      PointLatLng(destinationLocation!.latitude!, destinationLocation.longitude!),
      travelMode: TravelMode.driving,
    );
    print('ROUTE COORDINATES :  ${_result.points}');
    print('ROUTE ERROR :  ${_result.errorMessage}');

    // check if it not empty
    if (_result.points.isNotEmpty) {
      // loop coordinates points
      _result.points.forEach((PointLatLng element) {
        // add each coordinate
        _polylinesCoordinates.add(LatLng(element.latitude, element.longitude));
      });

      // add coordinates to poly lines
      _polylines.add(
        Polyline(
          polylineId: PolylineId('poly'),
          width: 5,
          points: _polylinesCoordinates,
          color: Color.fromARGB(255, 40, 122, 198),
        ),
      );
    }
    double totalDistance = 0;
    for(int i = 0;i<_polylinesCoordinates.length-1;i++){
      totalDistance += _calculateDistance(
        _polylinesCoordinates[i].latitude,
        _polylinesCoordinates[i].longitude,
        _polylinesCoordinates[i+1].latitude,
        _polylinesCoordinates[i+1].longitude,
      );
    }
    return SetPolylineModel(totalDistance, _polylines);
  }

  // remove marker
  Future<void> removeMarkers(Set<Marker> marker)async{
    marker.clear();
  }

  //remove polylines
  Future<void> removePolylines(Set<Polyline> polylines)async{
    polylines.clear();
  }

  //calculate distance
  double _calculateDistance(double lat1,double lon1,double lat2,double lon2){
    var p = 0.017453292519943295;
    var a = 0.5 - cos((lat2 - lat1) * p)/2 + cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p))/2;
    return 12742 * asin(sqrt(a));
  }
}
