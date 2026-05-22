# Smart Savings — Premium Flutter Frontend

A premium fintech mobile app frontend (Flutter, no backend) for a smart savings platform.
All data is mocked locally; calculations update in real time via Riverpod state.

## Run

```bash
flutter pub get
flutter run
```

Requires Flutter 3.19+ / Dart 3.3+.

## Architecture

```
lib/
  config/          # app constants, mock data loaders
  theme/           # light + dark theme, colors, typography, spacing
  routes/          # go_router config
  utils/           # formatters, helpers
  services/        # mock services (savings, ai coach)
  shared/
    widgets/       # reusable widgets (glass card, neumorphic button, etc.)
    components/    # higher-level building blocks (folder card, goal tile)
  features/
    splash/
    onboarding/
    auth/          # login, signup, otp
    dashboard/
    folders/
    wishlist/
    analytics/
    ai_coach/
    profile/
    settings/
```

## State

- `flutter_riverpod` for state management.
- `balanceProvider`, `foldersProvider`, `expensesProvider`, `wishlistProvider`,
  `themeModeProvider` — all reactive. Editing a balance or adding an expense
  instantly updates the dashboard, folder screen, and analytics.

## Theming

- Light + dark themes with smooth switching from Settings.
- Inter font via `google_fonts`.
- Glassmorphism + soft neumorphism + gradient accents.

## Notes

- All AI coach responses are mocked locally.
- Charts use `fl_chart`. Shimmer loading states included.
- Replace mock services in `lib/services/` with real APIs when wiring a backend.
