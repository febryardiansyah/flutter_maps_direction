import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter_gojek/repositories/main_repo.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:meta/meta.dart';

part 'update_pin_on_map_state.dart';

class UpdatePinOnMapCubit extends Cubit<UpdatePinOnMapState> {
  UpdatePinOnMapCubit() : super(UpdatePinOnMapInitial());
  final _repo = MainRepo();

  Future<void>updatePin({
    required LocationData currentLocation,required Completer<GoogleMapController> controller,
  })async{
    await _repo.updatePinOnMap(currentLocation: currentLocation, controller: controller);
  }
}
