import 'package:machine_test_thiran/common/models/details_db_model.dart';
import 'package:machine_test_thiran/common/models/details_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  Database? _database;

  final String userDbName = 'user_database.db';
  final String userTable = 'user';

  /// function to retrieve the initialized database instance,
  /// initializing it if necessary, and returns it.
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDatabase();
    return _database!;
  }

  /// function to initialize SQFLite db
  Future<Database> initDatabase() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, userDbName),
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE $userTable(
            id INTEGER PRIMARY KEY,
            node_id INTEGER,
            name TEXT,
            full_name REAL,
            avatar_url TEXTs
          )
          ''',
        );
      },
      version: 1,
    );
  }

  /// function to batch insert data to db
  Future<void> insertDetails(List<DetailsDbModel> details) async {
    final db = await database;
    final batch = db.batch();
    for (var detail in details) {
      batch.insert(
        userTable,
        detail.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  /// function to get the items from db
  Future<List<DetailsDbModel>> getDbItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(userTable);
    return List.generate(maps.length, (i) {
      return DetailsDbModel.fromJson(maps[i]);
    });
  }

  /// function to check whether db has data
  Future<bool> hasData() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM $userTable'),
        ) ??
        0;
    return count > 0;
  }

  /// function to clear db
  Future<void> clearDatabase() async {
    final db = await database;
    await db.rawDelete("DELETE FROM $userTable");
  }

  /// function to convert to DetailsDbModel
  DetailsDbModel convertFunction(Item data) {
    return DetailsDbModel(
      id: data.id,
      nodeId: data.nodeId,
      name: data.name,
      fullName: data.fullName,
      avatarUrl: data.owner?.avatarUrl,
    );
  }
}
