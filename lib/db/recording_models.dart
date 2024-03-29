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
  final String insightsDirPath;
  int? audioId;

  AudioRecord({
    this.id,
    required this.path,
    required this.comment,
    required this.timestamp,
    required this.isProcessed,
    required this.insightsDirPath,
    this.audioId,
  });

  Map<String, Object?> toMap() {
    var map = <String, Object?>{
      recordingIdColumn: id,
      filePathColumn: path,
      commentColumn: comment,
      timestampColumn: timestamp,
      isProcessedColumn: isProcessed,
      insightsDirPathColumn: insightsDirPath,
      audioIdColumn: audioId,
    };
    return map;
  }
}

class AudioRecordingProvider {
  AudioRecordingProvider();

  Future<AudioRecord?> createRecording(
      String filePath,String comment,String length,String timestamp, int audioId) async {
    Database db = await DatabaseHelper().database;
    AudioRecord recording = AudioRecord(
      path: filePath,
      comment: comment,
      isProcessed: 0,
      insightsDirPath: '',
      timestamp: timestamp,
      audioId: audioId,
    );
    print(recording.toMap());
    var r = await db.insert(recordingTable, recording.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    recording.id = r;
    return recording;
  }

  Future<AudioRecord?>getRecording(int id) async {
    Database db = await DatabaseHelper().database;
    if (id == -1) {
      return null;
    }

    List<Map<String, Object?>> maps = await db.query(recordingTable,
        where: '$recordingIdColumn = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return AudioRecord(
        id: maps[0][recordingIdColumn] as int,
        path: maps[0][filePathColumn] as String,
        comment: maps[0][commentColumn] as String,
        isProcessed: maps[0][isProcessedColumn] as int,
        insightsDirPath: maps[0][insightsDirPathColumn] as String,
        timestamp: maps[0][timestampColumn] as String,
        audioId: maps[0][audioIdColumn] as int,
      );
    }
    return null;
  }

  Future<List<AudioRecord>> getAll() async {
    Database db = await DatabaseHelper().database;
    List<Map<String, Object?>> maps = await db.query(recordingTable, orderBy: 'id DESC');
    List<AudioRecord> recordings = [];
    for (var map in maps) {
      recordings.add(AudioRecord(
        id: map[recordingIdColumn] as int,
        path: map[filePathColumn] as String,
        comment: map[commentColumn] as String,
        isProcessed: map[isProcessedColumn] as int,
        insightsDirPath: map[insightsDirPathColumn] as String,
        timestamp: map[timestampColumn] as String,
        audioId: maps[0][audioIdColumn] as int,
      ));
    }
    return recordings;
  }

  Future<bool> updateAudioId(String recordingId,String audioId) async {
    Database db = await DatabaseHelper().database;
    await db.update(
        recordingTable, // The name of your table
        {audioIdColumn: audioId},  // The column and new value
        where: 'id = ?',      // Selection criteria
        whereArgs: [recordingId]       // Arguments to prevent SQL injection
    );
    return true;
  }

  Future<bool> updateRecording(AudioRecord recording) async {
    Database db = await DatabaseHelper().database;
    int r = await db.update(recordingTable, recording.toMap(),
        where: '$recordingIdColumn = ?', whereArgs: [recording.id]);
    if (r < 1) {
      return false;
    }
    return true;
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
