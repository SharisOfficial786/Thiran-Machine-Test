import 'package:machine_test_thiran/common/models/details_model.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseProvider {
  static Database? _database;

  static const String tableName = 'cart';

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
      join(path, 'cart_database.db'),
      onCreate: (db, version) async {
        await db.execute(
          '''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY,
            productId INTEGER,
            title TEXT,
            price REAL,
            description TEXT,
            category TEXT,
            image TEXT,
            ratingRate REAL,
            ratingCount INTEGER,
            quantity INTEGER
          )
          ''',
        );
      },
      version: 1,
    );
  }

  /// function to insert data to db
  Future<void> addToDb(Item product) async {
    final db = await database;
    // Convert rating to JSON string
    await db.insert(
      tableName,
      product.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    ); // Use replace to handle conflicts
  }

  /// function to get the items from db
  Future<List<Item>> getDbItems() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) {
      return Item.fromJson(maps[i]);
    });
  }

  /// function to check whether db has data
  Future<bool> hasData() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM cart'),
        ) ??
        0;
    return count > 0;
  }

  /// TODO:- test
  /**
   * Future<void> storeApiResponseInDb() async {
  try {
    final ApiResponseModel apiResponse = await fetchApiResponse();

    final DbModel dbModel = DbModel(
      id: apiResponse.id,
      nodeId: apiResponse.nodeId,
      name: apiResponse.name,
      fullName: apiResponse.fullName,
      type: apiResponse.type,
      description: apiResponse.description,
      licenseName: apiResponse.license.name,
    );

    final Future<Database> database = openDatabase(
      join(await getDatabasesPath(), 'example_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE json_data('
          'id INTEGER PRIMARY KEY, '
          'node_id TEXT, '
          'name TEXT, '
          'full_name TEXT, '
          'type TEXT, '
          'description TEXT, '
          'license_name TEXT)',
        );
      },
      version: 1,
    );

    final Database db = await database;

    await db.insert(
      'json_data',
      dbModel.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  } catch (e) {
    print('Error storing API response in database: $e');
    // Handle error as needed
  }
}

   *  */ 
}
