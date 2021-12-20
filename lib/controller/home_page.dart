import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:badges/badges.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:worksites/controller/activity_page.dart';
import 'package:worksites/controller/documents_page.dart';
import 'package:worksites/controller/planning_page.dart';
import 'package:worksites/controller/worksites_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:worksites/main.dart';
import 'package:worksites/utils/app_localizations.dart';
import 'package:worksites/utils/constants.dart';
import 'package:worksites/utils/date_helper.dart';
import 'package:worksites/utils/database.dart';

class HomePage extends StatefulWidget {
  final String? payload;
  HomePage({
    Key? key,
    this.payload
  }) : super(key: key);
  _HomeState createState() => new _HomeState();
}

class _HomeState extends State<HomePage> with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  DateTime? _last_read_at;

  @override
  void initState() {
    super.initState();
    _configureSelectNotificationSubject();
  }

  @override
  void dispose() {
    selectNotificationSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: true,
        unselectedFontSize: 14,
        type: BottomNavigationBarType.fixed,
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.apps),
            label: AppLocalizations.of(context)!.text('worksites'),
          ),
          BottomNavigationBarItem(
            icon: StreamBuilder<QuerySnapshot>(
                stream: Database().notifications.where('read', isEqualTo: false).where('status', isEqualTo: Status.publied.index).snapshots(),
                builder: (context, snapshot) {
                  int count = 0;
                  if (snapshot.hasData && snapshot.data!.size > 0) {
                    snapshot.data!.docs.forEach((doc) {
                      var date = DateHelper.parse(doc['updated_at']);
                      if (_last_read_at == null || date!.isAfter(_last_read_at!)) {
                        DateTime? start = doc['start_at'] != null ? DateHelper.parse(doc['start_at']) : null;
                        DateTime? end = doc['end_at'] != null ? DateHelper.parse(doc['end_at']) : null;
                        if (DateHelper.isBetween(start, end)) {
                          ++count;
                        }
                      }
                    });
                  }
                  if (count > 0) {
                    return Badge(
                        shape: BadgeShape.circle,
                        borderRadius: BorderRadius.circular(100),
                        child: Icon(Icons.show_chart),
                        badgeContent: Text(count.toString(),
                            style: TextStyle(color: Colors.white))
                    );
                  }
                  return Icon(Icons.show_chart);
                }
            ),
            label: AppLocalizations.of(context)!.text('activity'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: AppLocalizations.of(context)!.text('planning'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.file_present),
            label: AppLocalizations.of(context)!.text('documents'),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.secondary,
        unselectedItemColor: Colors.black54,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: _showPage(),
    );
  }

  _initialize() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString(LAST_READ_KEY);
    if (value != null) {
      _last_read_at = DateHelper.parse(value);
    }
  }

  void _configureSelectNotificationSubject() {
    if (widget.payload != null) {
      setState(() {
        _selectedIndex = 1;
      });
    }
    selectNotificationSubject.stream.listen((String? payload) async {
      if (payload != null)  {
        setState(() {
          _selectedIndex = 1;
        });
      }
    });
  }

  Widget? _showPage() {
    _initialize();
    switch (_selectedIndex) {
      case 0: return WorksitesPage();
      case 1: return ActivityPage();
      case 2: return PlanningPage();
      case 3: return DocumentsPage();
    }
  }
}

