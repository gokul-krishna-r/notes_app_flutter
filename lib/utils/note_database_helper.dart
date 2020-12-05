import 'package:note_app_flutter/models/note_model.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class NoteDataBaseHelper {
  String noteTable = 'note_table';
  String colId = 'id';
  String colTitle = 'title';
  String colDescription = 'description';
  String colDate = 'date';
  String colPriority = 'priority';

  static NoteDataBaseHelper instance; //singleton database helper
  static Database _db; //singleton database

  NoteDataBaseHelper._createInstance();

  factory NoteDataBaseHelper(){
    instance = NoteDataBaseHelper._createInstance();
    return instance;
  }

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }

    _db = await initializeDatabase();
    return _db;
  }

  initializeDatabase() async {
    //Creating path
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'notes.db';
    return await openDatabase(path, version: 1, onCreate: _createDb);
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute('''
        CREATE TABLE $noteTable(
        $colId INTEGER PRIMARY KEY AUTOINCREMENT,
        $colTitle TEXT,
        $colDescription TEXT,
        $colPriority INTEGER,
        $colDate TEXT
        )
    ''');
  }

//Fetch Operation
  Future<List<Map<String, dynamic>>> getNotes() async {
    Database db = await this.db;
    var result = db.query(noteTable, orderBy: '$colPriority ASC');
    return result;
  }

  Future<int> insertNote(NoteModel noteModel) async {
    Database db = await this.db;
    var result = db.insert(noteTable, noteModel.toMap());
    return result;
  }

  Future<int> updateNote(NoteModel noteModel) async {
    Database db = await this.db;
    var result = db.update(noteTable, noteModel.toMap(),
        where: '$colId is ?', whereArgs: [noteModel.id]);
    return result;
  }

  Future<int> deleteNote(NoteModel noteModel) async{
    Database db =  await this.db;
    var result = db.delete(noteTable,where: '$colId is ?',whereArgs: [noteModel.id]);
    return result;
  }

  Future<int> getCount() async{
    Database db = await this.db;
    var result = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM $noteTable'));
    return result;
  }

  Future<List<NoteModel>> getNotesAsList() async{
    var notes= await getNotes();
    int count = notes.length;

    List<NoteModel> notesList = List<NoteModel>();
    for(int i=0;i < count;i++){
      notesList.add(NoteModel.fromMap(notes[i]));
    }

    return notesList;
  }
}
