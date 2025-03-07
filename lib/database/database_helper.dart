import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'queue_system.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Create tables when database is first created
        await db.execute('''
          CREATE TABLE settings (
            key TEXT PRIMARY KEY,
            value TEXT
          )
        ''');

        // Insert default settings if needed
        await db.insert(
          'settings',
          {'key': 'settingLoginPassword', 'value': ''},
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      },
      onUpgrade: (Database db, int oldVersion, int newVersion) async {
        // Handle database upgrades here
      },
    );
  }

  Future<Map<String, String>> getSettings() async {
    final db = await database;
    final List<Map<String, dynamic>> settings = await db.query('settings');
    
    // Convert list of {key: x, value: y} to single map {x: y}
    final Map<String, String> settingsMap = {};
    for (var setting in settings) {
      settingsMap[setting['key'] as String] = (setting['value'] ?? '').toString();
    }
    return settingsMap;
  }

  Future<void> updateSettings(Map<String, String> settings) async {
    final db = await database;
    final batch = db.batch();
    
    settings.forEach((key, value) {
      batch.insert(
        'settings',
        {
          'key': key,
          'value': value,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
    
    await batch.commit();
  }

  Future<void> saveLoginCredentials(String username, String password) async {
    final db = await database;
    final batch = db.batch();
    
    batch.insert(
      'settings',
      {'key': 'username', 'value': username},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    batch.insert(
      'settings',
      {'key': 'password', 'value': password},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    await batch.commit();
  }

  Future<Map<String, String>> getLoginCredentials() async {
    final db = await database;
    final List<Map<String, dynamic>> settings = await db.query(
      'settings',
      where: 'key IN (?, ?)',
      whereArgs: ['username', 'password'],
    );
    
    final Map<String, String> credentials = {};
    for (var setting in settings) {
      credentials[setting['key'] as String] = (setting['value'] ?? '').toString();
    }
    
    return {
      'username': credentials['username'] ?? '',
      'password': credentials['password'] ?? '',
    };
  }

  // Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
} 