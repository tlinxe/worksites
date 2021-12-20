import 'dart:ui';

import 'package:flutter/material.dart';

const String RECIPIENT = 'contact@fixiply.com';

const NOTIFICATION_TOPIC = 'alerts';

const String SIGN_IN_KEY = 'sign_in_email';
const String LAST_READ_KEY = 'last_read_at';

//Enums
enum Status { pending, publied, disabled}
enum Menu { settings, signout, publish, edition, edit, gallery, archived, hidden, planned, scan}
enum Sort { asc_name, desc_name, asc_size, desc_size}
enum Display { list, portrait, landscape, carousel}
enum View { list, grid, table}
