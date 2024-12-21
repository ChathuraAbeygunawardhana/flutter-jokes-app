## 214003G - Flutter Jokes App - IN3510 - Continuous Assessment 01

A Flutter application that fetches and displays random jokes with offline support.

## Features

- Fetches random jokes from the JokeAPI
- Displays jokes in a beautiful card layout
- Supports offline mode with cached jokes
- Real-time connectivity status monitoring
- Material Design 3 UI
- Automatic retry mechanism for failed requests
- Timeout handling for API requests

## Technical Implementation

### State Management
- Uses Provider pattern for state management
- Implements ChangeNotifier for reactive updates

### Network & Storage
- Utilizes `connectivity_plus` for network status monitoring
- Implements SharedPreferences for local joke storage
- HTTP requests with timeout handling
- Periodic connectivity checks

### UI Components
- Custom JokeCard widget for consistent joke display
- Loading indicators during API calls
- Online/Offline status indicator
- Error handling with user-friendly alerts

## Dependencies

- `provider`: State management
- `http`: API requests
- `shared_preferences`: Local storage
- `connectivity_plus`: Network connectivity monitoring
- `english_words`: Word pair generation (utility)

## Project Structure

- `lib/main.dart`: Application entry point and theme configuration
- `lib/app_state.dart`: Core state management and business logic
- `lib/home_page.dart`: Main UI implementation
- `lib/joke_card.dart`: Reusable joke display widget

## Getting Started

1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter run` to start the application

## API Reference

This app uses the [JokeAPI](https://v2.jokeapi.dev/) to fetch random jokes.

## Error Handling

- Network timeout after 5 seconds
- Fallback to cached jokes when offline
- User-friendly error messages
- Automatic connectivity status updates


