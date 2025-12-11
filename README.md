<div align="center" style="display: flex; gap: 20px; margin-bottom: 1rem">
  <img src="assets/icons/logo_dark.svg" alt="GitScribe Logo" height="86"/>
  <div style="display: flex; flex-direction: column; align-items: flex-start;">
    <h1 style="margin: 0;">GitScribe</h1>
    <strong style="margin-top: 4px;">Intelligent Insights for Every Commit</strong>
  </div>
</div>

[![Netlify Status](https://api.netlify.com/api/v1/badges/27eacb57-b520-433b-8b54-ae350d2a3f6d/deploy-status)](https://app.netlify.com/projects/git-scribe/deploys)

GitScribe helps you understand your GitHub repository changes through AI-generated summaries. Browse repositories, compare branches, and get intelligent insights into code changes. You can use your own AI, including local models through Ollama.

## Features

- 🔐 **GitHub OAuth Authentication** via Supabase
- 📦 **Repository Browsing** with responsive interface
- 🌿 **Branch Comparison** with detailed commit and file changes
- 🤖 **AI-Powered Summaries** using OpenAI, Anthropic, Gemini, or Ollama
- 🎨 **Multiple Themes** with programming-themed color schemes
- 📱 **Cross-Platform** - Web, Android, iOS (WIP), macOS, Linux, Windows

## Quick Start

### Prerequisites

- Flutter SDK 3.10.1+
- Supabase project (for authentication)
- (Optional) AI provider API keys

### Setup

1. **Clone and install:**
   ```bash
   git clone <repository-url>
   cd gitscribe
   flutter pub get
   ```

2. **Configure Supabase:**
   - Create a project at [Supabase](https://supabase.com)
   - Copy your Project URL and anon key
   - Create `.env` file:
     ```env
     SUPABASE_URL=your_supabase_project_url
     SUPABASE_ANON_KEY=your_supabase_anon_key
     ```

3. **Set up GitHub OAuth:**
   - In Supabase: Enable GitHub provider in Authentication → Providers
   - Create a [GitHub OAuth App](https://github.com/settings/developers)
   - Set callback URL: `https://your-supabase-project.supabase.co/auth/v1/callback`
   - Add Client ID and Secret to Supabase GitHub provider settings

4. **Configure AI (Optional):**
   - Open app → Options
   - Select AI provider and enter API key
   - Keys are stored securely


## Contributing

Do keep in mind I'm a first time flutter developer and AI heavily aided my in developing this app. Otherwise, feel free to make a contribution!

## License

MIT License - see [LICENSE](LICENSE) file for details.
