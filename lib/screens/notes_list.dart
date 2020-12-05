import 'package:flutter/material.dart';
import 'package:note_app_flutter/models/note_model.dart';
import 'package:note_app_flutter/screens/notes_content.dart';
import 'package:note_app_flutter/utils/note_database_helper.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class NotesList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _NotesListState();
  }
}

class _NotesListState extends State<NotesList> {
  NoteDataBaseHelper noteDataBaseHelper = NoteDataBaseHelper();
  Future<List<NoteModel>> notes;

  Future<List<NoteModel>> fetchNotesFromDatabase() async { //Function to load and update database
    setState(() {
      notes = noteDataBaseHelper.getNotesAsList();
    });

    return notes;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Notes App"),
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          tooltip: "Add Note",
          onPressed: () {
            debugPrint("FAB Clicked");
            navigateToNoteContent(NoteModel("", "", 1), "Add Note", "Create");
          },
        ),
        body: FutureBuilder<List<NoteModel>>(
          future: fetchNotesFromDatabase(),
          builder: (context, snapShot) {
            if (snapShot.hasData) {
              return ListView.builder(
                itemCount: snapShot.data.length,
                itemBuilder: (context, index) {
                  return Card(
                      child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: getColor(snapShot.data[index].priority),
                      child: getIcon(snapShot.data[index].priority),
                    ),
                    title: Text(
                      snapShot.data[index].title,
                      style: Theme.of(context).textTheme.headline6,
                    ),
                    subtitle: Text(
                      snapShot.data[index].description ?? "",
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      maxLines: 3,
                    ),
                    trailing: GestureDetector(
                      child: Icon(Icons.delete),
                      onTap: () {
                        _delete(snapShot.data[index]);
                      },
                    ),
                    onTap: () {
                      debugPrint("ListTile Tapped");
                      navigateToNoteContent(
                          snapShot.data[index], "Edit Note", "Update");
                    },
                    onLongPress: () {
                      setState(() {});
                    },
                  ));
                },
              );
            } else if (!snapShot.hasData) {
              return new Text('No Data');
            }
            return new Container(child: CircularProgressIndicator());
          },
        ));
  }

  void _delete(NoteModel noteModel) async {
    int result = await noteDataBaseHelper.deleteNote(noteModel);
    if (result != 0) {
      fetchNotesFromDatabase();
    }
  }

  Color getColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.yellow;
        break;
      default:
        return Colors.yellow;
    }
  }

  Icon getIcon(int priority) {
    switch (priority) {
      case 1:
        return Icon(Icons.play_arrow);
        break;
      case 2:
        return Icon(Icons.keyboard_arrow_right);
        break;
      default:
        return Icon(Icons.keyboard_arrow_right);
    }
  }

  void _showSnackBar(BuildContext context, String msg) {
    var snackBar = SnackBar(content: Text(msg));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

//TODO: Next Screen Intent
  //TODO: Passing value to another route
  void navigateToNoteContent(
      NoteModel noteModel, String title, String createBtnText) async {
    bool result =
        await Navigator.push(context, MaterialPageRoute(builder: (context) {
      return NotesContent(
          noteModel, title, createBtnText); //Passing AppBar Tile to next route
    }));
    if (result) {
      fetchNotesFromDatabase();
    }
  }
}
