import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../const/consts.dart';
import 'db_helper.dart';

class Recording {
  int? id;
  final String path;
  final String comment;
  final String length;
  final String timestamp;

  Recording({
    this.id,
    required this.path,
    required this.comment,
    required this.length,
    required this.timestamp,
  });

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      idColumn: id,
      filePathColumn: path,
      commentColumn: comment,
      lengthColumn: length,
      timestampColumn: timestamp,
    };
    return map;
  }
}

class RecordingProvider {
  RecordingProvider();

  Future<Recording?> createRecording(
      filePath, comment, length, timestamp) async {
    Database db = await DatabaseHelper().database;
    Recording recording = Recording(
      path: filePath,
      comment: comment,
      length: length,
      timestamp: timestamp,
    );
    print(recording.toMap());
    var r = await db.insert(recordingTable, recording.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    recording.id = r;
    return recording;
  }

  Future<List<Recording>> getAll() async {
    Database db = await DatabaseHelper().database;
    List<Map<String, Object?>> maps = await db.query(recordingTable);
    List<Recording> recordings = [];
    for (var map in maps) {
      recordings.add(Recording(
        id: map[idColumn] as int,
        path: map[filePathColumn] as String,
        comment: map[commentColumn] as String,
        length: map[lengthColumn] as String,
        timestamp: map[timestampColumn] as String,
      ));
    }
    return recordings;
  }

  Future<bool> deleteRecording(int id) async {
    Database db = await DatabaseHelper().database;
    int r = await db
        .delete(recordingTable, where: '$idColumn = ?', whereArgs: [id]);
    if (r < 1) {
      return false;
    }
    return true;
  }



}
