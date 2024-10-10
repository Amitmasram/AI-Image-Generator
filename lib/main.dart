// import 'package:ai_image_generator/features/prompt/ui/create_prompt_screen.dart';
// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//           appBarTheme:
//               AppBarTheme(backgroundColor: Colors.grey.shade900, elevation: 0),
//           brightness: Brightness.dark,
//           scaffoldBackgroundColor: Colors.grey.shade900),
//       home: CreatePromptScreen(),
//     );
//   }
// }

import 'package:ai_image_generator/features/prompt/ui/create_prompt_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart';

void main() {
  runApp(DevicePreview(
    enabled: !kReleaseMode, // Enable in debug mode only
    builder: (context) => MyApp(), // Wrap your app
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      builder: DevicePreview.appBuilder, // Add the builder
      useInheritedMediaQuery: true, // Required for correct scaling
      locale: DevicePreview.locale(context), // Allows previewing locales
      theme: ThemeData(
          appBarTheme:
              AppBarTheme(backgroundColor: Colors.grey.shade900, elevation: 0),
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.grey.shade900),
      home: CreatePromptScreen(),
    );
  }
}
