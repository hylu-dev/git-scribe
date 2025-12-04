# GitScribe

A Flutter application for GitHub integration.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## GitHub OAuth Setup

To enable GitHub authentication, you need to create a GitHub OAuth App:

1. Go to [GitHub Developer Settings](https://github.com/settings/developers)
2. Click "New OAuth App"
3. Fill in the application details:
   - **Application name**: GitScribe (or your preferred name)
   - **Homepage URL**: `http://localhost` (or your app's URL)
   - **Authorization callback URL**: `gitscribe://oauth/callback`
4. Click "Register application"
5. Copy the **Client ID** and generate a **Client Secret**
6. Update `lib/services/github_auth_service.dart`:
   - Replace `YOUR_GITHUB_CLIENT_ID` with your Client ID
   - Replace `YOUR_GITHUB_CLIENT_SECRET` with your Client Secret

### Note on Deep Linking

For the OAuth callback to work properly, you'll need to configure deep linking:
- **Android**: Update `android/app/src/main/AndroidManifest.xml` with intent filters
- **iOS**: Update `ios/Runner/Info.plist` with URL schemes

The callback URL `gitscribe://oauth/callback` should be handled by your app's deep linking configuration.
