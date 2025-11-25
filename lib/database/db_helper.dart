import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/date_spot_model.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  static Database? _database;

  factory DbHelper() {
    return _instance;
  }

  DbHelper._internal();

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'date_spots.db');
    return await openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB();
    return _database!;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE date_spot(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        date TEXT NOT NULL,
        notes TEXT,
        rating REAL)
''');
  }

  Future<int> insertDateSpot(DateSpot spot) async {
    final db = await database;
    return await db.insert('date_spot', spot.toMap());
  }

  Future<List<DateSpot>> getDates() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('date_spot');
    
    return List.generate(maps.length, (i) {
      return DateSpot.fromMap(maps[i]);
    });
  }
  
  Future<int> deleteDate(int id) async {
    Database db = await database;
    return await db.delete('date_spot', where: 'id = ?', whereArgs: [id]);
  }
}
