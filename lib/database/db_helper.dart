import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/date_spot_model.dart';
import '../models/user_model.dart';

class DbHelper {
  static final DbHelper _instance = DbHelper._internal();
  static Database? _database;

  factory DbHelper() {
    return _instance;
  }

  DbHelper._internal();

  Future<Database> _initDB() async {
    String path = join(await getDatabasesPath(), 'date_spots.db');
    return await openDatabase(path, version: 2, onCreate: _onCreate, onUpgrade: _onUpgrade);
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
        rating REAL,
        user_id INTEGER)
''');
    await db.execute('''
      CREATE TABLE users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        name TEXT)
''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE date_spot ADD COLUMN user_id INTEGER');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS users(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          email TEXT NOT NULL UNIQUE,
          password TEXT NOT NULL,
          name TEXT)
      ''');
    }
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

  // User methods
  Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  Future<List<DateSpot>> getDatesByUserId(int userId) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'date_spot',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
    
    return List.generate(maps.length, (i) {
      return DateSpot.fromMap(maps[i]);
    });
  }
}
