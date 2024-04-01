import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

import '../const/consts.dart';
import 'db_helper.dart';

class AudioSampleRecord {
  int? id;
  final String path;
  final String comment;
  final String timestamp;
  final int isProcessed;
  final String insightsDirPath;
  int? audioId;

  AudioSampleRecord({
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
      sampleRecordIdColumn: id,
      sampleRecordFilePathColumn: path,
      sampleRecordCommentColumn: comment,
      sampleRecordTimestampColumn: timestamp,
      sampleRecordIsProcessedColumn: isProcessed,
      sampleRecordInsightsDirPathColumn: insightsDirPath,
      sampleRecordAudioIdColumn: audioId,
    };

    return map;
  }
}

Future<void> createSampleRecordingTable(Database db) async {
  await db.execute('''
        create table $sampleRecordTable (
          $sampleRecordIdColumn INTEGER PRIMARY KEY AUTOINCREMENT,
          $sampleRecordFilePathColumn TEXT NOT NULL,
          $sampleRecordCommentColumn TEXT NOT NULL,
          $sampleRecordIsProcessedColumn INTEGER NOT NULL DEFAULT 0,
          $sampleRecordInsightsDirPathColumn TEXT NOT NULL,
          $sampleRecordTimestampColumn TEXT NOT NULL,
          $sampleRecordAudioIdColumn INTEGER NOT NULL
        );
      ''');
}

class AudioSampleRecordingProvider {
  AudioSampleRecordingProvider();

  Future<AudioSampleRecord?> createRecording(
      String filePath,String comment,String length,String timestamp, int audioId) async {
    Database db = await DatabaseHelper().database;
    AudioSampleRecord recording = AudioSampleRecord(
      path: filePath,
      comment: comment,
      isProcessed: 0,
      insightsDirPath: '',
      timestamp: timestamp,
      audioId: audioId,
    );
    print(recording.toMap());
    var r = await db.insert(sampleRecordTable, recording.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    recording.id = r;
    return recording;
  }

  Future<List<AudioSampleRecord>> getAll() async {
    Database db = await DatabaseHelper().database;
    List<Map<String, Object?>> maps = await db.query(sampleRecordTable);
    List<AudioSampleRecord> recordings = [];
    for (var map in maps) {
      recordings.add(AudioSampleRecord(
        id: map[sampleRecordIdColumn] as int,
        path: map[sampleRecordFilePathColumn] as String,
        comment: map[sampleRecordCommentColumn] as String,
        isProcessed: map[sampleRecordIsProcessedColumn] as int,
        insightsDirPath: map[sampleRecordInsightsDirPathColumn] as String,
        timestamp: map[sampleRecordTimestampColumn] as String,
        audioId: maps[0][sampleRecordAudioIdColumn] as int,
      ));
    }

    return recordings;
  }
}
