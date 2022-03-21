import 'package:bloc/bloc.dart';
import 'package:flutter_gojek/repositories/main_repo.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:meta/meta.dart';

part 'show_pin_marker_state.dart';

class ShowPinMarkerCubit extends Cubit<ShowPinMarkerState> {
  ShowPinMarkerCubit() : super(ShowPinMarkerInitial());
  final _repo = MainRepo();

  Future<void> showPin(
      {LocationData? currentLocation,
      LocationData? destinationLocation}) async {
    final _res = await _repo.showPinOnMap(
        currentLocation: currentLocation,
        destinationLocation: destinationLocation);
    emit(ShowPinMarkerSuccess(_res));
  }

  Future<void> remove(Set<Marker>markers) async {
    final _res = await _repo.removeMarkers(markers);
    emit(ShowPinMarkerInitial());
  }
}
