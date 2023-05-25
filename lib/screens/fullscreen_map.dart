import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:test_naver_map_01/services/gps_service.dart';

class FullscreenMap extends StatelessWidget {
  FullscreenMap({super.key});

  final Future<Position> user_position = GPSService.getPosition();
  Future<bool> isdetermined = GPSService.determinePermission();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: isdetermined,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == true) {
              return MyNaverMap(user_position: user_position);
            } else {
              return const Center(
                child: Text(
                  "Permission is denied",
                ),
              );
            }
          } else {
            return const Center(
              child: Text(
                "Loading...",
              ),
            );
          }
        },
      ),
      floatingActionButton: !Platform.isAndroid
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Icon(Icons.arrow_back),
            )
          : null,
      floatingActionButtonLocation:
          !Platform.isAndroid ? FloatingActionButtonLocation.endFloat : null,
    );
  }
}

class MyNaverMap extends StatelessWidget {
  const MyNaverMap({
    super.key,
    required this.user_position,
  });

  final Future<Position> user_position;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: user_position,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return NaverMap(
            options: NaverMapViewOptions(
              initialCameraPosition: NCameraPosition(
                target: NLatLng(
                  snapshot.data!.latitude,
                  snapshot.data!.longitude,
                ),
                zoom: 16,
              ),
              // 실내 지도 활성화 유무
              indoorEnable: true,
              // 표시할 정보 레이어
              activeLayerGroups: [
                // 건물 레이어
                NLayerGroup.building,
              ],
            ),
            onMapReady: (controller) {
              NMarker userMarker = NMarker(
                id: "User",
                position: NLatLng(
                  snapshot.data!.latitude,
                  snapshot.data!.longitude,
                ),
                size: const Size(20, 30),
              );
              controller.addOverlay(userMarker);
              // NCircleOverlay circle = NCircleOverlay(
              //   id: "User",
              //   center: NLatLng(
              //     snapshot.data!.latitude,
              //     snapshot.data!.longitude,
              //   ),
              //   color: Colors.green.withOpacity(0.5),
              //   outlineColor: Colors.blue,
              //   radius: 30,
              // );
              // controller.addOverlay(circle);
            },
          );
        } else {
          return const Center(
            child: Text("Find User Position..."),
          );
        }
      },
    );
  }
}
