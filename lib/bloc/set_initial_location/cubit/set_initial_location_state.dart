part of 'set_initial_location_cubit.dart';

@immutable
abstract class SetInitialLocationState {}

class SetInitialLocationInitial extends SetInitialLocationState {}
class SetInitialLocationLoading extends SetInitialLocationState {}
class SetInitialLocationSuccess extends SetInitialLocationState {
  final InitialLocationModel data;

  SetInitialLocationSuccess(this.data);
}
class SetInitialLocationFailure extends SetInitialLocationState {
  final String msg;

  SetInitialLocationFailure(this.msg);
}
