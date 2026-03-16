# Redii

A private couples app for two people to capture and share their moments together.

**Two hearts. One center.**

## Overview

Redii is an iOS app designed for couples to strengthen their connection by sharing moments, chatting privately, and reflecting on their relationship with the help of a gentle AI companion. Built with SwiftUI, Core Data, and CloudKit for seamless syncing between partners.

## Features

### Moments
- **Notes** — Capture thoughts, memories, and sweet messages
- **Photos** — Share pictures with captions, stored locally and synced via CloudKit
- **Moods** — Express how you're feeling with emoji-based mood tracking
- **Voice Notes** — Record and share audio messages with full playback controls

### AI Chat
- Conversational AI companion powered by OpenAI via a Cloudflare Worker backend
- Ask for date ideas, relationship advice, or just share what's on your mind
- Multi-modal input: attach photos, videos, voice recordings, and files
- Offline fallback with helpful local responses when the backend isn't available
- Message polish: rewrite messages in a soft, romantic tone
- Daily prompts for couples to reflect on their relationship
- Weekly summaries of shared moments

### Partner Chat (Whispers)
- Real-time private messaging between paired partners
- Message reactions
- Synced via CloudKit for cross-device delivery

### Gallery
- Visual grid of all photos and voice notes
- Tap to view full detail with playback controls
- Pull-to-refresh support

### Pairing
- 6-digit pair code system for connecting partners
- Share code via system share sheet
- CloudKit-based partner discovery and linking
- Skip option for solo exploration

### Security
- Biometric authentication (Face ID / Touch ID) app lock
- Automatic lock on app background
- Passcode fallback when biometrics unavailable

### Settings
- Theme color selection (Pink, Purple, Blue)
- AI backend configuration (URL + API token)
- Data export (JSON)
- Clear all data

## Architecture

```
MVVM + Repository Pattern + Dependency Injection

┌─────────────┐     ┌──────────────┐     ┌──────────────────┐
│    Views     │────▶│  ViewModels  │────▶│   Repositories   │
│  (SwiftUI)  │     │ (@MainActor) │     │   (Protocols)    │
└─────────────┘     └──────────────┘     └──────────────────┘
                                                   │
                                          ┌────────┴────────┐
                                          ▼                 ▼
                                    ┌──────────┐    ┌──────────────┐
                                    │ Core Data│    │   CloudKit   │
                                    │ (Local)  │    │   (Sync)     │
                                    └──────────┘    └──────────────┘
```

- **Views** — Pure SwiftUI, declarative UI
- **ViewModels** — Business logic with `@MainActor` async/await
- **Repositories** — Abstract data access behind protocols
- **Services** — CloudKit sync, AI backend, voice recording, biometric auth, image caching, data export
- **Core** — DI container wiring everything together

## Project Structure

```
ReDii/
├── Redii/                          # iOS client
│   ├── Redii/
│   │   ├── Models/                 # User, Moment, ChatMessage, AIMessage, AppState
│   │   ├── Views/                  # All SwiftUI views
│   │   ├── ViewModels/             # MVVM view models
│   │   ├── Repositories/           # MomentRepository, ChatRepository
│   │   ├── Services/               # CloudKit, AI, Voice, Biometric, ImageCache, DataExport
│   │   ├── Core/                   # DIContainer
│   │   └── CoreData/               # MomentEntity, PersistenceController
│   ├── RediiTests/                 # Unit tests
│   └── Package.swift
├── RediiBackend/                   # Cloudflare Worker backend
│   ├── src/
│   │   ├── index.ts                # API routes (chat, polish, prompt, summary)
│   │   ├── lib/
│   │   │   ├── auth.ts             # Bearer token auth
│   │   │   ├── cors.ts             # CORS headers
│   │   │   └── rateLimiter.ts      # IP-based rate limiting (KV)
│   │   └── types.ts                # TypeScript interfaces
│   └── wrangler.toml
└── README.md
```

## Quick Start

### iOS App

1. Open the project in Xcode
2. Select a simulator or device target
3. Build and run
4. Create your account, pair with your partner, and start sharing moments

**CloudKit setup** (for syncing between devices):
- Enable CloudKit capability in Xcode
- Configure your CloudKit container identifier
- Ensure both partners are signed into iCloud

### Backend

```bash
cd RediiBackend
npm install

# Set secrets
wrangler secret put OPENAI_API_KEY
wrangler secret put API_TOKEN

# Create KV namespace for rate limiting
wrangler kv:namespace create RATE_LIMIT_STORE

# Local development
npm run dev

# Deploy
wrangler deploy
```

Then configure the backend URL and API token in the app's Settings tab.

### API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| POST | `/ai/chat` | Conversational AI chat |
| POST | `/ai/message-polish` | Rewrite text in romantic tone |
| GET | `/ai/daily-prompt` | Generate a daily reflection prompt |
| POST | `/ai/weekly-summary` | Summarize a week of moments |

All endpoints require `Authorization: Bearer <API_TOKEN>` header.

## Tech Stack

### iOS
- **SwiftUI** — Declarative UI framework
- **Core Data** — Local persistence
- **CloudKit** — Cross-device sync and partner pairing
- **AVFoundation** — Voice recording and playback
- **LocalAuthentication** — Face ID / Touch ID
- **PhotosUI** — Photo picker
- **async/await** — Modern concurrency throughout

### Backend
- **Cloudflare Workers** — Edge serverless functions
- **OpenAI API** — GPT-4 for AI features
- **KV Storage** — Rate limiting

## Requirements

- iOS 17+
- Xcode 15+
- iCloud account (for sync features)
- Node.js 18+ (for backend development)

## License

MIT License
