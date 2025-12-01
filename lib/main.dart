import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart'; // Removed due to error
import 'LoginPage.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  // 1. Initialize Bindings: Required for platform channel calls (like orientation) before runApp
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Load Environment Variables
  // await dotenv.load(fileName: ".env"); // Removed dotenv loading

  // 3. Lock Orientation: Professional apps often lock to portrait to ensure layout consistency
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 4. Status Bar Style: Transparent status bar for a modern look.
  // Default to dark icons (for light backgrounds). Screens with colored AppBars will override this.
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark, // Dark icons for white/light backgrounds
    statusBarBrightness: Brightness.light,    // For iOS
  ));

  runApp(const InventoryApp());
}

class InventoryApp extends StatelessWidget {
  const InventoryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Inventory App',
      
      // Use the centralized AppTheme for consistent styling
      theme: AppTheme.lightTheme,
      
      // Builder to apply global modifications (like Text Scaling)
      builder: (context, child) {
        final mediaQueryData = MediaQuery.of(context);
        
        // Apply a global text scale factor of 1.1x for better readability
        // Using TextScaler.linear to fix type error while maintaining the scaling logic
        // We access textScaleFactor (deprecated but necessary to get the value) to respect system settings
        return MediaQuery(
          data: mediaQueryData.copyWith(
            // ignore: deprecated_member_use
            textScaler: TextScaler.linear(mediaQueryData.textScaleFactor * 1.1),
          ),
          child: child!,
        );
      },
      home: const LoginPage(), 
    );
  }
}
