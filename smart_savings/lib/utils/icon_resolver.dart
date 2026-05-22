import 'package:flutter/material.dart';

IconData iconFromName(String name) {
  switch (name) {
    case 'shield':
      return Icons.shield_outlined;
    case 'restaurant':
      return Icons.restaurant_outlined;
    case 'flight':
      return Icons.flight_takeoff_outlined;
    case 'home':
      return Icons.home_outlined;
    case 'trending_up':
      return Icons.trending_up;
    case 'sports_esports':
      return Icons.sports_esports_outlined;
    case 'shopping_bag':
      return Icons.shopping_bag_outlined;
    case 'local_hospital':
      return Icons.local_hospital_outlined;
    case 'school':
      return Icons.school_outlined;
    case 'directions_car':
      return Icons.directions_car_outlined;
    case 'movie':
      return Icons.movie_outlined;
    default:
      return Icons.folder_outlined;
  }
}
