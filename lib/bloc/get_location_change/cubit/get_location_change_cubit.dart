import 'package:bloc/bloc.dart';
import 'package:flutter_gojek/repositories/main_repo.dart';
import 'package:location/location.dart';
import 'package:meta/meta.dart';

part 'get_location_change_state.dart';

class GetLocationChangeCubit extends Cubit<GetLocationChangeState> {
  GetLocationChangeCubit() : super(GetLocationChangeInitial());
  final _repo = MainRepo();

  Stream<LocationData> fetchLocation()=>_repo.getLocationChange();
}
