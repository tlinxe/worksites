import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:worksites/utils/app_localizations.dart';

class EmptyContainer extends StatelessWidget {
  final IconData? icon;
  final String? message;

  EmptyContainer({
    this.icon,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Image.asset('assets/images/no_search_result.png', width: 200, height: 200)
          ),
          Expanded(
            child: Text(message != null ? message! : AppLocalizations.of(context)!.text('empty_list'), style: TextStyle(fontSize: 25, color: Colors.black38))
          )
        ],
      ),
    );
  }
}
