import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:chatapp/controllers/appwrite_controllers.dart';
import 'package:chatapp/controllers/fcm_controllers.dart';
import 'package:chatapp/controllers/local_saved_data.dart';
import 'package:chatapp/firebase_options.dart';
import 'package:chatapp/providers/chat_provider.dart';
import 'package:chatapp/providers/user_data_provider.dart';
import 'package:chatapp/views/chat_page.dart';
import 'package:chatapp/views/create_or_update_group.dart';
import 'package:chatapp/views/explore_groups.dart';
import 'package:chatapp/views/group_chat_page.dart';
import 'package:chatapp/views/group_details.dart';
import 'package:chatapp/views/home.dart';
import 'package:chatapp/views/invite_members.dart';
import 'package:chatapp/views/phone_login.dart';
import 'package:chatapp/views/profile.dart';
import 'package:chatapp/views/search_users.dart';
import 'package:chatapp/views/update_profile.dart';


import 'providers/group_message_provider.dart';

final navigatorKey = GlobalKey<NavigatorState>();

// function to listen to background changes
Future _firebaseBackgroundMessage(RemoteMessage message) async {
  if (message.notification != null) {
    print("Some notification Received in background...");
  }
}

class LifecycleEventHandler extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    String currentUserId =
        Provider.of<UserDataProvider>(
          navigatorKey.currentState!.context,
          listen: false,
        ).getUserId;
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        updateOnlineStatus(status: true, userId: currentUserId);
        print("app resumed");
        break;
      case AppLifecycleState.inactive:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("app inactive");

        break;
      case AppLifecycleState.paused:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("app paused");

        break;
      case AppLifecycleState.detached:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("app detched");

        break;
      case AppLifecycleState.hidden:
        updateOnlineStatus(status: false, userId: currentUserId);
        print("app hidden");
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addObserver(LifecycleEventHandler());

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalSavedData.init();

  // initialize firebase messaging
  await PushNotifications.init();

  // initialize local notifications
  await PushNotifications.localNotiInit();
  // Listen to background notifications
  FirebaseMessaging.onBackgroundMessage(_firebaseBackgroundMessage);

  // on background notification tapped
  FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
    if (message.notification != null) {
      print("Background Notification Tapped");
      navigatorKey.currentState!.pushNamed("/message", arguments: message);
    }
  });

  // to handle foreground notifications
  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    String payloadData = jsonEncode(message.data);
    print("Got a message in foreground");
    if (message.notification != null) {
      PushNotifications.showSimpleNotification(
        title: message.notification!.title!,
        body: message.notification!.body!,
        payload: payloadData,
      );
    }
  });

  // for handling in terminated state
  final RemoteMessage? message =
      await FirebaseMessaging.instance.getInitialMessage();

  if (message != null) {
    print("Launched from terminated state");
    Future.delayed(Duration(seconds: 1), () {
      navigatorKey.currentState!.pushNamed("/home");
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserDataProvider()),
        ChangeNotifierProvider(create: (context) => ChatProvider()),
        ChangeNotifierProvider(create: (context) => GroupMessageProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'FastChat App',
        theme: ThemeData(
          // This is the theme of your application.
          //
          // TRY THIS: Try running your application with "flutter run". You'll see
          // the application has a purple toolbar. Then, without quitting the app,
          // try changing the seedColor in the colorScheme below to Colors.green
          // and then invoke "hot reload" (save your changes or press the "hot
          // reload" button in a Flutter-supported IDE, or press "r" if you used
          // the command line to start the app).
          //
          // Notice that the counter didn't reset back to zero; the application
          // state is not lost during the reload. To reset the state, use hot
          // restart instead.
          //
          // This works for code too, not just values: Most code changes can be
          // tested with just a hot reload.
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        routes: {
          "/": (context) => CheckUserSessions(),
          "/login": (context) => PhoneLogin(),
          "/home": (context) => HomePage(),
          "/chat": (context) => ChatPage(),
          "/profile": (context) => ProfilePage(),
          "/update": (context) => UpdateProfile(),
          "/search": (context) => SearchUsers(),
          "/modify_group": (context) => CreateOrUpdateGroup(),
          "/explore_groups": (context) => ExploreGroups(),
          "/read_group_message": (context) => GroupChatPage(),
          "/invite_members": (context) => InviteMembers(),
          "/group_detail": (context) => GroupDetails(),
          
        },
      ),
    );
  }
}

class CheckUserSessions extends StatefulWidget {
  const CheckUserSessions({super.key});

  @override
  State<CheckUserSessions> createState() => _CheckUserSessionsState();
}

class _CheckUserSessionsState extends State<CheckUserSessions> {
  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      Provider.of<UserDataProvider>(context, listen: false).loadDatafromLocal();
    });

    checkSessions().then((value) {
      final userName =
          Provider.of<UserDataProvider>(context, listen: false).getUserName;
      print("username :$userName");
      if (value) {
        if (userName != null && userName != "") {
          Navigator.pushNamedAndRemoveUntil(context, "/home", (route) => false);
        } else {
          Navigator.pushNamedAndRemoveUntil(
            context,
            "/update",
            (route) => false,
            arguments: {"title": "add"},
          );
        }
      } else {
        Navigator.pushNamedAndRemoveUntil(context, "/login", (route) => false);
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
