# studybunnies
MAE Flutter Project


Handling `bodyText2` Error in Flutter Chart Library

When working with the Flutter chart library `charts_flutter` version 0.12.0, there is a possibility of encountering the following error:
../../../AppData/Local/Pub/Cache/hosted/pub.dev/charts_flutter-0.12.0/lib/src/behaviors/legend/legend_entry_layout.dart:134:45: Error: The getter 'bodyText2' isn't defined for the class 'TextTheme'.
- 'TextTheme' is from 'package:flutter/src/material/text_theme.dart' ('/C:/src/flutter/packages/flutter/lib/src/material/text_theme.dart').
Try correcting the name to the name of an existing getter, or defining a getter or field named 'bodyText2'.
color ??= Theme.of(context).textTheme.bodyText2!.color;

This issue arises because the `bodyText2` getter has been deprecated in the latest versions of Flutter. To resolve this issue and ensure that the Flutter chart runs without errors, follow these steps:

Step 1: Navigate to the Flutter Dependency Cache:

•	Open your project directory.

•	Navigate to the `.pub-cache` directory, usually located at:

•	Windows: `C:\Users\<YourUsername>\AppData\Local\Pub\Cache\hosted\pub.dev\charts_flutter-0.12.0\lib\src\behaviors\legend\`

•	macOS/Linux: `~/.pub-cache/hosted/pub.dev/charts_flutter-0.12.0/lib/src/behaviors/legend/`

Step 2: Find and Edit the File:

•	Locate the `legend_entry_layout.dart` file within the specified directory.

•	Open the file in your preferred code editor.

•	Find the line causing the issue (Line 134) and replace `bodyText2` with `bodyMedium`. 

The modified code should look like this:
color ??= Theme.of(context).textTheme.bodyMedium!.color;

Step 3: Save the File:

•	Save the changes you made to the `legend_entry_layout.dart` file.

Step 4: Restart Your Flutter Project:

•	Run `flutter clean` to clean the project.

•	Run `flutter pub get` to fetch the dependencies again.

•	Finally, run your project using `flutter run`.

This modification is necessary to prevent errors and ensure compatibility with the latest Flutter SDK versions, allowing the Flutter chart library to function correctly.








## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
