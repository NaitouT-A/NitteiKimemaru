import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ez2gether/app/views/top_view.dart';
import 'package:ez2gether/app/views/create_schedule.view.dart';
import 'package:ez2gether/app/views/room_detail_view.dart';

final goRouter = GoRouter(
  routes: [
    GoRoute(
        path: '/',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return const MaterialPage(child: MyHomePage());
        }),
    GoRoute(
        path: '/create',
        pageBuilder: (BuildContext context, GoRouterState state) {
          return const MaterialPage(child: CreateScheduleView());
        }),
    GoRoute(
        path: '/:roomId/:docId',
        pageBuilder: (BuildContext context, GoRouterState state) {
          String? roomId = state.pathParameters['roomId'];
          String? docId = state.pathParameters['docId'];
          if (roomId != null && docId != null) {
            return MaterialPage(
                child: RoomDetailsScreen(roomId: roomId, docId: docId));
          } else {
            throw Exception('Invalid room or document ID');
          }
        }),
  ],
);
