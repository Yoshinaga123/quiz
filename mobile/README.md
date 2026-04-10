# Quiz Mobile App

Flutter based native client for the quiz application.

## Current direction

This app now starts from a quiz-focused variation of the clean architecture sample in:

- `../samples/flutter-clean-architecture-example`

We are intentionally **not** copying the whole comparison project structure. The mobile app will use:

- `data / domain / presentation` layers
- `Riverpod` as the single state management solution
- a local mock data source first, then the Go API in `../backend`

## Current scope

The initial scaffold includes:

- quiz list page
- quiz details page
- domain entities, repository contracts, and use cases
- local data source with mock quiz content

## Structure

```text
lib/
  layers/
    data/
    domain/
    presentation/
```

## Notes

- `mobile/ios/Runner/GoogleService-Info.plist` already exists and is preserved.
- Flutter tooling is not installed in the current environment, so this scaffold has not been executed locally yet.
