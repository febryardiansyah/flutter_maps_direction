part of 'show_pin_marker_cubit.dart';

@immutable
abstract class ShowPinMarkerState {}

class ShowPinMarkerInitial extends ShowPinMarkerState {}
class ShowPinMarkerSuccess extends ShowPinMarkerState {
  final Set<Marker> data;

  ShowPinMarkerSuccess(this.data);
}
