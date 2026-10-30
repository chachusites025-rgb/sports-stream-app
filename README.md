# 🏆 Gamez Sports Stream Mobile App (Flutter + Dart)

A sports streaming mobile application built with Flutter & Dart. The app streams live football, basketball, motorsports, and more using the live schedule API from `https://gamez.quest/api/v1/schedule/all`.

---

## 🌟 Key Features

1. **Live Sports Schedule from API**:
   - Automatically synchronizes with `https://gamez.quest/api/v1/schedule/all`.
   - Real-time matches for LaLiga, Ligue 1, Bundesliga, Serie A, NBA, NHL, F1 Motorsports, CFB, and more.
   - Dynamic category filter tabs that auto-populate according to the sports available in the API.

2. **Embedded Web Streaming Player**:
   - Built-in live stream player powered by `webview_flutter`.
   - Plays direct live match broadcasts (`IframeURL`).
   - Built-in redirect & popunder protection to maintain seamless stream viewing.
   - One-tap fullscreen mode (immersive theater landscape view).
   - "Open in Browser" button for external fallback.
   - Quick "Share Stream" option.

3. **Auto-Update & Real-time Refresh**:
   - Pull-to-refresh anytime to fetch the latest matches.
   - Automatic background timer updates the schedule every 60 seconds without interrupting viewing.

4. **Sleek Sports UI / Dark Mode**:
   - High-contrast sports stadium theme (deep dark with neon green and electric cyan accents).
   - Team logos with automatic fallback badges.
   - Live broadcast pulsing badges and match timing chips.
   - Fast instant search across teams, leagues, and sports.

---

## 📱 How to Download & Install the APK on Mobile

1. Open the [Releases page](https://github.com/chachusites025-rgb/sports-stream-app/releases) on your Android device.
2. Tap on `SportsStream-v1.0.apk` to download.
3. Once downloaded, tap on the file to install (if prompted, enable "Install from unknown sources" or your browser's installation permission).
4. Launch **Gamez Stream** and start watching live sports!

---

## 🛠️ Project Structure

```
myapp/
├── .github/
│   └── workflows/
│       └── build-apk.yml          # Automated CI/CD workflow to build APK
├── android/                       # Android configuration & native files
├── lib/
│   ├── main.dart                  # App entry point & theme initialization
│   ├── models/
│   │   └── match_model.dart       # Match JSON model & parsed data fields
│   ├── services/
│   │   └── api_service.dart       # API fetcher for gamez.quest schedule
│   ├── theme/
│   │   └── app_theme.dart         # Dark theme & styling
│   ├── widgets/
│   │   └── match_card.dart        # Match card with team logos & live badge
│   └── screens/
│       ├── home_screen.dart       # Main screen with category tabs & search
│       └── player_screen.dart     # Web stream player with fullscreen mode
└── pubspec.yaml                   # Flutter dependencies & app metadata
```
