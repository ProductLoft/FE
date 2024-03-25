import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../const/consts.dart';
import 'db_helper.dart';

class AudioRecord {
  int? id;
  final String path;
  final String comment;
  final String timestamp;
  final int isProcessed;
  final String zipPath;

  AudioRecord({
    this.id,
    required this.path,
    required this.comment,
    required this.timestamp,
    required this.isProcessed,
    required this.zipPath,
  });

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      recordingIdColumn: id,
      filePathColumn: path,
      commentColumn: comment,
      timestampColumn: timestamp,
      isProcessedColumn: isProcessed,
      zipPathColumn: zipPath,
    };
    return map;
  }
}

class AudioRecordingProvider {
  AudioRecordingProvider();

  Future<AudioRecord?> createRecording(
      String filePath,String comment,String length,String timestamp) async {
    Database db = await DatabaseHelper().database;
    AudioRecord recording = AudioRecord(
      path: filePath,
      comment: comment,
      isProcessed: 0,
      zipPath: '',
      timestamp: timestamp,
    );
    print(recording.toMap());
    var r = await db.insert(recordingTable, recording.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    recording.id = r;
    return recording;
  }

  Future<AudioRecord?>getRecording(String id) async {
    Database db = await DatabaseHelper().database;
    List<Map<String, Object?>> maps = await db.query(recordingTable,
        where: '$recordingIdColumn = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return AudioRecord(
        id: maps[0][recordingIdColumn] as int,
        path: maps[0][filePathColumn] as String,
        comment: maps[0][commentColumn] as String,
        isProcessed: maps[0][isProcessedColumn] as int,
        zipPath: maps[0][zipPathColumn] as String,
        timestamp: maps[0][timestampColumn] as String,
      );
    }
    return null;
  }

  Future<List<AudioRecord>> getAll() async {
    Database db = await DatabaseHelper().database;
    List<Map<String, Object?>> maps = await db.query(recordingTable);
    List<AudioRecord> recordings = [];
    for (var map in maps) {
      recordings.add(AudioRecord(
        id: map[recordingIdColumn] as int,
        path: map[filePathColumn] as String,
        comment: map[commentColumn] as String,
        isProcessed: map[isProcessedColumn] as int,
        zipPath: map[zipPathColumn] as String,
        timestamp: map[timestampColumn] as String,
      ));
    }
    return recordings;
  }


  Future<bool> deleteRecording(int id) async {
    Database db = await DatabaseHelper().database;
    int r = await db
        .delete(recordingTable, where: '$recordingIdColumn = ?', whereArgs: [id]);
    if (r < 1) {
      return false;
    }
    return true;
  }



}
