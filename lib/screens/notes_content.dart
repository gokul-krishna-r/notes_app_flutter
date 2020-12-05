import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:note_app_flutter/models/note_model.dart';
import 'package:note_app_flutter/utils/note_database_helper.dart';
import 'package:intl/intl.dart';

class NotesContent extends StatefulWidget {
  NoteModel noteModel;
  String appBarTitle;
  String createBtnText;

  NotesContent(NoteModel noteModel, String appBarTitle, String createBtnText) {
    this.noteModel = noteModel;
    this.appBarTitle = appBarTitle;
    this.createBtnText = createBtnText;
  }

  @override
  State<StatefulWidget> createState() {
    //TODO: Creating Constructor in StateFul class and State to get value from last route
    return _NotesContentState(noteModel, appBarTitle, createBtnText);
  }
}

class _NotesContentState extends State<NotesContent> {
  var _formKey = GlobalKey<FormState>();
  static var _priorities = ["High", "Normal"];
  var minimumPadding = 5.0;

  String createBtnText;
  String appBarTitle;
  NoteModel noteModel;

  _NotesContentState(
      NoteModel noteModel, String appBarTitle, String createBtnText) {
    this.noteModel = noteModel;
    this.appBarTitle = appBarTitle;
    this.createBtnText = createBtnText;
  }

  NoteDataBaseHelper noteDataBaseHelper = NoteDataBaseHelper();
  String newTitle;
  String newDescription;

  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    titleController.text = noteModel.title;
    contentController.text = noteModel.description;

    return WillPopScope(
        //Controlling the back button click action
        //TODO: Back Button Click
        onWillPop: () {
          moveToLastScreen();
        },
        child: Scaffold(
            appBar: AppBar(
              title: Text(appBarTitle),
              leading: IconButton(
                //Controlling the backbutton on apppBar
                icon: Icon(Icons.arrow_back_sharp),
                onPressed: () {
                  moveToLastScreen();
                },
              ),
            ),
            body: Padding(
              padding: EdgeInsets.all(minimumPadding * 3),
              child: Form(
                  key: _formKey,
                  child: ListView(
                    children: <Widget>[
                      DropdownButton<String>(
                          items: _priorities.map((String dropDownItem) {
                            return DropdownMenuItem<String>(
                              value: dropDownItem,
                              child: Text(dropDownItem),
                            );
                          }).toList(),
                          onChanged: (String selectedValue) {
                            setState(() {
                              noteModel.priority =
                                  getPriorityAsInt(selectedValue);
                            });
                          },
                          value: getPriorityAsString(noteModel.priority)),
                      Padding(
                          padding: EdgeInsets.only(
                              top: minimumPadding * 2,
                              bottom: minimumPadding * 2),
                          child: TextFormField(
                              validator: (value) {
                                if (value.isEmpty) {
                                  return "Enter Title";
                                }
                              },
                              decoration: InputDecoration(
                                  labelText: "Title",
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(5.0))),
                              controller: titleController,
                              onChanged: (value) {
                                updateTitle();
                              })),
                      Padding(
                        padding: EdgeInsets.only(
                            top: minimumPadding * 2,
                            bottom: minimumPadding * 2),
                        child: TextField(
                            keyboardType: TextInputType.multiline,
                            minLines: 12,
                            maxLines: null,
                            decoration: InputDecoration(
                                labelText: "Description",
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5.0))),
                            controller: contentController,
                            onChanged: (value) {
                              updateDescription();
                            }),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: RaisedButton(
                              child: Text(createBtnText, textScaleFactor: 1.5),
                              color: Theme.of(context).primaryColorDark,
                              textColor: Theme.of(context).primaryColorLight,
                              onPressed: () {
                                setState(() {
                                  debugPrint("Create Clicked");
                                  if (_formKey.currentState.validate()) {
                                    _insert();
                                    moveToLastScreen();
                                  }
                                });
                              },
                            ),
                          ),
                          SizedBox(
                            width: minimumPadding * 2,
                          ),
                          Expanded(
                              child: FlatButton(
                            child: Text("Delete", textScaleFactor: 1.5),
                            textColor: Theme.of(context).primaryColorDark,
                            onPressed: () {
                              setState(() {
                                debugPrint("Delete Clicked");
                                _delete();
                              });
                            },
                          ))
                        ],
                      ),
                    ],
                  )),
            )));
  }

  void moveToLastScreen() {
    //TODO: returning to last route
    Navigator.pop(context, true);
  }

  void _insert() async {
    // Map<String, dynamic> map = {
    //   noteDataBaseHelper.colTitle: noteModel.title,
    //   noteDataBaseHelper.colDescription: noteModel.description,
    //   noteDataBaseHelper.colPriority: 1,
    //   noteDataBaseHelper.colDate: DateFormat.yMMMd().format(DateTime.now())
    // };
    noteModel.date = DateFormat.yMMMd().format(DateTime.now());

    if (noteModel.id == null) {
      await noteDataBaseHelper.insertNote(noteModel);
    } else {
      await noteDataBaseHelper.updateNote(noteModel);
    }
  }

  void _delete() async {
    if (noteModel.id == null) {
      _showAlertDialog("Status", "No New Note to delete");
      return;
    }
    int result = await noteDataBaseHelper.deleteNote(noteModel);
    if (result != 0) {
      _showAlertDialog("Success", "Note Deleted Successfully");
      titleController.text = "";
      contentController.text = "";
      debugPrint('${noteModel.id}');
    } else {
      _showAlertDialog("Error", "Error Occurred");
    }
  }

  void updateTitle() {
    noteModel.title = titleController.text;
  }

  void updateDescription() {
    noteModel.description = contentController.text;
    debugPrint(noteModel.description);
  }

  int getPriorityAsInt(String value) {
    int priorityInt;
    switch (value) {
      case 'High':
        return priorityInt = 1;
        break;
      case 'Normal':
        return priorityInt = 2;
        break;
      default:
        return priorityInt = 1;
    }
  }

  String getPriorityAsString(int value) {
    String priorityString;
    switch (value) {
      case 1:
        priorityString = _priorities[0];
        break;
      case 2:
        priorityString = _priorities[1];
        break;
    }
    return priorityString;
  }

  void _showAlertDialog(String status, String msg) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(status),
      content: Text(msg),
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return alertDialog;
        });
  }
}
