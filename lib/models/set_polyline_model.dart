import 'package:google_maps_flutter/google_maps_flutter.dart';

class SetPolylineModel{
  final double distance;
  final Set<Polyline> polylines;

  SetPolylineModel(this.distance, this.polylines);
}