import 'package:bloc/bloc.dart';
import 'package:flutter_gojek/models/initial_location_model.dart';
import 'package:flutter_gojek/repositories/main_repo.dart';
import 'package:location/location.dart';
import 'package:meta/meta.dart';

part 'set_initial_location_state.dart';

class SetInitialLocationCubit extends Cubit<SetInitialLocationState> {
  SetInitialLocationCubit() : super(SetInitialLocationInitial());
  final _repo = MainRepo();

  Future<void> setInitialLocation(LocationData currentLocation)async{
    // emit(SetInitialLocationLoading());
    try {
      final _res = await _repo.setInitialLocation(currentLocation);
      emit(SetInitialLocationSuccess(_res));
    } catch (e) {
      emit(SetInitialLocationFailure(e.toString()));
    }
  }
}
