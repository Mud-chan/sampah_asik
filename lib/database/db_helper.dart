import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'users.db');
    return openDatabase(
      path,
      version: 4, // ⬅️ NAIKKAN KE 4
      onCreate: (db, version) async {
        // ================= USERS =================
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT,
            profile_image TEXT,
            exp INTEGER DEFAULT 0
          )
        ''');

        // ================= SAVED WASTE =================
        await db.execute('''
          CREATE TABLE waste_saved(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT,
            waste_name TEXT,
            stars INTEGER,
            saved_at TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE users ADD COLUMN profile_image TEXT',
          );
        }

        if (oldVersion < 3) {
          await db.execute(
            'ALTER TABLE users ADD COLUMN exp INTEGER DEFAULT 0',
          );
        }

        if (oldVersion < 4) {
          await db.execute('''
            CREATE TABLE waste_saved(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              username TEXT,
              waste_name TEXT,
              stars INTEGER,
              saved_at TEXT
            )
          ''');
        }
      },
    );
  }

  // ===================== AUTH =====================

  static Future<int> register(String username, String password) async {
    final db = await database;
    return db.insert(
      'users',
      {
        'username': username,
        'password': password,
        'profile_image': null,
        'exp': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  static Future<bool> login(String username, String password) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    return result.isNotEmpty;
  }

  // ===================== USER DATA =====================

  static Future<Map<String, dynamic>?> getUser(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty ? result.first : null;
  }

  static Future<void> updateProfileImage(
    String username,
    String imagePath,
  ) async {
    final db = await database;
    await db.update(
      'users',
      {'profile_image': imagePath},
      where: 'username = ?',
      whereArgs: [username],
    );
  }

  static Future<String?> getProfileImage(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['profile_image'],
      where: 'username = ?',
      whereArgs: [username],
    );

    return result.isNotEmpty ? result.first['profile_image'] as String? : null;
  }

// ===================== UPDATE USERNAME =====================
  static Future<void> updateUsername(
    String oldUsername,
    String newUsername,
  ) async {
    final db = await database;

    // Update username di tabel users
    await db.update(
      'users',
      {'username': newUsername},
      where: 'username = ?',
      whereArgs: [oldUsername],
    );

    // Update username di tabel waste_saved
    await db.update(
      'waste_saved',
      {'username': newUsername},
      where: 'username = ?',
      whereArgs: [oldUsername],
    );
  }

  // ===================== EXP SYSTEM =====================

  static Future<int> getExp(String username) async {
    final db = await database;
    final result = await db.query(
      'users',
      columns: ['exp'],
      where: 'username = ?',
      whereArgs: [username],
    );

    return result.isNotEmpty ? result.first['exp'] as int : 0;
  }

  static Future<void> addExp(String username, int amount) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE users SET exp = exp + ? WHERE username = ?',
      [amount, username],
    );
  }

  // ===================== SAVE WASTE =====================
  // ⬅️ INI YANG TADI ERROR & SEKARANG SUDAH ADA

  static Future<void> saveWaste({
    required String username,
    required String wasteName,
    required int stars,
  }) async {
    final db = await database;

    await db.insert(
      'waste_saved',
      {
        'username': username,
        'waste_name': wasteName,
        'stars': stars,
        'saved_at': DateTime.now().toIso8601String(),
      },
    );
  }

  // (Optional) ambil daftar sampah tersimpan
  static Future<List<Map<String, dynamic>>> getSavedWaste(
    String username,
  ) async {
    final db = await database;
    return db.query(
      'waste_saved',
      where: 'username = ?',
      whereArgs: [username],
      orderBy: 'saved_at DESC',
    );
  }

  // ===================== DELETE WASTE =====================
  static Future<void> deleteWaste(int id) async {
    final db = await database;
    await db.delete(
      'waste_saved',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
