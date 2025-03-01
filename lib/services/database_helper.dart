import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('cnc_users.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // ✅ Incremented version for migration
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            regno TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password TEXT,
            section TEXT,  -- ✅ Added Section field
            auth_type TEXT NOT NULL DEFAULT 'password'
          )
        ''');

        await db.execute('''
          CREATE TABLE history (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            email TEXT NOT NULL,
            action TEXT NOT NULL,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          // ✅ Add `section` column for existing users during migration
          await db.execute("ALTER TABLE users ADD COLUMN section TEXT");
        }
      },
    );
  }

  /// ✅ **Check if user exists**
  Future<bool> userExists(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty;
  }

  /// ✅ **Insert a new user (with Section)**
  Future<void> insertUser(
    String name,
    String regno,
    String email,
    String? password,
    String section, // ✅ Added section parameter
    String authType,
  ) async {
    final db = await database;
    await db.insert('users', {
      'name': name,
      'regno': regno,
      'email': email,
      'password': password,
      'section': section, // ✅ Store section in DB
      'auth_type': authType,
    });
    await insertHistory(email, 'Registered via $authType');
  }

  /// ✅ **Get user details (including section)**
  Future<Map<String, dynamic>?> getUser(String email) async {
    final db = await database;
    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );

    if (result.isNotEmpty) {
      return result.first;
    }
    return null;
  }

  /// ✅ **Get logged-in user details**
  Future<Map<String, dynamic>?> getLoggedInUser(String email) async {
    return await getUser(email);
  }

  /// Debug Email User
  Future<void> debugCheckUser(String email) async {
    final user = await getUser(email);
    if (user != null) {
      print("✅ User found: $user");
    } else {
      print("❌ User not found in database: $email");
    }
  }

  /// ✅ **Validate user credentials**
  Future<bool> validateUser(String email, String password) async {
    final user = await getUser(email);
    if (user != null && user['password'] == password) {
      await insertHistory(email, 'Logged in');
      return true;
    }
    return false;
  }

  /// ✅ **Update user details (including section)**
  /// ✅ **Update user details (including section)**
  Future<int> updateUserDetails(
    String email,
    String newName,
    String newRegNo,
    String newSection, // ✅ Added section
  ) async {
    final db = await database;

    // ✅ Check if the user exists before updating
    final existingUser = await getUser(email);
    if (existingUser == null) {
      print("⚠️ User not found: $email");
      return 0; // Return 0 to indicate failure
    }

    try {
      int rowsAffected = await db.update(
        'users',
        {
          'name': newName,
          'regno': newRegNo,
          'section': newSection, // ✅ Update section
        },
        where: 'email = ?',
        whereArgs: [email],
      );

      if (rowsAffected > 0) {
        print("✅ User details updated successfully for $email");
      } else {
        print("⚠️ Update failed. No rows affected for $email");
      }

      return rowsAffected;
    } catch (e) {
      print("❌ Error updating user: $e");
      return 0;
    }
  }

  /// ✅ **Insert history entry**
  Future<void> insertHistory(String email, String action) async {
    final db = await database;
    await db.insert('history', {
      'email': email,
      'action': action,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  /// ✅ **Fetch user history**
  Future<List<Map<String, dynamic>>> getUserHistory(String email) async {
    final db = await database;
    return await db.query(
      'history',
      where: 'email = ?',
      whereArgs: [email],
      orderBy: 'timestamp DESC',
    );
  }

  /// ✅ **Reset password functionality**
  Future<void> resetPassword(String email, String newPassword) async {
    final db = await database;
    await db.update(
      'users',
      {'password': newPassword},
      where: 'email = ?',
      whereArgs: [email],
    );
    await insertHistory(email, 'Reset password');
  }

  /// ✅ **Logout function**
  Future<void> logout(String email) async {
    await insertHistory(email, 'Logged out');
    print("User logged out successfully!");
  }
}
