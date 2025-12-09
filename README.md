# GitScribe

**AI-powered GitHub branch analysis made simple**

GitScribe is a Flutter application that helps you understand your GitHub repository changes through AI-generated summaries. Browse your repositories, compare branches, and get intelligent insights into code changes with support for multiple AI providers.

## Features

- 🔐 **GitHub OAuth Authentication** - Secure login via Supabase
- 📦 **Repository Browsing** - View all your GitHub repositories in a beautiful, responsive interface
- 🌿 **Branch Comparison** - Compare branches and see detailed commit and file change information
- 🤖 **AI-Powered Summaries** - Generate intelligent summaries of branch changes using:
  - OpenAI (GPT-4, GPT-4o-mini, etc.)
  - Anthropic (Claude 3.5 Sonnet, etc.)
  - Google Gemini (Gemini 2.0 Flash, etc.)
  - Ollama (Local models like Llama 3.2)
- 🎨 **Multiple Themes** - Choose from various programming-themed color schemes
- 🔒 **Secure Storage** - API keys are stored securely using platform-native secure storage
- 📱 **Cross-Platform** - Works on Web, Android, iOS, macOS, Linux, and Windows

## Prerequisites

- Flutter SDK (3.10.1 or higher)
- Dart SDK (3.10.1 or higher)
- A Supabase project (for authentication)
- (Optional) API keys for AI providers you want to use

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd gitscribe
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Set Up Supabase

1. Create a new project at [Supabase](https://supabase.com)
2. Go to Project Settings → API
3. Copy your **Project URL** and **anon/public key**

### 4. Configure Environment Variables

Create a `.env` file in the root directory:

```env
SUPABASE_URL=your_supabase_project_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

Alternatively, you can pass these as compile-time environment variables:

```bash
flutter run --dart-define=SUPABASE_URL=your_url --dart-define=SUPABASE_ANON_KEY=your_key
```

### 5. Configure GitHub OAuth in Supabase

1. In your Supabase dashboard, go to **Authentication** → **Providers**
2. Enable **GitHub** provider
3. Add your GitHub OAuth App credentials:
   - **Client ID**: Your GitHub OAuth App Client ID
   - **Client Secret**: Your GitHub OAuth App Client Secret
4. Set the **Redirect URL** to:
   - For web: `https://your-domain.com/auth/callback` (or `http://localhost:port/auth/callback` for local)
   - For mobile: Configure deep linking (see below)

### 6. Create a GitHub OAuth App

1. Go to [GitHub Developer Settings](https://github.com/settings/developers)
2. Click **New OAuth App**
3. Fill in the details:
   - **Application name**: GitScribe
   - **Homepage URL**: Your app's URL
   - **Authorization callback URL**: 
     - For web: `https://your-supabase-project.supabase.co/auth/v1/callback`
     - For mobile: Your deep link URL (e.g., `gitscribe://oauth/callback`)
4. Click **Register application**
5. Copy the **Client ID** and generate a **Client Secret**
6. Add these to your Supabase GitHub provider settings

### 7. (Optional) Configure AI Providers

1. Open the app and go to **Options** (accessible from the header)
2. Select an AI provider (OpenAI, Anthropic, Gemini, or Ollama)
3. Enter your API key (or base URL for Ollama)
4. Click **Save** - your API key will be securely stored

**Note**: AI summaries are optional. You can use the app to browse repositories and compare branches without configuring an AI provider.

## Running the App

### Web

```bash
flutter run -d chrome
```

### Mobile

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios
```

### Desktop

```bash
# macOS
flutter run -d macos

# Linux
flutter run -d linux

# Windows
flutter run -d windows
```

## Deep Linking Setup (Mobile)

For mobile apps, you'll need to configure deep linking to handle OAuth callbacks.

### Android

Update `android/app/src/main/AndroidManifest.xml`:

```xml
<activity
    android:name=".MainActivity"
    ...>
    <intent-filter>
        <action android:name="android.intent.action.VIEW" />
        <category android:name="android.intent.category.DEFAULT" />
        <category android:name="android.intent.category.BROWSABLE" />
        <data
            android:scheme="gitscribe"
            android:host="oauth" />
    </intent-filter>
</activity>
```

### iOS

Update `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>gitscribe</string>
        </array>
    </dict>
</array>
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── app_router.dart          # Navigation configuration
├── models/                  # Data models
├── screens/                 # UI screens
│   ├── login_screen.dart
│   ├── logged_in_screen.dart
│   ├── repository_branches_screen.dart
│   └── branch_comparison_screen.dart
├── services/                # Business logic
│   ├── ai_service.dart      # AI provider management
│   ├── auth_service.dart    # Authentication
│   ├── github_service.dart   # GitHub API integration
│   └── branch_summary_service.dart
├── widgets/                 # Reusable UI components
│   ├── cards/              # Card components
│   ├── modals/             # Modal dialogs
│   └── navigation/         # Navigation components
└── themes/                  # Theme configurations
```

## Key Technologies

- **Flutter** - Cross-platform UI framework
- **Supabase** - Backend-as-a-Service for authentication
- **GoRouter** - Declarative routing
- **flutter_secure_storage** - Secure key storage
- **Multiple AI Providers** - OpenAI, Anthropic, Gemini, Ollama

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Support

For issues and questions, please open an issue on GitHub.
