# Quiz Mobile App

Flutter based native client for the quiz application.

## Current direction

This app uses a quiz-focused clean architecture. We are intentionally **not** copying a comparison project into the published tree. The mobile app will use:

- `data / domain / presentation` layers
- `Riverpod` as the single state management solution
- a local mock data source first, then the Go API in `../backend`

## Current scope

The initial scaffold includes:

- quiz list page
- interactive play (select then reveal) and session scoring
- local history (`shared_preferences`, ADR 0008)
- quiz details page (notification tap; answers stay hidden until submit)
- domain entities, repository contracts, and use cases
- remote data source using the public Go API
- mock Push feed polling and local notification display

## Mock Push notifications

Phase A of push notification delivery does not use Firebase / FCM. Instead, the backend records a mock delivery and the mobile app polls the public feed.

1. Start the backend API.
2. In `admin-web`, set a quiz to `published` and Push `ON`.
3. Click `mock Push 送信` in `admin-web`.
4. Run the mobile app with the backend URL:

```bash
flutter run --dart-define=QUIZ_API_BASE_URL=http://10.0.2.2:8082
```

5. Open the quiz list or tap the notification icon in the app bar. The app calls `GET /v1/push/feed`.
6. If the latest `deliveryId` has not been shown before, `flutter_local_notifications` displays a local notification.
7. Tapping the notification opens that quiz as a playable question (answers stay hidden until submit).

The last displayed `deliveryId` is stored in `shared_preferences` under `quzzes:lastMockPushDeliveryId` to avoid duplicate local notifications.

Platform folders are minimal in this scaffold. Android/iOS permission and icon settings may need to be completed when generating full Flutter platform projects.

## Structure

```text
lib/
  layers/
    data/
    domain/
    presentation/
```

## Notes

- Phase A does not use Firebase. `GoogleService-Info.plist` is gitignored if present locally. Do not commit another product's Firebase project.
- Flutter tooling is not installed in the current environment, so this scaffold has not been executed locally yet.
