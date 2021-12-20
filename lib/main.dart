import 'dart:async';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart' as Foundation;
import 'package:flutter/material.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_native_timezone/flutter_native_timezone.dart';
import 'package:rxdart/subjects.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:worksites/controller/home_page.dart';
import 'package:worksites/controller/login_page.dart';
import 'package:worksites/utils/app_localizations.dart';
import 'package:worksites/utils/constants.dart';
import 'package:worksites/utils/notifications.dart';

import 'utils/theme.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  String? title = message.data['title'];
  if (title != null) {
    String? id = message.data['id'];
    Notifications.instance.showNotification(
        id != null ? int.parse(id) : 0,
        title,
        body: message.data['body'],
        payload: message.data['payload'],
        scheduled: message.data['scheduled']
    );
  }
}

/// Streams are created so that app can respond to notification-related events
/// since the plugin is initialised in the `main` function
final BehaviorSubject<String?> selectNotificationSubject = BehaviorSubject<String?>();

/// Create a [AndroidNotificationChannel] for heads up notifications
late AndroidNotificationChannel channel;

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

String? selectedNotificationPayload;
bool USE_FIRESTORE_EMULATOR = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  if (USE_FIRESTORE_EMULATOR && Foundation.kDebugMode) {
    print('Using Firestore Emulator');
    FirebaseFirestore.instance.settings = const Settings(
        host: '192.168.0.147:8084',
        // host: '86.215.80.45:8084',
        // host: 'localhost:8084',
        sslEnabled: false,
        persistenceEnabled: false
    );
  }
  _configureLocalNotifications();
  _configureFirebaseMessaging();

  runApp(
    MyApp(payload: selectedNotificationPayload)
  );
}

void _configureLocalNotifications() async {
  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await _configureLocalTimeZone();
  final NotificationAppLaunchDetails? notificationAppLaunchDetails = !Foundation.kIsWeb &&
      Platform.isLinux
      ? null
      : await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
  if (notificationAppLaunchDetails?.didNotificationLaunchApp ?? false) {
    selectedNotificationPayload = notificationAppLaunchDetails!.payload;
  }
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');

  /// Note: permissions aren't requested here just to demonstrate that can be
  /// done later
  final IOSInitializationSettings initializationSettingsIOS = IOSInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false
  );
  const MacOSInitializationSettings initializationSettingsMacOS = MacOSInitializationSettings(
    requestAlertPermission: false,
    requestBadgePermission: false,
    requestSoundPermission: false,
  );
  final LinuxInitializationSettings initializationSettingsLinux = LinuxInitializationSettings(
    defaultActionName: 'Open notification',
    defaultIcon: AssetsLinuxIcon('icons/app_icon.png'),
  );
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
    macOS: initializationSettingsMacOS,
    linux: initializationSettingsLinux,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings, onSelectNotification: (String? payload) async {
    selectedNotificationPayload = payload;
    selectNotificationSubject.add(payload);
  });
}

Future<void> _configureLocalTimeZone() async {
  if (Foundation.kIsWeb || Platform.isLinux) {
    return;
  }
  tz.initializeTimeZones();
  final String? timeZoneName = await FlutterNativeTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(timeZoneName!));
}

void _configureFirebaseMessaging() async {
  // Set the background messaging handler early on, as a named top-level function
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  if (!Foundation.kIsWeb) {
    /// Update the iOS foreground notification presentation options to allow
    /// heads up notifications.
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }
}

class MyApp extends StatefulWidget {
  final String? payload;
  MyApp({
    Key? key, this.payload,
  }) : super(key: key);
  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<MyApp> {

  TranslationsDelegate? _newLocaleDelegate;

  @override
  void initState() {
    super.initState();
    _newLocaleDelegate = TranslationsDelegate(newLocale: null);
    _subscribe();
  }

  void onLocaleChange(Locale locale) {
    setState(() {
      _newLocaleDelegate = TranslationsDelegate(newLocale: locale);
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final ThemeData theme = ThemeData(
      fontFamily: 'Montserrat',
      primaryColor: primaryColor,
    );
    return MaterialApp(
        onGenerateTitle: (BuildContext context) => AppLocalizations.of(context)!.text('app_title'),
        debugShowCheckedModeBanner: false,
        theme: theme.copyWith(
          colorScheme: theme.colorScheme.copyWith(secondary: pointerColor),
        ),
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, snapshot) {
            return (!snapshot.hasData) ? LoginPage() : HomePage(payload: widget.payload);
          },
        ),
        builder: EasyLoading.init(),
        localizationsDelegates: [
          _newLocaleDelegate!,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          const Locale('en'), // English
          const Locale('fr'), // French
        ]
    );
  }

  Future<void> _subscribe() async {
    if (!Foundation.kIsWeb) {
      await FirebaseMessaging.instance.subscribeToTopic(NOTIFICATION_TOPIC);
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        String? title = message.data['title'];
        if (title != null) {
          String? id = message.data['id'];
          Notifications.instance.showNotification(
              id != null ? int.parse(id) : 0,
              title,
              body: message.data['body'],
              payload: message.data['payload'],
              scheduled: message.data['scheduled']
          );
        }
      });
    }
  }
}
