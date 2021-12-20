import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as Foundation;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:worksites/utils/theme.dart';

class PlanningPage extends StatefulWidget {
  PlanningPage();
  _planningState createState() => new _planningState();
}

class _planningState extends State<PlanningPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Authentification
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: fillColor,
        body: Container(),
    );
  }

  _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(message),
            duration: Duration(seconds: 10)
        )
    );
  }
}

