import 'dart:io';

import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sql.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';

import 'package:tracking_goals/utils/edit_dailies_body.dart';

class Dailies {
  int? id;
  String taskName;
  bool isCompleted;
  String? taskDescription;
  List<Dailies> subDailies = [];
  bool isTop;

  Dailies({
    this.id,
    required this.taskName,
    required this.isCompleted,
    this.taskDescription,
    required this.isTop,
  });

  factory Dailies.fromMap(Map<String, dynamic> result) {
    var dailies = Dailies(
        id: result["id"],
        taskName: result["taskName"],
        isCompleted: result["isCompleted"] == "true" ? true : false,
        taskDescription: result["taskDescription"],
        isTop: result["isTop"]);

    dailies.subDailies = json.decode(result["subDailies"]);

    return dailies;
  }

  Map<String, dynamic> toMap({required int isTop}) {
    return {
      'id': id,
      'taskName': taskName,
      'isCompleted': isCompleted,
      'taskDescription': taskDescription,
      'isTop': isTop
    };
  }
}

class DatabaseHelper {
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async => _database ??= await _initDatabase();

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'dailies.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _oncreate,
    );
  }

  Future _oncreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE dailies(
        id INTEGER PRIMARY KEY,
        taskName TEXT,
        isCompleted TEXT,
        taskDescription TEXT,
        subDailies TEXT,
        isTop TEXT
      )
    ''');
  }

  Future<List<Dailies>> getDailies() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'dailies.db');
    deleteDatabase(path);

    // Database db = await instance.database;
    // var dailies = await db.query('dailies', where: 'isTop = 1', orderBy: 'id');
    // List<Dailies> dailiesList = dailies.isNotEmpty
    //     ? dailies.map((e) => Dailies.fromMap(e)).toList()
    //     : [];

    // return dailiesList;
    return [];
  }

  Future<int> addDailies(Dailies dailies) async {
    List<int> subDailiesList = [];
    if (dailies.subDailies.isNotEmpty) {
      dailies.subDailies.forEach((subDailies) {
        subDailiesList.add(subDailies.id ?? 0);
      });
    }

    Database db = await instance.database;
    return await db.rawInsert('''
      INSERT INTO dailies(taskName, isCompleted, taskDescription, isTop, subDailies) VALUES(?, ?, ?, ?, ?)
    ''', [
      dailies.taskName,
      dailies.isCompleted == true ? "true" : "false",
      dailies.taskDescription,
      dailies.isTop == true ? "true" : "false",
      subDailiesList.toString()
    ]);
  }

  Future<int> addSubDailies(Dailies dailies) async {
    Database db = await instance.database;
    await db.rawInsert('''
      INSERT INTO dailies(taskName, isCompleted, taskDescription, isTop, subDailies) VALUES(?, ?, ?, ?, ?)
    ''', ["", "false", "", "false", "[]"]);

    List<Map> maxId = await db.rawQuery('''
      SELECT max(id) FROM dailies
    ''');

    List<int> subDailiesList = [];
    if (dailies.subDailies.isNotEmpty) {
      dailies.subDailies.forEach((subDailies) {
        subDailiesList.add(subDailies.id ?? 0);
      });
    }
    subDailiesList.add(maxId[0]["max(id)"]);

    return await db.rawUpdate('''
      UPDATE dailies SET subDailies = ? WHERE id = ?
    ''', [subDailiesList.toString(), dailies.id]);
  }

  Future<Dailies> getSingleDailies(id) async {
    Database db = await instance.database;
    List<Map> result = await db.query('dailies', where: 'id = $id');

    var temp = Dailies(
      id: result[0]["id"],
      taskName: result[0]["taskName"],
      isCompleted: result[0]["isCompleted"] == "true" ? true : false,
      taskDescription: result[0]["taskDescription"],
      isTop: result[0]["isTop"] == "true" ? true : false,
    );

    temp.subDailies =
        await getAllSubDailies(result[0]["subDailies"].toString());
    return temp;
  }

  Future<int> removeTopDailies(int id) async {
    Database db = await instance.database;

    var result = await db.rawQuery('''
      SELECT subDailies FROM dailies WHERE id = ?
    ''', [id]);

    String subDailiesList = result[0]["subDailies"].toString();
    subDailiesList = subDailiesList.substring(1, subDailiesList.length - 1);

    await db.rawDelete('''
      DELETE FROM dailies WHERE id IN ($subDailiesList)
    ''');

    return await db.rawDelete('''
      DELETE FROM dailies WHERE id = ?
    ''', [id]);
  }

  Future<int> removeSubDailies(int subId, int topId) async {
    Database db = await instance.database;
    await db.rawDelete('''
      DELETE FROM dailies WHERE id = ?
    ''', [subId]);

    var result = await db.rawQuery('''
      SELECT subDailies FROM dailies WHERE id = ?
    ''', [topId]);

    List subDailiesList = json.decode(result[0]["subDailies"].toString());
    subDailiesList.remove(subId);

    return await db.rawUpdate('''
      UPDATE dailies SET subDailies = ? WHERE id = ?
    ''', [subDailiesList.toString(), topId]);
  }

  Future<List<Dailies>> test() async {
    Database db = await instance.database;
    await db.rawUpdate('''
      UPDATE dailies SET subDailies = ?, isTop = ? WHERE id = ?
    ''', [
      [3],
      "true",
      1
    ]);
    await db.rawUpdate('''
      UPDATE dailies SET isTop = ? WHERE id = ?
    ''', ["false", 3]);
    return [];
  }

  Future<int> updateDailies(
      String taskName, String taskDescription, int id) async {
    Database db = await instance.database;
    return await db.rawUpdate('''
      UPDATE dailies SET taskName = ?, taskDescription = ? WHERE id = ?
    ''', [taskName, taskDescription, id]);
  }

  Future<int> updateSubDailies(String taskName, int id) async {
    Database db = await instance.database;
    return await db.rawUpdate('''
      UPDATE dailies SET taskName = ? WHERE id = ?
    ''', [taskName, id]);
  }

  Future<int> updateIsCompleted(String isCompleted, int id) async {
    Database db = await instance.database;
    return await db.rawUpdate('''
      UPDATE dailies SET isCompleted = ? WHERE id = ?
    ''', [isCompleted, id]);
  }

  Future<int> updateIsCompletedForTopDailies(String isCompleted, int id) async {
    Database db = await instance.database;
    await db.rawUpdate('''
      UPDATE dailies SET isCompleted = ? WHERE id = ?
    ''', [isCompleted, id]);

    var result = await db.rawQuery('''
      SELECT subDailies FROM dailies WHERE id = ?
    ''', [id]);

    String subDailiesList = result[0]["subDailies"].toString();
    subDailiesList = subDailiesList.substring(1, subDailiesList.length - 1);

    return await db.rawUpdate('''
      UPDATE dailies SET isCompleted = ? WHERE id IN ($subDailiesList)
    ''', [isCompleted]);
  }

  Future<List> getSubDailiesList(int id) async {
    Database db = await instance.database;
    List<Map> result = await db.rawQuery('''
      SELECT subDailies FROM dailies WHERE id = ?
    ''', [id]);
    return json.decode(result[0]["subDailies"]);
  }

  Future<List<Dailies>> getSubDailies(List SubDailiesList) async {
    Database db = await instance.database;
    List<Map> results = await db.rawQuery('''
      SELECT * FROM dailies WHERE id (?, ?)
    ''', [SubDailiesList]);

    List<Dailies> subDailies = [];
    for (var result in results) {
      subDailies.add(Dailies(
        id: result["id"],
        taskName: result["taskName"],
        isCompleted: result["isCompleted"],
        taskDescription: result["taskDescription"],
        isTop: result["isTop"],
      ));
    }
    return subDailies;
  }

  Future<List<Dailies>> getAllDailies() async {
    List<Dailies> dailies = [];
    Database db = await instance.database;
    List<Map> topDailiesResults =
        await db.query('dailies', where: 'isTop = "true"', orderBy: 'id');

    for (Map topDailiesResult in topDailiesResults) {
      var temp = Dailies(
        id: topDailiesResult["id"],
        taskName: topDailiesResult["taskName"],
        isCompleted: topDailiesResult["isCompleted"] == "true" ? true : false,
        taskDescription: topDailiesResult["taskDescription"],
        isTop: topDailiesResult["isTop"] == "true" ? true : false,
      );
      print(temp.isTop);
      temp.subDailies =
          await getAllSubDailies(topDailiesResult["subDailies"].toString());
      dailies.add(temp);
    }

    return dailies;
  }

  Future<List<Dailies>> getAllSubDailies(String subDailiesList) async {
    if (json.decode(subDailiesList).isEmpty) {
      return [];
    }

    subDailiesList = subDailiesList.substring(1, subDailiesList.length - 1);

    Database db = await instance.database;
    List<Map> subDailiesResults = await db.rawQuery('''
      SELECT * FROM dailies WHERE id IN ($subDailiesList)
    ''');

    List<Dailies> list = [];

    for (var subDailiesResult in subDailiesResults) {
      var temp = Dailies(
        id: subDailiesResult["id"],
        taskName: subDailiesResult["taskName"],
        isCompleted: subDailiesResult["isCompleted"] == "true" ? true : false,
        taskDescription: subDailiesResult["taskDescription"],
        isTop: subDailiesResult["isTop"] == "true" ? true : false,
      );

      // List subDailiesList = json.decode(subDailiesResult["subDailies"]);
      temp.subDailies =
          await getAllSubDailies(subDailiesResult["subDailies"].toString());
      list.add(temp);
    }

    return list;
  }
}
