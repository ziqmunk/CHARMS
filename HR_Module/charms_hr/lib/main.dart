import 'package:charms_hr/api_service.dart';
import 'package:charms_hr/camera_service.dart';
import 'package:charms_hr/providers/attendances.dart';
import 'package:charms_hr/providers/claims.dart';
import 'package:charms_hr/providers/leaves.dart';
import 'package:charms_hr/providers/payments.dart';
import 'package:charms_hr/providers/schedules.dart';
import 'package:charms_hr/providers/staffs.dart';
import 'package:charms_hr/screens/admin/admin_dashboard_screen.dart';
import 'package:charms_hr/screens/main_dashboard.dart';
import 'package:charms_hr/screens/staff/staff_dashboard_screen.dart';
import 'package:charms_hr/providers/auth.dart';
import 'package:charms_hr/providers/bookevents.dart';
import 'package:charms_hr/providers/events.dart';
import 'package:charms_hr/providers/indemnities.dart';
import 'package:charms_hr/providers/users.dart';
import 'package:charms_hr/providers/theme_provider.dart';
import 'package:charms_hr/screens/auth_screen.dart';
import 'package:charms_hr/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:overlay_support/overlay_support.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await CameraService.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProvider(create: (ctx) => Users()),
        ChangeNotifierProvider(create: (ctx) => Events()),
        ChangeNotifierProvider(create: (ctx) => Indemnitites()),
        ChangeNotifierProvider(create: (ctx) => BookEvents()),
        ChangeNotifierProvider(create: (ctx) => Staffs()),
        ChangeNotifierProvider(create: (ctx) => Schedules()),
        ChangeNotifierProvider(create: (ctx) => Payments()),
        ChangeNotifierProvider(create: (ctx) => Attendances()),
        ChangeNotifierProvider(create: (ctx) => Leaves()),
        ChangeNotifierProvider(create: (ctx) => Claims()),
        ChangeNotifierProvider(create: (ctx) => ThemeProvider()),
      ],
      child: OverlaySupport.global(
        child: Consumer<Auth>(
          builder: (ctx, auth, _) => Consumer<ThemeProvider>(
            builder: (ctx, themeProvider, _) => MaterialApp(
              navigatorKey: navigatorKey,
              title: 'Flippers Command Module/System, FlipC',
              debugShowCheckedModeBanner: false,
              theme: themeProvider.isDarkMode
                  ? ThemeData.dark().copyWith(
                      primaryColor: Colors.blue,
                      scaffoldBackgroundColor: Colors.black,
                    )
                  : ThemeData(
                      primaryColor: Colors.blue,
                      appBarTheme: AppBarTheme(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      scaffoldBackgroundColor: Colors.white,
                      textButtonTheme: TextButtonThemeData(
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                      ),
                      textTheme: const TextTheme(
                        bodyText1: TextStyle(color: Colors.black),
                        bodyText2: TextStyle(color: Colors.black),
                      ),
                      inputDecorationTheme: const InputDecorationTheme(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.blue),
                        ),
                        labelStyle: TextStyle(color: Colors.black),
                      ),
                      cardColor: Colors.grey[100],
                    ),
              home: auth.isAuth
                  ? _selectDashboard(auth.usertype)
                  : FutureBuilder(
                      future: auth.tryAutoLogin(),
                      builder: (ctx, authResultSnapshot) =>
                          authResultSnapshot.connectionState ==
                                  ConnectionState.waiting
                              ? const SplashScreen()
                              : const AuthScreen(),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _selectDashboard(int userType) {
  final username =
      Provider.of<Auth>(navigatorKey.currentContext!, listen: false).username;

  if (userType == 0) {
    return const AuthScreen();
  } else if ([1, 2, 3, 4, 5].contains(userType)) {
    return MainDashboard();
  } else if (userType == 6) {
    return AdminDashboard(username: username);
  } else if ([7, 8, 9, 10].contains(userType)) {
    return StaffDashboardScreen(username: username);
  } else {
    throw Exception("Unknown user type: $userType");
  }
}
