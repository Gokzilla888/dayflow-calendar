# Dayflow

Dayflow is the first working UI milestone for a motion-first calendar app. It currently includes:

- Animated month and agenda views
- Date selection and event indicators
- Event, task, personal and holiday layers
- A date-trivia card
- Light and dark themes
- Responsive Material 3 UI
- A create-event bottom sheet

## Run locally

1. Install the current stable Flutter SDK and Android Studio.
2. From the directory above this project, run `flutter create dayflow --platforms=android` if the Android platform folder is not present.
3. Restore this repository's `pubspec.yaml`, `analysis_options.yaml`, `lib/`, and `test/` if prompted before overwriting.
4. Run:

```bash
cd dayflow
flutter pub get
flutter analyze
flutter test
flutter run
```

## Build Android packages

```bash
flutter build apk --release --split-per-abi
flutter build appbundle --release
```

Release APKs are written beneath `build/app/outputs/flutter-apk/`. The Play Store bundle is written beneath `build/app/outputs/bundle/release/`.

## Next milestone

Add a local SQLite repository, editable events, and a backend OAuth connector for Google Calendar. Provider secrets and refresh tokens must stay on the backend, not in the APK.
