import 'package:flutter/material.dart';

class DialogBox extends StatefulWidget {
  const DialogBox(
      {super.key,
      required this.taskNameController,
      required this.taskDescriptionController,
      required this.onSave,
      required this.onCancel});
  final taskNameController;
  final taskDescriptionController;
  final VoidCallback onSave;
  final VoidCallback onCancel;
  @override
  State<DialogBox> createState() => _DialogBoxState();
}

class _DialogBoxState extends State<DialogBox> {
  bool isDescriptionPressed = false;

  FocusNode descriptionField = FocusNode();

  void descriptionPressed() {
    descriptionField.requestFocus();
    setState(() {
      isDescriptionPressed = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      insetPadding: EdgeInsets.zero,
      content: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Container(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: new BorderRadius.only(
                    topLeft: const Radius.circular(20.0),
                    topRight: const Radius.circular(20.0),
                  )),
              width: double.infinity,
              child: Column(
                children: [
                  Container(
                    height: 40,
                    margin: EdgeInsets.fromLTRB(20, 10, 20, 0),
                    child: SizedBox(
                      child: TextField(
                        controller: widget.taskNameController,
                        autofocus: true,
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.zero,
                          hintText: "New dailies",
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  isDescriptionPressed
                      ? Container(
                          height: 40,
                          margin: EdgeInsets.fromLTRB(20, 0, 20, 5),
                          child: TextField(
                            controller: widget.taskDescriptionController,
                            focusNode: descriptionField,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              hintText: "Add description",
                              border: InputBorder.none,
                            ),
                          ),
                        )
                      : SizedBox(),
                  Container(
                    height: 60,
                    margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          IconButton(
                              iconSize: 26,
                              onPressed: descriptionPressed,
                              icon: Icon(Icons.library_books)),
                          Spacer(),
                          TextButton(
                            onPressed: widget.onSave,
                            child: const Text(
                              'Save',
                              style: TextStyle(fontSize: 20),
                            ),
                          )
                        ]),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
