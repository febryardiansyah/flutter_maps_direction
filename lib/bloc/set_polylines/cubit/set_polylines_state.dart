part of 'set_polylines_cubit.dart';

@immutable
abstract class SetPolylinesState {}

class SetPolylinesInitial extends SetPolylinesState {}
class SetPolylinesSuccess extends SetPolylinesState {
  final SetPolylineModel data;

  SetPolylinesSuccess(this.data);
}
