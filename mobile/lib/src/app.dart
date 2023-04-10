import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mobile/src/camera/camera_view.dart';
import 'package:mobile/src/main_view/main_view.dart';
import 'package:mobile/src/profile/profile_view.dart';
import 'package:mobile/src/sign_in/sign_in_view.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

import 'sample_feature/sample_item_details_view.dart';
import 'sample_feature/sample_item_list_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The AnimatedBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    return Consumer<SettingsController>(
      builder: (context, settingsController, child) => AnimatedBuilder(
        animation: settingsController,
        builder: (BuildContext context, Widget? child) {
          return MaterialApp(
            // Providing a restorationScopeId allows the Navigator built by the
            // MaterialApp to restore the navigation stack when a user leaves and
            // returns to the app after it has been killed while running in the
            // background.
            restorationScopeId: 'app',

            // Provide the generated AppLocalizations to the MaterialApp. This
            // allows descendant Widgets to display the correct translations
            // depending on the user's locale.
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en', ''), // English, no country code
            ],

            // Use AppLocalizations to configure the correct application title
            // depending on the user's locale.
            //
            // The appTitle is defined in .arb files found in the localization
            // directory.
            onGenerateTitle: (BuildContext context) =>
                AppLocalizations.of(context)!.appTitle,

            // Define a light and dark color theme. Then, read the user's
            // preferred ThemeMode (light, dark, or system default) from the
            // SettingsController to display the correct theme.
            theme: ThemeData(),
            darkTheme: ThemeData.dark(),
            themeMode: settingsController.themeMode,

            // Define a function to handle named routes in order to support
            // Flutter web url navigation and deep linking.
            onGenerateRoute: (RouteSettings routeSettings) {
              return MaterialPageRoute<void>(
                settings: routeSettings,
                builder: (BuildContext context) {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) {
                    return const SignInView();
                  } else {
                    final arguments = routeSettings.arguments;

                    switch (routeSettings.name) {
                      case CameraView.routeName:
                        return const CameraView();
                      case ProfileView.routeName:
                        return const ProfileView();
                      case SettingsView.routeName:
                        return const SettingsView();
                      case SampleItemDetailsView.routeName:
                        if (arguments is int) {
                          return SampleItemDetailsView(id: arguments);
                        }
                        continue def;
                      case SampleItemListView.routeName:
                        return const SampleItemListView();
                      case MainView.routeName:
                      def:
                      default:
                        return const MainView();
                    }
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
