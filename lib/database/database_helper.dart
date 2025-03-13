import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  Future<void> saveLoginCredentials(String username, String password, String linkAddress) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setString('password', password);
    await prefs.setString('linkAddress', linkAddress);
  }

  Future<void> saveLogoUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('logoUrl', url);
  }

  Future<String?> getLogoUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('logoUrl');
  }

  Future<Map<String, String>> getLoginCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'username': prefs.getString('username') ?? '',
      'password': prefs.getString('password') ?? '',
      'linkAddress': prefs.getString('linkAddress') ?? '',
      'serverDomain': prefs.getString('serverDomain') ?? 'https://singaporeq.com',
    };
  }

  Future<void> saveServerDomain(String domain) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('serverDomain', domain);
  }

  // Close database
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
} 