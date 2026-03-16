# Redii AI Chat

## Overview

OpenAI-style AI chat interface with multi-modal inputs.

## Features

### 📝 Multi-modal input
- Text chat
- Image upload (Photos)
- Voice notes (5–30s)
- Video upload
- File attachments

### 🎨 UI/UX
- OpenAI-like layout
- Smart message stream (user vs assistant)
- Attachment previews
- Typing indicator
- Auto scroll to bottom

### 🔧 Implementation

#### Data model
- `AIMessage` (text + attachments)
- `AIMessage.Attachment` (image/voice/video/file)

#### View model
- `AIChatViewModel` manages state and integrates with `AIService`

#### Components
- `AIChatView`, `MessageRow`, `AttachmentView`
- `ProcessingIndicator`, `ImagePicker`, `DocumentPicker`

## Usage

### Access in app
1. Open Redii
2. Switch to the "AI Chat" tab
3. Start chatting

### Send a text message
- Type in the field
- Tap the send button (blue icon appears when ready)

### Add attachments
Bottom toolbar offers:
- 📷 Photo
- 🎥 Video
- 🎤 Voice
- 📄 File

### Preview attachments
- Thumbnails appear above the input field
- Remove using the X button

## Backend Integration

### Endpoints
- `/ai/message-polish`
- `/ai/daily-prompt`
- `/ai/weekly-summary`

### Configuration
In `AIService.swift`:
```swift
private let baseURL: String = "https://your-worker.workers.dev"
private let apiToken: String = "your-api-token"
```

## Message Types

### User message
```swift
let message = AIMessage.userMessage(
    content: "Hello!",
    attachments: nil
)
```

### Assistant message
```swift
let message = AIMessage.assistantMessage(
    content: "Hello! How can I help you today?"
)
```

### Message with attachment
```swift
let attachment = AIMessage.Attachment(
    type: .image,
    url: imageURL,
    name: "photo.jpg"
)
let message = AIMessage.userMessage(
    content: "Look at this!",
    attachments: [attachment]
)
```

## Examples

### Text chat
```
User: "Today was great!"
AI: "Today was simply wonderful, filled with gentle joy and warm moments..."
```

### Image chat
```
User: [photo] "Look at this sunset!"
AI: "What a breathtakingly beautiful sunset! The colors are so peaceful and romantic..."
```

## Roadmap

- [ ] Voice input (STT)
- [ ] Video player
- [ ] File preview/open
- [ ] Message history persistence
- [ ] Search
- [ ] i18n

## Tech

- SwiftUI, Async/Await
- URLSession, AVFoundation
- PhotosPicker, DocumentPicker

