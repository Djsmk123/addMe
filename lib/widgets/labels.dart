import 'package:flutter/material.dart';
// ignore: camel_case_types

//Widget for Labels
class Label extends StatelessWidget {
  final String title;
  // ignore: use_key_in_widget_constructors
  const Label({ this.title="",});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).size.width>500?EdgeInsets.fromLTRB(MediaQuery.of(context).size.width/5, 20, MediaQuery.of(context).size.width/5, 0):EdgeInsets.fromLTRB(MediaQuery.of(context).size.width/10, 20, MediaQuery.of(context).size.width/10, 0),
      child:  Text(title,style: const TextStyle(
        fontSize: 14,
        letterSpacing: 5,
        fontWeight: FontWeight.w600,
        color: Color(0XFFee8d56),
      ),
      ),
    );
  }
}