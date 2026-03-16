# Redii iOS – Quick Start

## Overview

Redii is a private couples app for two people to capture shared moments.

## 核心功能

### 🏠 Home
- Days together counter
- Quick add Moment
- Quick access to AI Chat and Partner Chat

### ⭐ Moments
- Types: Note, Photo, Mood, Voice
- Filters (All/Notes/Photos/Moods/Voice)
- Pull to refresh
- Swipe to delete

### 🤖 AI Chat
- OpenAI-style chat UI
- Multi-modal inputs:
  - 📝 Text
  - 🎤 Voice
  - 📷 Image
  - 🎥 Video
  - 📄 File
- Backend API integration
- Auto scroll to latest message
- Subtle typing indicator

### 💬 Partner Chat
- Private chat
- Lightweight reactions
- Real-time sync (via CloudKit in future)

### 📸 Memory Gallery
- Grid for photos and voice entries
- Detail view
- Timeline browsing

### ⚙️ Settings
- Theme color
- App Lock
- Export (stub)

## Tech Stack

- UI: SwiftUI
- Architecture: MVVM + Repository
- Data: Core Data + CloudKit
- DI: Simple container
- Concurrency: async/await
- Testing: Unit tests

## AI Chat Details

### Input Types
```swift
enum InputType {
    case text      // text input
    case voice     // voice recording
    case image     // image selection
    case video     // video selection
    case file      // file attachment
}
```

### Message Model
```swift
struct AIMessage: Identifiable, Codable {
    let id: UUID
    var content: String
    let timestamp: Date
    let role: MessageRole  // user / assistant
    var attachments: [Attachment]?
}
```

### Usage

1. Access AI Chat
   - Select the "AI Chat" tab
   - Or tap "AI Chat" on Home quick actions
   - Or tap the sparkles icon in the toolbar

2. Send a text message
   - Type text and tap the send button

3. Add attachments
   - Use bottom toolbar icons:
     - 📷 Photo
     - 🎥 Video
     - 🎤 Voice
     - 📄 File

4. Preview attachments
   - Preview appears above the input field
   - Remove with the X button

## Backend API

### Configuration
Configure in `Redii/Redii/Services/AIService.swift`:
```swift
private let baseURL: String = "https://your-worker.workers.dev"
private let apiToken: String = "your-api-token"
```

### Endpoints
- `POST /ai/message-polish` - polish a message
- `GET /ai/daily-prompt` - fetch daily prompt
- `POST /ai/weekly-summary` - generate weekly summary

## Project Structure

```
Redii/
├── Redii/
│   ├── Models/              # data models
│   │   ├── Moment.swift
│   │   ├── User.swift
│   │   ├── ChatMessage.swift
│   │   ├── AIMessage.swift     # AI 消息模型
│   │   └── AppState.swift
│   ├── Views/               # views
│   │   ├── RediiApp.swift
│   │   ├── HomeView.swift
│   │   ├── AIChatView.swift    # AI Chat 界面
│   │   ├── ChatView.swift
│   │   └── ...
│   ├── ViewModels/          # view models
│   │   ├── AIChatViewModel.swift  # AI Chat 逻辑
│   │   └── ...
│   ├── Repositories/        # repositories
│   ├── Services/            # services
│   │   ├── AIService.swift  # AI API service
│   │   ├── CloudKitService.swift
│   │   └── ...
│   └── Core/                # core config
├── RediiTests/             # 单元测试
└── RediiBackend/           # 后端服务
```

## Development Guide

### Run the app
1. Open Xcode
2. Import the `Redii/Redii` folder
3. Configure CloudKit (optional)
4. Run

### Run the backend
```bash
cd RediiBackend
npm install
wrangler secret put OPENAI_API_KEY
wrangler secret put API_TOKEN
wrangler dev
```

### Tests
```bash
# Run unit tests via Xcode (Cmd+U)
```

## Highlights

✅ Production-quality code
- Robust error handling
- Async architecture
- Protocol abstractions
- Dependency injection

✅ Modern UI/UX
- SwiftUI, SF Symbols, Haptics
- Smooth animations

✅ Complete features
- AI chat
- Multi-modal support
- Local cache + CloudKit sync

✅ Tests
- Unit tests for models, repos, view models

## Next Steps

- [ ] Voice recording (real capture)
- [ ] Video playback
- [ ] File preview improvements
- [ ] Message history persistence
- [ ] Reactions
- [ ] Theming animations

## License

MIT License

