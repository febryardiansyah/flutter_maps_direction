import 'package:bloc/bloc.dart';
import 'package:flutter_gojek/models/set_polyline_model.dart';
import 'package:flutter_gojek/repositories/main_repo.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:meta/meta.dart';

part 'set_polylines_state.dart';

class SetPolylinesCubit extends Cubit<SetPolylinesState> {
  SetPolylinesCubit() : super(SetPolylinesInitial());
  final _repo = MainRepo();

  Future<void> setPolylines(
      {LocationData? currentLocation,
      LocationData? destinationLocation}) async {
    final _res = await _repo.setPolylines(
      currentLocation: currentLocation,
      destinationLocation: destinationLocation,
    );
    emit(SetPolylinesSuccess(_res));
  }

  Future<void> remove(Set<Polyline> polylines)async{
    await _repo.removePolylines(polylines);
    emit(SetPolylinesInitial());
  }
}
