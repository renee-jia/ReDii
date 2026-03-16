# AI Chat UI Visualization

## Layout

```
┌─────────────────────────────────────┐
│  AI Chat                     [⚡]   │ ← top navigation
├─────────────────────────────────────┤
│                                     │
│                          ┌────────┐ │
│                          │Hello!  │ │ ← user message (right, blue bubble)
│                          │How can │ │
│                          │you     │ │
│                          │help?   │ │
│                          └────────┘ │
│                          10:23 AM  │
│                                     │
│  ┌─────────────────────┐           │
│  │Hello! I'm here     │           │ ← assistant message (left, gray bubble)
│  │to help you...      │           │
│  └─────────────────────┘           │
│  10:23 AM                           │
│                                     │
│                          ┌────────┐ │
│                          │Make    │ │
│                          │this    │ │
│                          │romantic│ │
│                          └────────┘ │
│                          10:24 AM  │
│                                     │
│  ┌─────────────────────┐           │
│  │Today was            │           │
│  │absolutely          │           │
│  │wonderful...        │           │
│  └─────────────────────┘           │
│  10:24 AM                           │
│                                     │
│                          ┌────────┐ │
│                          │Thank   │ │
│                          │you!    │ │
│                          └────────┘ │
│                          10:25 AM  │
│                                     │
│  ┌─────────────────────┐           │
│  │You're welcome!     │           │
│  └─────────────────────┘           │
│  10:25 AM                           │
│                                     │
├─────────────────────────────────────┤
│  [📷] [📹] [🎤] [📄]               │ ← input type buttons
│  ┌─────────────────────────────────┐ │
│  │ Type a message...        [↑]   │ │ ← input field (auto height)
│  └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

## Message Styles

### User Message
```
┌─────────────────────────┐
│ Today was nice          │  ← blue background, white text
└─────────────────────────┘
        10:23 AM           ← timestamp below
```
- 右对齐
- 蓝色背景
- 白色文字
- 圆角气泡

### Assistant Message
```
    ┌─────────────────────┐
    │ Today was           │  ← gray background, dark text
    │ absolutely          │
    │ wonderful...        │
    └─────────────────────┘
    10:23 AM              ← timestamp below
```
- 左对齐
- 浅灰色背景
- 黑色文字
- 圆角气泡

## Attachments

### Image
```
┌─────────────────────────┐
│  [image 200x200]         │  ← preview
└─────────────────────────┘
```

### Voice
```
┌─────────────────────────┐
│  ▶ Play   voice.m4a     │  ← play button + filename
└─────────────────────────┘
```

### Video
```
┌─────────────────────────┐
│  🎥                     │  ← icon + filename
│  video.mp4              │
└─────────────────────────┘
```

### File
```
┌─────────────────────────┐
│  📄 document.pdf        │  ← icon + name + size
│    2.5 MB               │
└─────────────────────────┘
```

## Input Area

### Basic
```
┌─────────────────────────────────────┐
│  [⌨️] Type a message...       [↑]   │  ← keyboard + input + send
└─────────────────────────────────────┘
```

### With attachments
```
┌─────────────────────────────────────┐
│  [image preview] [X]               │  ← attachment preview
├─────────────────────────────────────┤
│  [⌨️] Type a message...       [↑]   │
└─────────────────────────────────────┘
```

### Toolbar
```
┌─────────────────────────────────────┐
│  [📷 Photo] [🎥 Video]
│  [🎤 Voice] [📄 File]
└─────────────────────────────────────┘
```

## Typing Indicator

### Animation
```
    ┌────────┐
    │ ●  ●  ● │  ← three bouncing dots
    └────────┘
```

## Scenarios

### Scenario 1: Empty State
```
┌─────────────────────────────────────┐
│                                     │
│           💬                        │
│                                     │
│         No messages yet             │
│    Start a conversation to begin    │
│                                     │
└─────────────────────────────────────┘
```

### Scenario 2: Conversation
```
User: "Make this romantic: 'I had coffee'"
AI:   "I savored a warm cup of coffee today, and it reminded me of the cozy moments we share together..."
```

### Scenario 3: With Image
```
User: [image] + "Look at this sunset!"
AI: "What a breathtakingly beautiful sunset! The colors are so peaceful and romantic..."
```

### Scenario 4: Multiple Attachments
```
User: [image] + [voice] + [file] "Check out these files!"
AI: "I received your message with attachments!"
```

## Interactions

### Send message
1. Type text (or add attachments)
2. Blue send button appears
3. Tap to send
4. Message appended
5. Auto-scroll to bottom
6. Typing indicator visible
7. Assistant response appears

### Choose attachments
1. Tap toolbar icons (📷/🎥/🎤/📄)
2. System pickers open
3. Preview appears
4. Remove before sending (X)

### Long-press actions
- Bubble: copy/delete
- Attachment: preview/download

## Visual Feedback

### Button states
- Disabled: gray
- Enabled: blue
- Sending: typing indicator
- Success: message shown
- Error: inline error

### Animations
- New message: slide-in
- Typing: bouncing dots
- Upload: progress bar
- Error: subtle shake or red hint

## Shortcuts
- Send: Cmd+Enter
- New line: Shift+Enter
- Clear input: Cmd+K

## Responsive

### iPhone (portrait)
- Single column
- Input docked at bottom
- Toolbar scrolls horizontally

### iPad (landscape)
- List + detail
- Split view

## Themes

### Light
- User: #007AFF
- Assistant: #E5E5EA
- Background: #FFFFFF

### Dark
- User: #0A84FF
- Assistant: #2C2C2E
- Background: #000000

