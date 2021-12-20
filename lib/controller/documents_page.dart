import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' as Foundation;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:worksites/utils/theme.dart';

class DocumentsPage extends StatefulWidget {
  DocumentsPage();
  _DocumentsState createState() => new _DocumentsState();
}

class _DocumentsState extends State<DocumentsPage> {
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

