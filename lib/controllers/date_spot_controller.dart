import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/date_spot_model.dart';

class DateSpotController extends ChangeNotifier {
  List<DateSpot> dateSpots = [];

  Future<void> loadDateSpots() async {
    dateSpots = await DbHelper().getDates();

    notifyListeners();
  }

  Future<void> addDateSpot(DateSpot spot) async {
    await DbHelper().insertDateSpot(spot);
    await loadDateSpots();
  }

  Future<void> deleteDateSpot(int id) async {
    await DbHelper().deleteDate(id);
    await loadDateSpots();
  }
}
