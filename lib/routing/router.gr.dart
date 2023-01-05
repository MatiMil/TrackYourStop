// **************************************************************************
// AutoRouteGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouteGenerator
// **************************************************************************
//
// ignore_for_file: type=lint

part of 'router.dart';

class _$AppRouter extends RootStackRouter {
  _$AppRouter([GlobalKey<NavigatorState>? navigatorKey]) : super(navigatorKey);

  @override
  final Map<String, PageFactory> pagesMap = {
    DepartureRoute.name: (routeData) {
      return MaterialPageX<dynamic>(
        routeData: routeData,
        child: const DeparturePage(),
      );
    },
    FavoriteRoute.name: (routeData) {
      return MaterialPageX<dynamic>(
        routeData: routeData,
        child: const FavoritePage(),
      );
    },
  };

  @override
  List<RouteConfig> get routes => [
        RouteConfig(
          DepartureRoute.name,
          path: '/',
        ),
        RouteConfig(
          FavoriteRoute.name,
          path: '/favorite-page',
        ),
      ];
}

/// generated route for
/// [DeparturePage]
class DepartureRoute extends PageRouteInfo<void> {
  const DepartureRoute()
      : super(
          DepartureRoute.name,
          path: '/',
        );

  static const String name = 'DepartureRoute';
}

/// generated route for
/// [FavoritePage]
class FavoriteRoute extends PageRouteInfo<void> {
  const FavoriteRoute()
      : super(
          FavoriteRoute.name,
          path: '/favorite-page',
        );

  static const String name = 'FavoriteRoute';
}
