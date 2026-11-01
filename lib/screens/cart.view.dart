import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class CartView extends StatefulWidget {
  const CartView({super.key});

  @override
  State<CartView> createState() => _CartViewState();
}

class _CartViewState extends State<CartView> {
  final MapController mapController = MapController();

  static const LatLng casablanca = LatLng(33.5731, -7.5898);

  StreamSubscription<Position>? positionSubscription;

  LatLng? departure;
  LatLng? destination;
  LatLng? userPosition;

  List<LatLng> routePoints = [];

  double? distanceKm;
  double? durationSeconds;

  bool loadingRoute = false;
  bool tracking = false;
  bool startingGps = false;

  String? routeError;

  // Empêche une ancienne réponse de remplacer une nouvelle sélection.
  int routeRequestId = 0;

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void selectPosition(LatLng point) {
    setState(() {
      routeRequestId++;
      routePoints = [];
      distanceKm = null;
      durationSeconds = null;
      routeError = null;
      loadingRoute = false;

      if (departure == null || destination != null) {
        departure = point;
        destination = null;
      } else {
        destination = point;
      }
    });

    if (departure != null && destination != null) {
      calculateRoute();
    }
  }

  Future<void> calculateRoute() async {
    final start = departure;
    final end = destination;

    if (start == null || end == null) return;

    final requestId = ++routeRequestId;

    setState(() {
      loadingRoute = true;
      routeError = null;
    });

    // OSRM attend les coordonnées dans l'ordre longitude, latitude.
    final uri = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${start.longitude},${start.latitude};'
      '${end.longitude},${end.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 20));

      if (response.statusCode != 200) {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final routes = data['routes'] as List?;

      if (data['code'] != 'Ok' || routes == null || routes.isEmpty) {
        throw Exception('Aucun itinéraire routier disponible.');
      }

      final route = routes.first as Map<String, dynamic>;
      final geometry = route['geometry'] as Map<String, dynamic>;
      final coordinates = geometry['coordinates'] as List;

      final points = coordinates.map((coordinate) {
        final pair = coordinate as List;

        return LatLng(
          (pair[1] as num).toDouble(),
          (pair[0] as num).toDouble(),
        );
      }).toList();

      if (!mounted || requestId != routeRequestId) return;

      setState(() {
        routePoints = points;
        distanceKm = (route['distance'] as num).toDouble() / 1000;
        durationSeconds = (route['duration'] as num).toDouble();
      });
    } catch (_) {
      if (!mounted || requestId != routeRequestId) return;

      setState(() {
        routeError =
            'Impossible de calculer le trajet. '
            'Vérifie Internet ou choisis deux autres points.';
      });
    } finally {
      if (mounted && requestId == routeRequestId) {
        setState(() {
          loadingRoute = false;
        });
      }
    }
  }

  void clearSelection() {
    setState(() {
      routeRequestId++;
      departure = null;
      destination = null;
      routePoints = [];
      distanceKm = null;
      durationSeconds = null;
      routeError = null;
      loadingRoute = false;
    });
  }

  void changeZoom(double value) {
    final camera = mapController.camera;
    final zoom = (camera.zoom + value).clamp(3.0, 18.0).toDouble();

    mapController.move(camera.center, zoom);
  }

  Future<void> toggleGps() async {
    if (startingGps) return;

    if (tracking) {
      final subscription = positionSubscription;
      positionSubscription = null;

      setState(() {
        tracking = false;
      });

      await subscription?.cancel();
      return;
    }

    setState(() {
      startingGps = true;
    });

    try {
      final enabled = await Geolocator.isLocationServiceEnabled();

      if (!enabled) {
        showMessage('Active la localisation sur ton appareil.');
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        showMessage(
          'Autorise la localisation dans les paramètres '
          'du navigateur ou de l’application.',
        );
        return;
      }

      if (!mounted) return;

      setState(() {
        tracking = true;
      });

      positionSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen(
        (position) {
          if (!mounted || !tracking) return;

          final point = LatLng(
            position.latitude,
            position.longitude,
          );

          setState(() {
            userPosition = point;
          });

          // La carte suit la position reçue.
          mapController.move(point, mapController.camera.zoom);
        },
        onError: (Object error) {
          if (!mounted) return;

          positionSubscription?.cancel();
          positionSubscription = null;

          setState(() {
            tracking = false;
          });

          showMessage(
            'Position indisponible. Vérifie la localisation '
            'et les autorisations.',
          );
        },
      );
    } catch (_) {
      showMessage('Impossible de démarrer la localisation.');

      if (mounted) {
        setState(() {
          tracking = false;
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          startingGps = false;
        });
      }
    }
  }

  String formatDuration(double seconds) {
    final minutes = (seconds / 60).ceil();

    if (minutes < 60) return '$minutes min';

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    return '$hours h $remainingMinutes min';
  }

  String coordinates(LatLng point) {
    return '${point.latitude.toStringAsFixed(5)}, '
        '${point.longitude.toStringAsFixed(5)}';
  }

  Marker buildMarker(LatLng point, Color color) {
    return Marker(
      point: point,
      width: 50,
      height: 50,
      alignment: Alignment.topCenter,
      child: Icon(
        Icons.location_pin,
        color: color,
        size: 50,
      ),
    );
  }

  @override
  void dispose() {
    routeRequestId++;
    positionSubscription?.cancel();
    mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final start = departure;
    final end = destination;
    final currentPosition = userPosition;
    final distance = distanceKm;
    final duration = durationSeconds;

    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: casablanca,
              initialZoom: 12,
              minZoom: 3,
              maxZoom: 18,
              onTap: (tapPosition, point) {
                selectPosition(point);
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                // Remplace par l'identifiant réel de ton application.
                userAgentPackageName: 'com.example.counter_app',
              ),

              if (routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: routePoints,
                      color: Colors.indigo,
                      strokeWidth: 5,
                    ),
                  ],
                ),

              MarkerLayer(
                markers: [
                  if (start != null)
                    buildMarker(start, Colors.green),
                  if (end != null)
                    buildMarker(end, Colors.red),
                  if (currentPosition != null)
                    Marker(
                      point: currentPosition,
                      width: 30,
                      height: 30,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white,
                            width: 4,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                  ),
                ],
              ),
            ],
          ),

          Positioned(
            top: 15,
            right: 15,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'zoomPlus',
                    onPressed: () => changeZoom(1),
                    child: const Icon(Icons.add),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton.small(
                    heroTag: 'zoomMinus',
                    onPressed: () => changeZoom(-1),
                    child: const Icon(Icons.remove),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton.small(
                    heroTag: 'resetMap',
                    onPressed: () {
                      mapController.move(casablanca, 12);
                    },
                    child: const Icon(Icons.home),
                  ),
                  const SizedBox(height: 10),
                  FloatingActionButton.small(
                    heroTag: 'gps',
                    tooltip: tracking
                        ? 'Arrêter le suivi GPS'
                        : 'Activer le suivi GPS',
                    backgroundColor:
                        tracking ? Colors.green : Colors.indigo,
                    onPressed: startingGps ? null : toggleGps,
                    child: startingGps
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            tracking
                                ? Icons.location_off
                                : Icons.my_location,
                            color: Colors.white,
                          ),
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            bottom: 45,
            left: 15,
            right: 15,
            child: SafeArea(
              top: false,
              child: Card(
                elevation: 4,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 230),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Itinéraire en voiture',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.indigo,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          start == null
                              ? '1. Clique pour choisir le départ.'
                              : 'Départ : ${coordinates(start)}',
                        ),
                        const SizedBox(height: 6),
                        Text(
                          end == null
                              ? '2. Clique pour choisir la destination.'
                              : 'Destination : ${coordinates(end)}',
                        ),

                        if (loadingRoute) ...[
                          const SizedBox(height: 12),
                          const LinearProgressIndicator(),
                          const Text('Calcul de l’itinéraire…'),
                        ],

                        if (routeError != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            routeError!,
                            style: const TextStyle(color: Colors.red),
                          ),
                          TextButton(
                            onPressed: calculateRoute,
                            child: const Text('Réessayer'),
                          ),
                        ],

                        if (distance != null && duration != null) ...[
                          const Divider(),
                          Text(
                            'Distance : ${distance.toStringAsFixed(2)} km',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Durée estimée : ${formatDuration(duration)}',
                          ),
                        ],

                        if (tracking)
                          const Text(
                            'Suivi GPS actif — position en bleu',
                            style: TextStyle(color: Colors.green),
                          ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            onPressed: clearSelection,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Nouvelle sélection'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}