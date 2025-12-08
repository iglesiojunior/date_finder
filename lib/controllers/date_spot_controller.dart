import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/date_spot_model.dart';

class DateSpotController extends ChangeNotifier {
  List<DateSpot> dateSpots = [];

  Future<void> loadDateSpots({int? userId}) async {
    if (userId != null) {
      dateSpots = await DbHelper().getDatesByUserId(userId);
    } else {
      dateSpots = await DbHelper().getDates();
    }
    notifyListeners();
  }

  Future<void> addDateSpot(DateSpot spot) async {
    await DbHelper().insertDateSpot(spot);
    await loadDateSpots(userId: spot.userId);
  }

  Future<void> deleteDateSpot(int id, {int? userId}) async {
    await DbHelper().deleteDate(id);
    await loadDateSpots(userId: userId);
  }
}
