import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gojek/bloc/get_location_change/cubit/get_location_change_cubit.dart';
import 'package:flutter_gojek/bloc/set_initial_location/cubit/set_initial_location_cubit.dart';
import 'package:flutter_gojek/bloc/set_polylines/cubit/set_polylines_cubit.dart';
import 'package:flutter_gojek/bloc/show_pin_marker/cubit/show_pin_marker_cubit.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

import 'bloc/update_pin_on_map/update_pin_on_map_cubit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GetLocationChangeCubit()),
        BlocProvider(create: (_) => SetInitialLocationCubit()),
        BlocProvider(create: (_) => ShowPinMarkerCubit()),
        BlocProvider(create: (_) => SetPolylinesCubit()),
        BlocProvider(create: (_) => UpdatePinOnMapCubit()),
      ],
      child: MaterialApp(
        title: 'Flutter Gojek',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // controller google map
  Completer<GoogleMapController> _controller = Completer();

  LocationData? currentLocation;
  LocationData? destinationLocation;

  double totalDistance = 0.0;

  @override
  void initState() {
    super.initState();
    context.read<GetLocationChangeCubit>().fetchLocation().listen((event) {
      // print(event.latitude);
      context.read<SetInitialLocationCubit>().setInitialLocation(event);
    });
  }

  @override
  Widget build(BuildContext context) {
    final _setPolylinesState = context.watch<SetPolylinesCubit>().state;
    final _showPinMarkerState = context.watch<ShowPinMarkerCubit>().state;
    return Scaffold(
      bottomNavigationBar: _setPolylinesState is SetPolylinesSuccess?Container(
        child: Center(child: Text(
          'Total Distance: ${_setPolylinesState.data.distance.toStringAsFixed(2)} KM',
        )),
        height: 50,
    ):null,
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: _showPinMarkerState is ShowPinMarkerSuccess?BlocBuilder<SetPolylinesCubit,SetPolylinesState>(
          builder: (context,state) {
            if (state is SetPolylinesSuccess) {
              return FloatingActionButton(
                child: Icon(Icons.clear),
                backgroundColor: Colors.red,
                onPressed: () {
                  context.read<SetPolylinesCubit>().remove(state.data.polylines);
                },
              );
            }
            return FloatingActionButton(
              child: Icon(Icons.alt_route),
              backgroundColor: Colors.blue,
              onPressed: () {
                context.read<SetPolylinesCubit>().setPolylines(
                  currentLocation: currentLocation,
                  destinationLocation: destinationLocation,
                );
              },
            );
          }
      ):null,
      appBar: AppBar(
        title: Text('Flutter Gojek'),
      ),
      body: BlocBuilder<SetInitialLocationCubit, SetInitialLocationState>(
        builder: (context, state) {
          if (state is SetInitialLocationLoading) {
            return Center(
              child: CupertinoActivityIndicator(),
            );
          }
          if (state is SetInitialLocationFailure) {
            return Center(child: Text(state.msg));
          }
          if (state is SetInitialLocationSuccess) {
            final _data = state.data;
            currentLocation = _data.currentLocation;
            return BlocBuilder<ShowPinMarkerCubit, ShowPinMarkerState>(
              builder: (context, state) {
                return GoogleMap(
                  initialCameraPosition: _data.cameraPosition,
                  myLocationEnabled: true,
                  compassEnabled: true,
                  tiltGesturesEnabled: true,
                  zoomGesturesEnabled: true,
                  mapType: MapType.normal,
                  markers: state is ShowPinMarkerSuccess ? state.data : {},
                  polylines: _setPolylinesState is SetPolylinesSuccess ? Set<Polyline>.of(_setPolylinesState.data.polylines) : {},
                  onTap: (e){
                    bool _isMarked = destinationLocation == LocationData.fromMap({
                      "latitude": e.latitude,
                      "longitude": e.longitude,
                    });
                    debugPrint('IS MARKED ===> $_isMarked');
                    if (_isMarked) {
                      context.read<ShowPinMarkerCubit>().remove(state is ShowPinMarkerSuccess ? state.data : {});
                    }else{
                      setState(() {
                        destinationLocation = LocationData.fromMap({
                          "latitude": e.latitude,
                          "longitude": e.longitude,
                        });
                      });
                      context.read<ShowPinMarkerCubit>().showPin(
                        currentLocation: _data.currentLocation,
                        destinationLocation: LocationData.fromMap({
                          "latitude": e.latitude,
                          "longitude": e.longitude,
                        },),);
                    }
                  },
                  onMapCreated: (GoogleMapController controller) {
                    _controller.complete(controller);
                  },
                );
              },
            );
          }
          return Container();
        },
      ),
    );
  }
}
