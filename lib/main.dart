import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'home_page.dart';
import 'reports_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';
import 'alert_details_page.dart';
import 'alert_store.dart';


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("📩 BG Message: ${message.messageId}");
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await EasyLocalization.ensureInitialized();

  await FirebaseMessaging.instance.requestPermission();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'Used for important notifications',
    importance: Importance.high,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  const AndroidInitializationSettings androidInitSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  final InitializationSettings initSettings =
      InitializationSettings(android: androidInitSettings);

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      if (response.payload != null) {
        final alert = AlertStore.decodePayload(response.payload!);
        navigatorKey.currentState?.pushNamed('/alertDetails', arguments: alert);
      }
    },
  );

  //Dynamic token registration (only added this block)
FirebaseMessaging.instance.getToken().then((token) async {
  print("🔐 [DEBUG] Full FCM Token: $token"); 
  try {
    final response = await http.post(
      Uri.parse('http://192.168.8.137:8000/register_device'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token, 'platform': 'android'}), 
    );
    print("✅ [DEBUG] Registration response: ${response.body}");
  } catch (e) {
    print("❌ [DEBUG] Registration error: ${e.toString()}");
  }
});

  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
    print("🔐 Refreshed FCM Token: $newToken");
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:8000/register_device'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': newToken}),
      );
      print("Token refresh status: ${response.statusCode}");
    } catch (e) {
      print("Token refresh failed: $e");
    }
  });


  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  print("Received notification: ${message.notification?.title}");
});
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;

      final alert = {
      'title': notification?.title ?? 'Alert',
      'body': notification?.body ?? 'No message',
      'status': 'unresolved',  
      'location': message.data['location'],
      'risk_level': message.data['risk_level'],  
};

      AlertStore.addAlert(alert);

      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'High Importance Notifications',
              channelDescription: 'Used for important notifications',
              icon: '@mipmap/ic_launcher',
              importance: Importance.max,
              priority: Priority.high,
            ),
          ),
          payload: AlertStore.encodePayload(alert),
        );
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final alert = {
        'title': message.notification?.title ?? 'Alert',
        'body': message.notification?.body ?? 'No message',
        'status': 'unresolved',
        'location': message.data['location'],
        'risk_level': message.data['risk_level'],
      };

      AlertStore.addAlert(alert);

      navigatorKey.currentState?.pushNamed('/alertDetails', arguments: alert);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Secure Sight',
      theme: ThemeData(primarySwatch: Colors.orange),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home: HomePage(),
      routes: {
        '/home': (context) => HomePage(),
        '/reports': (context) => ReportsPage(),
        '/profile': (context) => ProfilePage(),
        '/settings': (context) => const SettingsPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/alertDetails') {
          final alert = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (context) => AlertDetailsPage(alert: alert),
          );
        }
        return null;
      },
    );
  }
}
