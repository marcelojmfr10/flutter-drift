# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Learning app for the Drift local database (Flutter). Currently a fresh scaffold (`lib/main.dart` is a Hello World); the intended stack per README is:

- Flutter
- Riverpod (with annotations, i.e. `riverpod_annotation` + code generation)
- Drift (local database, also code-generated)
- go_router

When adding these dependencies, both Riverpod annotations and Drift require `build_runner` code generation.

## Commands

```sh
flutter run                 # run the app (add -d <device> to pick a device)
flutter analyze             # lint (uses flutter_lints via analysis_options.yaml)
flutter test                # run all tests
flutter test test/foo_test.dart            # run a single test file
flutter test --plain-name "test name"      # run a single test by name
flutter pub get             # fetch dependencies

# Once Drift/Riverpod codegen is added:
dart run build_runner build --delete-conflicting-outputs   # one-shot codegen
dart run build_runner watch --delete-conflicting-outputs   # codegen in watch mode
```

## Notes

- `cheatsheets/` contains PDF reference sheets for Drift and Riverpod annotations.
- README and project docs are written in Spanish.
